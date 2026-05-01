// ignore_for_file: use_build_context_synchronously
import 'package:biztidy_agent_app/app/helpers/agent_sharedprefs.dart';
import 'package:biztidy_agent_app/app/services/agent_firebase_service.dart';
import 'package:biztidy_agent_app/main.dart' show logger;
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_model/agent_model.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AgentProfileController extends GetxController {
  AgentModel? agentData;
  bool showLoading = false;

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final currentPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAgent();
  }

  Future<void> loadAgent() async {
    // Load from local cache only — home controller already refreshes from Firebase
    agentData = await getLocallySavedAgentDetails();
    update();
  }

  // ── Change Password ──────────────────────────────────────────────────────
  Future<void> changePassword(BuildContext context) async {
    final current = currentPasswordController.text.trim();
    final newPass  = newPasswordController.text.trim();
    final confirm  = confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      Fluttertoast.showToast(msg: 'All fields are required');
      return;
    }
    if (newPass != confirm) {
      Fluttertoast.showToast(msg: 'New passwords do not match');
      return;
    }
    if (newPass.length < 6) {
      Fluttertoast.showToast(msg: 'Password must be at least 6 characters');
      return;
    }

    showLoading = true; update();
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: current);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);
      // Update in Firestore too
      await FirebaseFirestore.instance
          .collection('Agents')
          .doc(agentData!.agentId)
          .update({'password': newPass});
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Password changed successfully!',
          backgroundColor: AppColors.normalGreen);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'Current password is incorrect');
      } else {
        Fluttertoast.showToast(msg: 'Error: ${e.message}');
      }
    }
    showLoading = false; update();
  }

  // ── Delete Account ───────────────────────────────────────────────────────
  Future<void> deleteAccount(BuildContext context, String password) async {
    showLoading = true; update();
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);

      // Delete Firestore document
      if (agentData?.agentId != null) {
        await FirebaseFirestore.instance
            .collection('Agents')
            .doc(agentData!.agentId)
            .delete();
      }
      // Delete Firebase Auth account
      await user.delete();
      await clearAgentDetailsLocally();
      context.go('/');
      Fluttertoast.showToast(msg: 'Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'Incorrect password');
      } else {
        Fluttertoast.showToast(msg: 'Error: ${e.message}');
      }
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: 'Failed to delete account. Try again.');
    }
    showLoading = false; update();
  }


  // ── Forgot / Reset Password (sends email) ───────────────────────────────
  Future<void> sendPasswordResetEmail(BuildContext context, String email) async {
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your email address');
      return;
    }
    showLoading = true; update();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Password reset email sent! Check your inbox.',
          backgroundColor: AppColors.normalGreen,
          toastLength: Toast.LENGTH_LONG);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: 'No account found with this email.');
      } else {
        Fluttertoast.showToast(msg: 'Error: \${e.message}');
      }
    }
    showLoading = false; update();
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────
  Future<void> signOut(BuildContext context) async {
    if (agentData?.agentId != null) {
      await AgentFirebaseService()
          .updateAgentStatus(agentData!.agentId!, 'offline');
    }
    await FirebaseAuth.instance.signOut();
    await clearAgentDetailsLocally();
    context.go('/');
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    currentPasswordController.dispose();
    super.onClose();
  }
}
