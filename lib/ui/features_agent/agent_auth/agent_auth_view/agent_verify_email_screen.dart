// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_controller/agent_auth_controller.dart';
import 'package:biztidy_agent_app/ui/shared/custom_button.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AgentVerifyEmailScreen extends StatefulWidget {
  const AgentVerifyEmailScreen({super.key});

  @override
  State<AgentVerifyEmailScreen> createState() => _AgentVerifyEmailScreenState();
}

class _AgentVerifyEmailScreenState extends State<AgentVerifyEmailScreen> {
  final controller = Get.put(AgentAuthController());
  Timer? _timer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Auto-check every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _autoCheck());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _autoCheck() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final verified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    if (verified && mounted) {
      _timer?.cancel();
      context.go('/agentPendingApprovalScreen');
    }
  }

  Future<void> _manualCheck() async {
    setState(() => _checking = true);
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final verified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    if (verified && mounted) {
      context.go('/agentPendingApprovalScreen');
    } else {
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email not yet verified. Check your inbox.',
              style: AppStyles.subStringStyle(13, AppColors.plainWhite)),
          backgroundColor: AppColors.coolRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryThemeColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.plainWhite,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                // Icon
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.primaryThemeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_rounded,
                    size: 56,
                    color: AppColors.primaryThemeColor,
                  ),
                ),
                verticalSpacer(28),
                Text(
                  'Verify Your Email',
                  style: AppStyles.keyStringStyle(24, AppColors.fullBlack),
                  textAlign: TextAlign.center,
                ),
                verticalSpacer(14),
                Text(
                  'We\'ve sent a verification link to',
                  style: AppStyles.subStringStyle(15, AppColors.darkGray),
                  textAlign: TextAlign.center,
                ),
                verticalSpacer(6),
                Text(
                  email,
                  style: AppStyles.regularStringStyle(
                      15, AppColors.primaryThemeColor),
                  textAlign: TextAlign.center,
                ),
                verticalSpacer(10),
                Text(
                  'Please check your inbox (and spam folder) and click the link to verify your email before continuing.',
                  style: AppStyles.subStringStyle(14, AppColors.darkGray),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Auto-checking indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryThemeColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Checking automatically...',
                      style: AppStyles.subStringStyle(13, AppColors.darkGray),
                    ),
                  ],
                ),
                verticalSpacer(20),
                _checking
                    ? CircularProgressIndicator(
                        color: AppColors.primaryThemeColor)
                    : CustomButton(
                        buttonText: 'I\'ve Verified My Email',
                        width: screenWidth(context),
                        onPressed: _manualCheck,
                      ),
                verticalSpacer(14),
                CustomButton(
                  buttonText: 'Resend Verification Email',
                  width: screenWidth(context),
                  color: AppColors.plainWhite,
                  borderColor: AppColors.primaryThemeColor,
                  textcolor: AppColors.primaryThemeColor,
                  onPressed: controller.resendVerificationEmail,
                ),
                verticalSpacer(14),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    context.go('/');
                  },
                  child: Text(
                    'Use a different email',
                    style: AppStyles.subStringStyle(14, AppColors.darkGray),
                  ),
                ),
                verticalSpacer(10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
