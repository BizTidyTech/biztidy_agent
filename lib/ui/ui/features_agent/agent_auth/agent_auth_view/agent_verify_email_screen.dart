// ignore_for_file: use_build_context_synchronously
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
  final _otpController = Get.put(AgentOtpController());

  // 6 individual controllers + focus nodes
  final List<TextEditingController> _cells =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _cells) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _enteredOtp => _cells.map((c) => c.text).join();

  void _onCellChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Support paste: if someone pastes 6 digits into the first box
    if (value.length == 6 && index == 0) {
      for (int i = 0; i < 6; i++) {
        _cells[i].text = value[i];
      }
      _focusNodes[5].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _cells[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _cells[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final otp = _enteredOtp;
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter the complete 6-digit OTP.',
            style: AppStyles.subStringStyle(13, AppColors.plainWhite)),
        backgroundColor: AppColors.coolRed,
      ));
      return;
    }
    await _otpController.verifyOtp(context: context, otp: otp);
    // Show error from controller if any
    if (_otpController.errMessage.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_otpController.errMessage,
            style: AppStyles.subStringStyle(13, AppColors.plainWhite)),
        backgroundColor: AppColors.coolRed,
      ));
      // Clear the cells so the agent can try again
      for (final c in _cells) c.clear();
      _focusNodes[0].requestFocus();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GetBuilder<AgentOtpController>(
              builder: (ctrl) => Column(
                children: [
                  verticalSpacer(24),

                  // ── Icon ──────────────────────────────────────────────────
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

                  // ── Title ─────────────────────────────────────────────────
                  Text(
                    'Verify Your Email',
                    style: AppStyles.keyStringStyle(24, AppColors.fullBlack),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpacer(14),
                  Text(
                    'We\'ve sent a 6-digit verification code to',
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
                  verticalSpacer(6),
                  Text(
                    'Enter the code below to continue.',
                    style: AppStyles.subStringStyle(14, AppColors.darkGray),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpacer(36),

                  // ── OTP boxes ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _OtpCell(
                          controller: _cells[i],
                          focusNode: _focusNodes[i],
                          onChanged: (v) => _onCellChanged(v, i),
                          onKeyEvent: (e) => _onKeyEvent(e, i),
                        ),
                      );
                    }),
                  ),
                  verticalSpacer(36),

                  // ── Verify button ─────────────────────────────────────────
                  ctrl.isVerifying
                      ? CircularProgressIndicator(
                      color: AppColors.primaryThemeColor)
                      : CustomButton(
                    buttonText: 'Verify Email',
                    width: screenWidth(context),
                    onPressed: _submit,
                  ),
                  verticalSpacer(14),

                  // ── Resend ────────────────────────────────────────────────
                  ctrl.isResending
                      ? Row(
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
                        'Sending new code...',
                        style: AppStyles.subStringStyle(
                            13, AppColors.darkGray),
                      ),
                    ],
                  )
                      : CustomButton(
                    buttonText: 'Resend Code',
                    width: screenWidth(context),
                    color: AppColors.plainWhite,
                    borderColor: AppColors.primaryThemeColor,
                    textcolor: AppColors.primaryThemeColor,
                    onPressed: () => ctrl.resendOtp(context),
                  ),
                  verticalSpacer(14),

                  // ── Use different email ───────────────────────────────────
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
      ),
    );
  }
}

// ── Single OTP digit cell ────────────────────────────────────────────────────
class _OtpCell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 46,
        height: 56,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: AppStyles.keyStringStyle(22, AppColors.fullBlack),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: AppColors.primaryThemeColor.withValues(alpha: 0.06),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryThemeColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryThemeColor,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}