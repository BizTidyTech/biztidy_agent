import 'package:biztidy_agent_app/main.dart' show logger;
// ignore_for_file: use_build_context_synchronously

import 'package:biztidy_agent_app/app/helpers/agent_sharedprefs.dart';
import 'package:biztidy_agent_app/app/services/agent_firebase_service.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_jobs/agent_jobs_model/agent_job_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AgentJobsController extends GetxController {
  AgentJobModel? selectedJob;
  bool showLoading = false;

  final ImagePicker _picker = ImagePicker();

  List<String> beforePhotoUrls = [];
  List<String> afterPhotoUrls = [];
  List<String> beforeVideoUrls = [];
  List<String> afterVideoUrls = [];
  bool uploadingPhotos = false;

  void selectJob(AgentJobModel job) {
    selectedJob = job;
    beforePhotoUrls = List.from(job.beforePhotoUrls ?? []);
    afterPhotoUrls = List.from(job.afterPhotoUrls ?? []);
    beforeVideoUrls = List.from(job.beforeVideoUrls ?? []);
    afterVideoUrls = List.from(job.afterVideoUrls ?? []);
    update();
  }

  void startLoading() { showLoading = true; update(); }
  void stopLoading() { showLoading = false; update(); }

  // ── Start job (clock in) ───────────────────────────────────────────────────
  Future<void> startJob() async {
    if (selectedJob == null) return;
    startLoading();
    final updated = selectedJob!.copyWith(
      status: 'in_progress',
      startedAt: DateTime.now(),
    );
    final success = await AgentFirebaseService().updateAgentJob(updated);
    if (success) {
      selectedJob = updated;
      final agent = await getLocallySavedAgentDetails();
      if (agent?.agentId != null) {
        await AgentFirebaseService()
            .updateAgentStatus(agent!.agentId!, 'on_job');
      }
      Fluttertoast.showToast(msg: 'Job started! Upload before photos.');
    }
    stopLoading();
  }

  // ── Photo upload ───────────────────────────────────────────────────────────
  Future<void> pickAndUploadPhoto({required bool isBefore}) async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.camera, imageQuality: 70);
      if (image == null) return;

      uploadingPhotos = true;
      update();

      final fileName =
          '${isBefore ? 'before' : 'after'}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('job_photos')
          .child(selectedJob!.jobId!)
          .child(fileName);

      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      if (isBefore) {
        beforePhotoUrls.add(url);
        await AgentFirebaseService().uploadJobPhotos(
          jobId: selectedJob!.jobId!,
          photoUrls: beforePhotoUrls,
          isBefore: true,
        );
        selectedJob = selectedJob!.copyWith(beforePhotoUrls: beforePhotoUrls);
      } else {
        afterPhotoUrls.add(url);
        await AgentFirebaseService().uploadJobPhotos(
          jobId: selectedJob!.jobId!,
          photoUrls: afterPhotoUrls,
          isBefore: false,
        );
        selectedJob = selectedJob!.copyWith(afterPhotoUrls: afterPhotoUrls);
      }

      Fluttertoast.showToast(msg: 'Photo uploaded successfully');
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: 'Error uploading photo. Retry.');
    }
    uploadingPhotos = false;
    update();
  }

  // ── Video upload (max 60 seconds) ──────────────────────────────────────────
  Future<void> pickAndUploadVideo({required bool isBefore}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 60),
      );
      if (video == null) return;

      uploadingPhotos = true; // reuse same loading flag
      update();

      final fileName =
          '${isBefore ? 'before' : 'after'}_vid_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ref = FirebaseStorage.instance
          .ref()
          .child('job_videos')
          .child(selectedJob!.jobId!)
          .child(fileName);

      await ref.putFile(
        File(video.path),
        SettableMetadata(contentType: 'video/mp4'),
      );
      final url = await ref.getDownloadURL();

      if (isBefore) {
        beforeVideoUrls.add(url);
        await AgentFirebaseService().uploadJobVideos(
          jobId: selectedJob!.jobId!,
          videoUrls: beforeVideoUrls,
          isBefore: true,
        );
        selectedJob = selectedJob!.copyWith(beforeVideoUrls: beforeVideoUrls);
      } else {
        afterVideoUrls.add(url);
        await AgentFirebaseService().uploadJobVideos(
          jobId: selectedJob!.jobId!,
          videoUrls: afterVideoUrls,
          isBefore: false,
        );
        selectedJob = selectedJob!.copyWith(afterVideoUrls: afterVideoUrls);
      }

      Fluttertoast.showToast(msg: 'Video uploaded successfully');
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: 'Error uploading video. Retry.');
    }
    uploadingPhotos = false;
    update();
  }

  // ── Complete job (clock out) ───────────────────────────────────────────────
  Future<void> completeJob(BuildContext context) async {
    if (selectedJob == null) return;

    if (afterPhotoUrls.isEmpty && afterVideoUrls.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please upload at least one after photo or video',
        backgroundColor: Colors.orange,
      );
      return;
    }

    startLoading();
    final updated = selectedJob!.copyWith(
      status: 'completed',
      completedAt: DateTime.now(),
      afterPhotoUrls: afterPhotoUrls,
      afterVideoUrls: afterVideoUrls,
    );
    final success = await AgentFirebaseService().updateAgentJob(updated);
    if (success) {
      selectedJob = updated;
      final agent = await getLocallySavedAgentDetails();
      if (agent?.agentId != null) {
        await AgentFirebaseService()
            .updateAgentStatus(agent!.agentId!, 'online');
      }
      Fluttertoast.showToast(
        msg: 'Job completed! Great work.',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    }
    stopLoading();
  }
}
