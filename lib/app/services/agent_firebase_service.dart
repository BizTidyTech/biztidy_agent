import 'dart:convert';

import 'package:async/async.dart';
import 'package:biztidy_agent_app/main.dart' show logger;
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_model/agent_model.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_jobs/agent_jobs_model/agent_job_model.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

// Top-level function required by compute()
List<AgentJobModel> _parseJobsInBackground(
    List<Map<String, dynamic>> jsonList) {
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  final jobs = jsonList.map((j) => AgentJobModel.fromJson(j)).toList();
  jobs.sort(
      (a, b) => (b.assignedAt ?? epoch).compareTo(a.assignedAt ?? epoch));
  return jobs;
}

class AgentFirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _agents = 'Agents';
  static const String _agentJobs = 'AgentJobs';

  // ─── AUTH ─────────────────────────────────────────────────────────────────

  Future<AgentModel?> getAgentById(String agentId) async {
    try {
      final doc = await _db.collection(_agents).doc(agentId).get();
      if (doc.exists && doc.data() != null) {
        return AgentModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<bool> registerAgent(AgentModel agent) async {
    try {
      await _db.collection(_agents).doc(agent.agentId).set(agent.toJson());
      Fluttertoast.showToast(
        msg: 'Application submitted successfully!',
        backgroundColor: AppColors.normalGreen,
      );
      return true;
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: 'Error registering. Retry.');
      return false;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final result = await _db
          .collection(_agents)
          .where('email', isEqualTo: email)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> approveAgent(String agentId, bool approved) async {
    try {
      await _db
          .collection(_agents)
          .doc(agentId)
          .update({'isApproved': approved});
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  Future<List<AgentModel>> fetchPendingAgents() async {
    try {
      final result = await _db
          .collection(_agents)
          .where('isApproved', isEqualTo: false)
          .get();
      return result.docs
          .map((doc) => AgentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Future<AgentModel?> signInAgent(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final uid = credential.user!.uid;
      final doc = await _db.collection(_agents).doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        Fluttertoast.showToast(msg: 'Agent profile not found.');
        return null;
      }
      return AgentModel.fromJson(doc.data()!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'Incorrect email or password.');
      } else if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: 'No account found with this email.');
      } else {
        Fluttertoast.showToast(msg: 'Sign in failed. Please retry.');
      }
      return null;
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: 'Error signing in. Retry.');
      return null;
    }
  }

  // ─── STATUS ───────────────────────────────────────────────────────────────

  Future<bool> updateAgentStatus(String agentId, String status) async {
    try {
      await _db
          .collection(_agents)
          .doc(agentId)
          .update({'status': status});
      return true;
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: 'Error updating status');
      return false;
    }
  }

  // ─── JOBS ─────────────────────────────────────────────────────────────────

  Stream<List<AgentJobModel>> listenToAgentJobs(String agentId) {
    final myJobsStream = _db
        .collection(_agentJobs)
        .where('agentId', isEqualTo: agentId)
        .snapshots(includeMetadataChanges: false);

    final pendingJobsStream = _db
        .collection(_agentJobs)
        .where('status', isEqualTo: 'pending')
        .where('agentId', isNull: true)
        .snapshots(includeMetadataChanges: false);

    return StreamGroup.merge([myJobsStream, pendingJobsStream])
        .asyncMap((_) async {
      final mySnap = await _db
          .collection(_agentJobs)
          .where('agentId', isEqualTo: agentId)
          .get();
      final pendingSnap = await _db
          .collection(_agentJobs)
          .where('status', isEqualTo: 'pending')
          .where('agentId', isNull: true)
          .get();

      final Map<String, Map<String, dynamic>> combined = {};
      for (final doc in [...mySnap.docs, ...pendingSnap.docs]) {
        combined[doc.id] = doc.data();
      }
      return compute(_parseJobsInBackground, combined.values.toList());
    });
  }

  Future<List<AgentJobModel>> fetchAgentJobs(String agentId) async {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    try {
      final result = await _db
          .collection(_agentJobs)
          .where('agentId', isEqualTo: agentId)
          .get();
      final jobs = result.docs
          .map((doc) => AgentJobModel.fromJson(doc.data()))
          .toList();
      jobs.sort((a, b) =>
          (b.assignedAt ?? epoch).compareTo(a.assignedAt ?? epoch));
      return jobs;
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Future<bool> updateAgentJob(AgentJobModel job) async {
    try {
      await _db
          .collection(_agentJobs)
          .doc(job.jobId)
          .update(job.toJson());
      return true;
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(
        msg: 'Error updating job. Retry.',
        backgroundColor: AppColors.coolRed,
      );
      return false;
    }
  }

  Future<bool> uploadJobPhotos({
    required String jobId,
    required List<String> photoUrls,
    required bool isBefore,
  }) async {
    try {
      await _db.collection(_agentJobs).doc(jobId).update({
        isBefore ? 'beforePhotoUrls' : 'afterPhotoUrls': photoUrls,
      });
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  Future<bool> uploadJobVideos({
    required String jobId,
    required List<String> videoUrls,
    required bool isBefore,
  }) async {
    try {
      await _db.collection(_agentJobs).doc(jobId).update({
        isBefore ? 'beforeVideoUrls' : 'afterVideoUrls': videoUrls,
      });
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  // ─── ADMIN: all agents ────────────────────────────────────────────────────

  Future<List<AgentModel>> fetchAllAgents() async {
    try {
      final result = await _db.collection(_agents).get();
      return result.docs
          .map((doc) => AgentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Stream<List<AgentModel>> listenToAllAgents() {
    return _db
        .collection(_agents)
        .snapshots(includeMetadataChanges: false)
        .map((snapshot) => snapshot.docs
            .map((doc) => AgentModel.fromJson(doc.data()))
            .toList());
  }

  // ─── BANK DETAILS ─────────────────────────────────────────────────────────

  /// Step 1 of the transfer setup: registers the agent's bank account as a
  /// Paystack Transfer Recipient. Called once when saving bank details.
  /// Returns the recipient_code (e.g. "RCP_xxxxx") or null on failure.
  Future<String?> createPaystackRecipient({
    required String accountName,
    required String accountNumber,
    required String bankCode,
    required String paystackSecretKey,
  }) async {
    try {
      final uri = Uri.parse('https://api.paystack.co/transferrecipient');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $paystackSecretKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'type': 'nuban',
          'name': accountName,
          'account_number': accountNumber,
          'bank_code': bankCode,
          'currency': 'NGN',
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data =
            json.decode(response.body) as Map<String, dynamic>;
        final code =
            data['data']?['recipient_code'] as String?;
        logger.i('Paystack recipient created: $code');
        return code;
      }
      logger.w('createPaystackRecipient failed: ${response.body}');
      return null;
    } catch (e) {
      logger.e('createPaystackRecipient error: $e');
      return null;
    }
  }

  /// Saves the agent's verified bank details to Firestore, including the
  /// Paystack recipient_code so future payouts can be initiated instantly.
  Future<bool> saveBankDetails({
    required String agentId,
    required Map<String, dynamic> bankDetails,
  }) async {
    try {
      await _db.collection(_agents).doc(agentId).update({
        'bankDetails': bankDetails,
      });
      Fluttertoast.showToast(
        msg: 'Bank details saved!',
        backgroundColor: AppColors.normalGreen,
      );
      return true;
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: 'Error saving bank details. Retry.');
      return false;
    }
  }

  /// Calls Paystack Resolve Account API to verify account name matches agent.
  /// Returns the verified account name string, or null on failure.
  Future<String?> verifyBankAccount({
    required String accountNumber,
    required String bankCode,
    required String paystackSecretKey,
  }) async {
    try {
      final uri = Uri.parse(
          'https://api.paystack.co/bank/resolve'
          '?account_number=$accountNumber&bank_code=$bankCode');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $paystackSecretKey'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['data']?['account_name'] as String?;
      }
      return null;
    } catch (e) {
      logger.e('verifyBankAccount error: $e');
      return null;
    }
  }

  Future<String?> fetchPaystackKey() async {
    try {
      final doc =
          await _db.collection('Keys').doc('keysData').get();
      return doc.data()?['paystackSecretKey'] as String?;
    } catch (e) {
      return null;
    }
  }

  // ─── WITHDRAWAL REQUESTS ──────────────────────────────────────────────────

  /// Creates a withdrawal request in Firestore.
  /// Includes the recipient_code so the admin app can initiate the
  /// Paystack transfer without any extra lookups.
  Future<bool> requestPayout({
    required String agentId,
    required String agentName,
    required double amount,
    required Map<String, dynamic> bankDetails,
  }) async {
    try {
      final reqId = _db.collection('WithdrawalRequests').doc().id;
      await _db.collection('WithdrawalRequests').doc(reqId).set({
        'requestId': reqId,
        'agentId': agentId,
        'agentName': agentName,
        'amount': amount,
        'bankDetails': bankDetails,
        // Include recipient_code at the top level for easy access in admin
        'recipientCode': bankDetails['recipientCode'],
        'status': 'pending',        // pending | processing | paid | failed
        'transferCode': null,       // Paystack TRF_xxx — set when transfer initiated
        'transferStatus': null,     // Paystack transfer status
        'requestedAt': DateTime.now().toIso8601String(),
        'paidAt': null,
        'note': null,
      });
      Fluttertoast.showToast(
        msg: 'Withdrawal request submitted! Admin will process it.',
        backgroundColor: AppColors.normalGreen,
      );
      return true;
    } catch (e) {
      logger.e('requestPayout error: $e');
      Fluttertoast.showToast(msg: 'Error submitting request. Retry.');
      return false;
    }
  }
}
