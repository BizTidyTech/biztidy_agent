// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:biztidy_agent_app/app/helpers/agent_sharedprefs.dart';
import 'package:biztidy_agent_app/app/services/agent_firebase_service.dart';
import 'package:biztidy_agent_app/app/services/job_dispatch_service.dart';
import 'package:biztidy_agent_app/main.dart' show logger;
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_model/agent_model.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_jobs/agent_jobs_model/agent_job_model.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AgentHomeController extends GetxController {
  AgentModel? agentData;
  List<AgentJobModel> allJobs = [];
  StreamSubscription? _jobsSubscription;

  // Cached filtered lists — computed once when allJobs changes,
  // not on every widget access. Previously each getter scanned allJobs
  // on every call, meaning 6+ full list scans per rebuild.
  List<AgentJobModel> pendingJobs = [];
  List<AgentJobModel> activeJobs = [];
  List<AgentJobModel> completedJobs = [];

  bool showLoading = false;
  String errMessage = '';

  @override
  void onInit() {
    super.onInit();
    loadAgentData();
  }

  @override
  void onClose() {
    _jobsSubscription?.cancel();
    JobDispatchService().stopRebroadcastWatcher();
    super.onClose();
  }

  Future<void> loadAgentData() async {
    showLoading = true;
    update();

    // Load from local storage FIRST — shows UI immediately
    agentData = await getLocallySavedAgentDetails();
    if (agentData?.agentId != null) {
      // Ensure agent is online whenever they reach the home screen
      if (agentData!.status != 'online' && agentData!.status != 'on_job') {
        agentData = agentData!.copyWith(status: 'online');
        await saveAgentDetailsLocally(agentData!);
        await AgentFirebaseService()
            .updateAgentStatus(agentData!.agentId!, 'online');
      }
      showLoading = false;
      update(); // Show UI right away with cached data

      // Then refresh from Firebase in the background
      _listenToJobs();
      _refreshFromFirebase();
      _startDispatchWatcher();
    } else {
      showLoading = false;
      update();
    }
  }

  // Refresh agent profile in background without blocking UI
  Future<void> _refreshFromFirebase() async {
    try {
      final fresh = await AgentFirebaseService().getAgentById(agentData!.agentId!);
      if (fresh != null) {
        agentData = fresh;
        await saveAgentDetailsLocally(fresh);
        update(['header']); // Only header card needs to know about agentData refresh
      }
    } catch (e) {
      logger.e('Background refresh error: $e');
    }
  }

  /// Public version — call after saving bank details, profile edits, etc.
  /// so the Earnings view picks up changes immediately without a restart.
  Future<void> refreshAgentData() async {
    if (agentData?.agentId == null) return;
    try {
      final fresh =
      await AgentFirebaseService().getAgentById(agentData!.agentId!);
      if (fresh != null) {
        agentData = fresh;
        await saveAgentDetailsLocally(fresh);
        update(['header', 'jobs']); // refresh header stats + earnings view
      }
    } catch (e) {
      logger.e('refreshAgentData error: $e');
    }
  }

  void _startDispatchWatcher() {
    // Only watch for rebroadcast when agent is online
    if (isOnline) {
      JobDispatchService().startRebroadcastWatcher();
    } else {
      JobDispatchService().stopRebroadcastWatcher();
    }
  }

  void _listenToJobs() {
    _jobsSubscription?.cancel();
    _jobsSubscription = AgentFirebaseService()
        .listenToAgentJobs(agentData!.agentId!)
        .listen((jobs) {
      allJobs = jobs;
      // Compute filtered lists ONCE here, not on every widget getter call
      pendingJobs   = jobs.where((j) => j.status == 'pending' && j.agentId == null).toList();
      activeJobs    = jobs.where((j) => (j.status == 'in_progress' || j.status == 'accepted') && j.agentId == agentData?.agentId).toList();
      completedJobs = jobs.where((j) => j.status == 'completed' && j.agentId == agentData?.agentId).toList();
      update(['jobs']);
    });
  }

  bool get isOnline =>
      agentData?.status == 'online' || agentData?.status == 'on_job';

  Future<void> toggleOnlineStatus() async {
    if (agentData == null) return;
    final newStatus = isOnline ? 'offline' : 'online';
    agentData = agentData!.copyWith(status: newStatus);
    update(['header']); // Only the header card shows online status
    final success = await AgentFirebaseService()
        .updateAgentStatus(agentData!.agentId!, newStatus);
    if (success) {
      await saveAgentDetailsLocally(agentData!);
      _startDispatchWatcher();
      Fluttertoast.showToast(
        msg: isOnline ? 'You are now Online' : 'You are now Offline',
      );
    } else {
      agentData = agentData!.copyWith(
          status: newStatus == 'online' ? 'offline' : 'online');
      update(['header']);
    }
  }

  Future<void> acceptJob(AgentJobModel job) async {
    if (agentData?.agentId == null || job.jobId == null) return;
    // Atomic transaction — prevents two agents accepting the same job
    final accepted = await JobDispatchService().acceptJob(
        job.jobId!, agentData!.agentId!);
    if (accepted) {
      logger.i('Job accepted: ${job.jobId}');
      Fluttertoast.showToast(
        msg: 'Job accepted! Check your Active Jobs tab.',
        backgroundColor: AppColors.normalGreen,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Sorry, this job was just taken by another agent.',
        backgroundColor: AppColors.coolRed,
      );
    }
  }

  Future<void> declineJob(AgentJobModel job) async {
    final updated = job.copyWith(status: 'cancelled');
    await AgentFirebaseService().updateAgentJob(updated);
  }

  Future<void> signOut(BuildContext context) async {
    if (agentData?.agentId != null) {
      await AgentFirebaseService()
          .updateAgentStatus(agentData!.agentId!, 'offline');
    }
    await FirebaseAuth.instance.signOut();
    await clearAgentDetailsLocally();
    context.go('/');
  }
}