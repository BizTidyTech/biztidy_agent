// ignore_for_file: prefer_const_constructors
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_controller/agent_auth_controller.dart';
import 'package:biztidy_agent_app/ui/shared/custom_button.dart';
import 'package:biztidy_agent_app/ui/shared/loading_widget.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AgentCreateAccountView extends StatefulWidget {
  const AgentCreateAccountView({super.key});

  @override
  State<AgentCreateAccountView> createState() => _AgentCreateAccountViewState();
}

class _AgentCreateAccountViewState extends State<AgentCreateAccountView> {
  final controller = Get.put(AgentSignupController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.plainWhite,
      ),
      child: GestureDetector(
        onTap: () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
        child: GetBuilder<AgentSignupController>(
          builder: (_) {
            return Scaffold(
              backgroundColor: AppColors.plainWhite,
              appBar: AppBar(
                backgroundColor: AppColors.primaryThemeColor,
                iconTheme: IconThemeData(color: AppColors.plainWhite),
                title: Text('Agent Application',
                    style: AppStyles.keyStringStyle(18, AppColors.plainWhite)),
                elevation: 0,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpacer(10),
                    Text('Create Your Agent Account',
                        style: AppStyles.keyStringStyle(20, AppColors.fullBlack)),
                    verticalSpacer(6),
                    Text(
                      'Fill in your details below. Your application will be reviewed and approved before you can start receiving jobs.',
                      style: AppStyles.subStringStyle(13, AppColors.darkGray),
                    ),
                    verticalSpacer(24),

                    // ── Passport Photo ──────────────────────────────────────
                    _sectionHeader('Passport Photo', required: true),
                    verticalSpacer(10),
                    _photoUploadBox(
                      file: controller.passportPhoto,
                      placeholder: 'Tap to upload a clear\nfacial photo',
                      icon: Icons.person,
                      onTap: controller.pickPassportPhoto,
                      isPicking: controller.isPickingPassport,
                    ),
                    verticalSpacer(20),

                    // ── Personal Info ───────────────────────────────────────
                    _sectionHeader('Personal Information', required: false),
                    verticalSpacer(10),
                    _label('Full Name *'),
                    _field(controller.nameController, 'Enter your full name'),
                    verticalSpacer(14),
                    _label('Email Address *'),
                    _field(controller.emailController, 'Enter your email',
                        type: TextInputType.emailAddress),
                    verticalSpacer(14),
                    _label('Phone Number *'),
                    _field(controller.phoneController, 'e.g. +2348012345678',
                        type: TextInputType.phone),
                    verticalSpacer(14),
                    _label('Home Address *'),
                    _field(controller.addressController,
                        'Enter your full home address'),
                    verticalSpacer(20),

                    // ── ID Document ─────────────────────────────────────────
                    _sectionHeader('Means of Identification', required: true),
                    verticalSpacer(10),
                    _label('ID Type *'),
                    _idTypeDropdown(),
                    verticalSpacer(14),
                    _label('Upload ${controller.selectedIdType} *'),
                    _photoUploadBox(
                      file: controller.idDocument,
                      placeholder: 'Tap to upload a clear\nphoto of your ${controller.selectedIdType}',
                      icon: Icons.credit_card,
                      onTap: controller.pickIdDocument,
                      isWide: true,
                      isPicking: controller.isPickingId,
                    ),
                    verticalSpacer(20),

                    // ── Password ────────────────────────────────────────────
                    _sectionHeader('Security', required: false),
                    verticalSpacer(10),
                    _label('Password *'),
                    _passwordField(
                      ctrl: controller.passwordController,
                      hint: 'Create a password (min. 6 characters)',
                      isObscured: controller.isObscured,
                      onToggle: controller.toggleObscure,
                    ),
                    verticalSpacer(14),
                    _label('Confirm Password *'),
                    _passwordField(
                      ctrl: controller.confirmPasswordController,
                      hint: 'Confirm your password',
                      isObscured: true,
                      onToggle: () {},
                      showToggle: false,
                    ),
                    verticalSpacer(20),

                    // ── Error ───────────────────────────────────────────────
                    if (controller.errMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.coolRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.coolRed.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          controller.errMessage,
                          style: AppStyles.subStringStyle(13, AppColors.coolRed),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // ── Submit ──────────────────────────────────────────────
                    controller.showLoading
                        ? Center(child: loadingWidget())
                        : CustomButton(
                            buttonText: 'Submit Application',
                            width: screenWidth(context),
                            onPressed: () {
                              SystemChannels.textInput.invokeMethod('TextInput.hide');
                              controller.attemptSignUp(context);
                            },
                          ),
                    verticalSpacer(16),
                    Center(
                      child: RichText(
                        textScaler: const TextScaler.linear(1),
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: AppStyles.subStringStyle(14, AppColors.fullBlack),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: AppStyles.regularStringStyle(
                                  14, AppColors.primaryThemeColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  controller.resetValues();
                                  context.pushReplacement('/agentSignInView');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
                  ],
                ),
              ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {required bool required}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryThemeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(title,
            style: AppStyles.keyStringStyle(13, AppColors.primaryThemeColor)),
      );

  Widget _photoUploadBox({
    required dynamic file,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
    bool isWide = false,
    bool isPicking = false,
  }) {
    final hasFile = file != null;
    final boxHeight = MediaQuery.of(context).size.height * 0.19;
    return GestureDetector(
      onTap: isPicking ? null : onTap, // block taps while picker is open
      child: Container(
        width: isWide ? double.infinity : boxHeight,
        height: boxHeight,
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.primaryThemeColor.withValues(alpha: 0.05)
              : AppColors.lighterGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile
                ? AppColors.primaryThemeColor
                : AppColors.darkGray.withValues(alpha: 0.3),
            width: hasFile ? 2 : 1,
          ),
        ),
        child: isPicking
            // ── Loading state while gallery is opening ──────────────────
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primaryThemeColor,
                    strokeWidth: 2.5,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Opening gallery...',
                    style: AppStyles.subStringStyle(12, AppColors.darkGray),
                  ),
                ],
              )
            : hasFile
                // ── Image selected — show it with a "Tap to change" overlay ─
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(file!, fit: BoxFit.cover),
                      ),
                      // Semi-transparent bottom bar so agent knows they can tap
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(11)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            color: Colors.black54,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.edit,
                                    size: 13, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  'Tap to change',
                                  style: AppStyles.subStringStyle(
                                      12, Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                // ── Empty — show upload prompt ──────────────────────────────
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon,
                              size: 36,
                              color: AppColors.darkGray.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text(
                            placeholder,
                            style:
                                AppStyles.subStringStyle(12, AppColors.darkGray),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryThemeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Choose Photo',
                                style: AppStyles.subStringStyle(
                                    11, AppColors.plainWhite)),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _idTypeDropdown() => Container(
        decoration: BoxDecoration(
          color: AppColors.lighterGray,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedIdType,
            isExpanded: true,
            style: AppStyles.regularStringStyle(14, AppColors.fullBlack),
            items: controller.idTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) {
              if (val != null) controller.setIdType(val);
            },
          ),
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: AppStyles.regularStringStyle(14, AppColors.fullBlack)),
      );

  Widget _field(TextEditingController ctrl, String hint,
          {TextInputType? type}) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppStyles.subStringStyle(14, AppColors.darkGray),
          filled: true,
          fillColor: AppColors.lighterGray,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _passwordField({
    required TextEditingController ctrl,
    required String hint,
    required bool isObscured,
    required VoidCallback onToggle,
    bool showToggle = true,
  }) =>
      TextField(
        controller: ctrl,
        obscureText: isObscured,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppStyles.subStringStyle(14, AppColors.darkGray),
          filled: true,
          fillColor: AppColors.lighterGray,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: showToggle
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.darkGray,
                  ),
                  onPressed: onToggle,
                )
              : null,
        ),
      );
}
