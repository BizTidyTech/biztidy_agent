// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_controller/agent_auth_controller.dart';
import 'package:biztidy_agent_app/ui/shared/custom_button.dart';
import 'package:biztidy_agent_app/ui/shared/loading_widget.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AgentSignInView extends StatefulWidget {
  const AgentSignInView({super.key});

  @override
  State<AgentSignInView> createState() => _AgentSignInViewState();
}

class _AgentSignInViewState extends State<AgentSignInView> {
  // Use lazyPut so controller is only created when this screen is active
  AgentAuthController get controller => Get.find<AgentAuthController>();

  @override
  void initState() {
    super.initState();
    // Register lazily - only signin fields needed here
    if (!Get.isRegistered<AgentAuthController>()) {
      Get.lazyPut(() => AgentAuthController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.plainWhite,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: GetBuilder<AgentAuthController>(
          builder: (ctrl) {
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryThemeColor,
                      AppColors.kPrimaryColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        verticalSpacer(60),
                        // Premium BT monogram — white disc + teal letterform
                        // on the teal gradient background
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer hairline ring (white, translucent)
                            Container(
                              width: 116,
                              height: 116,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Inner hairline ring
                            Container(
                              width: 94,
                              height: 94,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.40),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Core white disc
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.plainWhite,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'BT',
                                  style: TextStyle(
                                    fontFamily: 'Audiowide',
                                    fontSize: 20,
                                    color: AppColors.primaryThemeColor,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            // Jewel accent dot
                            Positioned(
                              top: 18,
                              right: 18,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.kPrimaryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.kPrimaryColor
                                          .withValues(alpha: 0.8),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacer(16),
                        Text('BizTidy Agent',
                            style: AppStyles.keyStringStyle(
                                28, AppColors.plainWhite)),
                        verticalSpacer(6),
                        Text('Sign in to your agent account',
                            style: AppStyles.subStringStyle(
                                14, AppColors.plainWhite)),
                        verticalSpacer(48),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.plainWhite,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel('Email Address'),
                              _buildEmailField(ctrl),
                              verticalSpacer(16),
                              _inputLabel('Password'),
                              _buildPasswordField(ctrl),
                              verticalSpacer(8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => _showForgotPasswordDialog(
                                      context,
                                      ctrl.emailController.text.trim()),
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppStyles.subStringStyle(
                                            13, AppColors.primaryThemeColor)
                                        .copyWith(
                                            decoration:
                                                TextDecoration.underline),
                                  ),
                                ),
                              ),
                              verticalSpacer(16),
                              if (ctrl.errMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    ctrl.errMessage,
                                    style: AppStyles.subStringStyle(
                                        13, AppColors.coolRed),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ctrl.showLoading
                                  ? Center(child: loadingWidget())
                                  : CustomButton(
                                      buttonText: 'Sign In',
                                      width: screenWidth(context),
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        ctrl.attemptSignIn(context);
                                      },
                                    ),
                            ],
                          ),
                        ),
                        verticalSpacer(40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _inputLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: AppStyles.regularStringStyle(14, AppColors.fullBlack)),
      );

  Widget _buildEmailField(AgentAuthController ctrl) => TextField(
        controller: ctrl.emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          hintText: 'Enter your email',
          hintStyle: AppStyles.subStringStyle(14, AppColors.darkGray),
          filled: true,
          fillColor: AppColors.lighterGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _buildPasswordField(AgentAuthController ctrl) => TextField(
        controller: ctrl.passwordController,
        obscureText: ctrl.isObscured,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => ctrl.attemptSignIn(context),
        decoration: InputDecoration(
          hintText: 'Enter your password',
          hintStyle: AppStyles.subStringStyle(14, AppColors.darkGray),
          filled: true,
          fillColor: AppColors.lighterGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              ctrl.isObscured ? Icons.visibility_off : Icons.visibility,
              color: AppColors.darkGray,
            ),
            onPressed: ctrl.toggleObscure,
          ),
        ),
      );

  void _showForgotPasswordDialog(BuildContext context, String prefillEmail) {
    final emailCtrl = TextEditingController(text: prefillEmail);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset Password',
            style: AppStyles.keyStringStyle(17, AppColors.fullBlack)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email and we will send you a reset link.',
              style: AppStyles.subStringStyle(13, AppColors.darkGray),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Your email address',
                hintStyle: AppStyles.subStringStyle(13, AppColors.darkGray),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style:
                    AppStyles.regularStringStyle(14, AppColors.darkGray)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Reset link sent! Check your inbox.'),
                  backgroundColor: AppColors.normalGreen,
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Could not send reset email. Try again.'),
                  backgroundColor: AppColors.coolRed,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryThemeColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Send Link',
                style: AppStyles.regularStringStyle(
                    14, AppColors.plainWhite)),
          ),
        ],
      ),
    );
  }
}
