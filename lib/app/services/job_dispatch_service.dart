import 'dart:async';
import 'package:biztidy_agent_app/main.dart' show logger;
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDispatchService {
  static final JobDispatchService _instance = JobDispatchService._internal();
  factory JobDispatchService() => _instance;
  JobDispatchService._internal();

  final _db = FirebaseFirestore.instance;
  Timer? _rebroadcastTimer;

  // ── Start watching for unaccepted jobs & rebroadcast after 5 mins ────────
  void startRebroadcastWatcher() {
    _rebroadcastTimer?.cancel();
    // Check every 60 seconds for jobs that need rebroadcast
    _rebroadcastTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _checkAndRebroadcast(),
    );
    logger.i('JobDispatchService: rebroadcast watcher started');
  }

  void stopRebroadcastWatcher() {
    _rebroadcastTimer?.cancel();
    _rebroadcastTimer = null;
  }

  Future<void> _checkAndRebroadcast() async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(minutes: 5));
      final snap = await _db
          .collection('AgentJobs')
          .where('status', isEqualTo: 'pending')
          .where('agentId', isNull: true)
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final broadcastedAt = data['broadcastedAt'];
        if (broadcastedAt == null) continue;

        DateTime broadcastTime;
        try {
          broadcastTime = DateTime.parse(broadcastedAt.toString());
        } catch (_) {
          continue;
        }

        // Job has been pending for more than 5 minutes — rebroadcast
        if (broadcastTime.isBefore(cutoff)) {
          await _rebroadcastJob(doc.id, data);
        }
      }
    } catch (e) {
      logger.e('Rebroadcast check error: $e');
    }
  }

  Future<void> _rebroadcastJob(
      String jobId, Map<String, dynamic> jobData) async {
    try {
      final rebroadcastCount = (jobData['rebroadcastCount'] as int? ?? 0) + 1;

      // Update the job's broadcastedAt so the 5-min timer resets
      await _db.collection('AgentJobs').doc(jobId).update({
        'broadcastedAt': DateTime.now().toIso8601String(),
        'rebroadcastCount': rebroadcastCount,
      });

      // Notify all online agents again
      final agentsSnap = await _db
          .collection('Agents')
          .where('isApproved', isEqualTo: true)
          .where('isSuspended', isEqualTo: false)
          .where('status', whereIn: ['online', 'on_job'])
          .get();

      final booking = jobData['booking'] as Map<String, dynamic>?;
      final service = booking?['service'] as Map<String, dynamic>?;
      final location = booking?['locationName'] ?? 'your area';

      for (final agentDoc in agentsSnap.docs) {
        final notifId = 'notif_job_${jobId}_rb$rebroadcastCount';
        await _db
            .collection('Agents')
            .doc(agentDoc.id)
            .collection('Notifications')
            .doc(notifId)
            .set({
          'id': notifId,
          'title': '🔔 Job Still Available!',
          'body':
              '${service?['name'] ?? 'Cleaning'} job in $location is still waiting for an agent.',
          'type': 'job',
          'jobId': jobId,
          'createdAt': Timestamp.now(),
          'isRead': false,
        });
      }

      logger.i('Job $jobId rebroadcasted (attempt $rebroadcastCount)');
    } catch (e) {
      logger.e('Rebroadcast error for job $jobId: $e');
    }
  }

  // ── Accept a job — atomic transaction to prevent double-acceptance ────────
  Future<bool> acceptJob(String jobId, String agentId) async {
    try {
      bool accepted = false;
      await _db.runTransaction((tx) async {
        final jobRef = _db.collection('AgentJobs').doc(jobId);
        final snap = await tx.get(jobRef);
        if (!snap.exists) return;

        final data = snap.data()!;
        // Only accept if still pending and unassigned
        if (data['status'] == 'pending' && data['agentId'] == null) {
          tx.update(jobRef, {
            'status': 'accepted',
            'agentId': agentId,
            'assignedAt': DateTime.now().toIso8601String(),
          });
          accepted = true;
        }
      });
      return accepted;
    } catch (e) {
      logger.e('Accept job error: $e');
      return false;
    }
  }

  // ── Mark job as in progress ────────────────────────────────────────────────
  Future<bool> startJob(String jobId) async {
    try {
      await _db.collection('AgentJobs').doc(jobId).update({
        'status': 'in_progress',
        'startedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      logger.e('Start job error: $e');
      return false;
    }
  }

  // ── Complete job ───────────────────────────────────────────────────────────
  Future<bool> completeJob(String jobId) async {
    try {
      await _db.collection('AgentJobs').doc(jobId).update({
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      logger.e('Complete job error: $e');
      return false;
    }
  }
}
