// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:biztidy_agent_app/app/helpers/agent_sharedprefs.dart';
import 'package:biztidy_agent_app/app/services/agent_firebase_service.dart';
import 'package:biztidy_agent_app/main.dart' show logger;
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_model/agent_model.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// ── Sign-In Controller ───────────────────────────────────────────────────────
class AgentAuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool showLoading = false;
  bool isObscured = true;
  String errMessage = '';

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscure() { isObscured = !isObscured; update(); }

  Future<void> attemptSignIn(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      errMessage = 'Email and password are required';
      update(); return;
    }
    showLoading = true; errMessage = ''; update();
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;

      final agent = await AgentFirebaseService().getAgentById(user.uid);
      if (agent == null) {
        errMessage = 'Agent profile not found. Contact support.';
        showLoading = false; update(); return;
      }

      // Email not yet verified — send a fresh OTP and redirect
      if (agent.emailVerified != true) {
        showLoading = false; update();
        await AgentOtpController.sendOtp(email: email);
        context.go('/agentVerifyEmailScreen');
        return;
      }

      await saveAgentDetailsLocally(agent);
      showLoading = false; update();

      if (agent.isApproved != true) {
        context.go('/agentPendingApprovalScreen');
        return;
      }

      Fluttertoast.showToast(
          msg: 'Welcome back, ${agent.name?.split(' ').first ?? 'Agent'}!',
          backgroundColor: AppColors.normalGreen);
      context.go('/agentHomeScreen');
    } on FirebaseAuthException catch (e) {
      errMessage = (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found')
          ? 'Incorrect email or password.'
          : e.code == 'too-many-requests'
          ? 'Too many attempts. Please wait.'
          : 'Sign in failed. Please retry.';
      showLoading = false; update();
    } catch (e) {
      errMessage = 'Something went wrong. Please try again.';
      showLoading = false; update();
    }
  }

  Future<void> signOut(BuildContext context) async {
    final agent = await getLocallySavedAgentDetails();
    if (agent?.agentId != null) {
      await AgentFirebaseService().updateAgentStatus(agent!.agentId!, 'offline');
    }
    await FirebaseAuth.instance.signOut();
    await clearAgentDetailsLocally();
    context.go('/');
  }
}

// ── OTP Controller ───────────────────────────────────────────────────────────
class AgentOtpController extends GetxController {
  bool isVerifying = false;
  bool isResending = false;
  String errMessage = '';

  /// Sends a 6-digit OTP to [email] using the email_otp package (same SMTP
  /// config as the customer app — no Cloud Function needed).
  static Future<void> sendOtp({required String email}) async {
    final sent = await EmailOTP.sendOTP(email: email);
    if (sent != true) {
      logger.e('EmailOTP.sendOTP failed for $email');
    }
  }

  Future<void> verifyOtp({
    required BuildContext context,
    required String otp,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { context.go('/'); return; }

    isVerifying = true; errMessage = ''; update();

    // Verify against the in-memory OTP managed by email_otp package
    final ok = EmailOTP.verifyOTP(otp: otp);
    if (ok != true) {
      errMessage = 'Incorrect or expired OTP. Please try again.';
      isVerifying = false; update(); return;
    }

    // Persist verified state to Firestore so splash screen knows next launch
    await AgentFirebaseService().markEmailVerified(user.uid);

    final agent = await AgentFirebaseService().getAgentById(user.uid);
    if (agent != null) await saveAgentDetailsLocally(agent);

    isVerifying = false; update();
    Fluttertoast.showToast(
        msg: 'Email verified successfully!',
        backgroundColor: AppColors.normalGreen);
    context.go('/agentPendingApprovalScreen');
  }

  Future<void> resendOtp(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isResending = true; update();
    await sendOtp(email: user.email ?? '');
    Fluttertoast.showToast(
        msg: 'New OTP sent to your email!',
        backgroundColor: AppColors.normalGreen);
    isResending = false; update();
  }
}

// ── Signup Controller ─────────────────────────────────────────────────────────
class AgentSignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final addressController = TextEditingController();

  File? passportPhoto;
  File? idDocument;
  String selectedIdType = 'NIN';
  final List<String> idTypes = ['NIN', "Voter's Card", 'International Passport'];

  bool showLoading = false;
  bool isObscured = true;
  String errMessage = '';

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void toggleObscure() { isObscured = !isObscured; update(); }
  void setIdType(String type) { selectedIdType = type; update(); }

  void resetValues() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    addressController.clear();
    passportPhoto = null;
    idDocument = null;
    selectedIdType = 'NIN';
    isObscured = true;
    errMessage = '';
    showLoading = false;
    update();
  }

  Future<void> pickPassportPhoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) { passportPhoto = File(picked.path); update(); }
  }

  Future<void> pickIdDocument() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) { idDocument = File(picked.path); update(); }
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance
          .refFromURL('gs://tidytech-app.firebasestorage.app')
          .child(path);
      final task = await ref.putFile(file);
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      logger.e('Storage error: ${e.code}');
      Fluttertoast.showToast(msg: 'Upload error: ${e.message}');
      return null;
    }
  }

  Future<void> attemptSignUp(BuildContext context) async {
    final name     = nameController.text.trim();
    final email    = emailController.text.trim();
    final phone    = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirm  = confirmPasswordController.text.trim();
    final address  = addressController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty ||
        address.isEmpty || password.isEmpty || confirm.isEmpty) {
      errMessage = 'All fields are required'; update(); return;
    }
    if (passportPhoto == null) {
      errMessage = 'Please upload your passport photo'; update(); return;
    }
    if (idDocument == null) {
      errMessage = 'Please upload your ID document'; update(); return;
    }
    if (password != confirm) {
      errMessage = 'Passwords do not match'; update(); return;
    }
    if (password.length < 6) {
      errMessage = 'Password must be at least 6 characters'; update(); return;
    }

    showLoading = true; errMessage = ''; update();

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final agentId = credential.user!.uid;

      Fluttertoast.showToast(msg: 'Uploading documents...');
      final photoUrl = await _uploadFile(
          passportPhoto!, 'agent_photos/$agentId/passport.jpg');
      final idUrl = await _uploadFile(
          idDocument!, 'agent_photos/$agentId/id_document.jpg');

      if (photoUrl == null || idUrl == null) {
        errMessage = 'File upload failed. Check your connection and retry.';
        showLoading = false; update(); return;
      }

      final newAgent = AgentModel(
        agentId: agentId,
        name: name,
        email: email,
        password: password,
        phoneNumber: phone,
        address: address,
        photoUrl: photoUrl,
        idDocumentUrl: idUrl,
        idDocumentType: selectedIdType,
        status: 'offline',
        rating: 0.0,
        totalJobsCompleted: 0,
        totalEarnings: 0.0,
        isApproved: false,
        emailVerified: false,
        timeCreated: DateTime.now(),
      );

      final success = await AgentFirebaseService().registerAgent(newAgent);
      if (success) {
        await saveAgentDetailsLocally(newAgent);

        // Send OTP via email_otp package (same as customer app)
        await AgentOtpController.sendOtp(email: email);

        showLoading = false; update();
        context.go('/agentVerifyEmailScreen');
      } else {
        errMessage = 'Registration failed. Please try again.';
        showLoading = false; update();
      }
    } on FirebaseAuthException catch (e) {
      errMessage = e.code == 'email-already-in-use'
          ? 'This email is already registered. Please sign in.'
          : e.code == 'invalid-email'
          ? 'Please enter a valid email address.'
          : 'Account creation failed: ${e.message}';
      showLoading = false; update();
    }
  }
}