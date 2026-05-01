// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:biztidy_agent_app/ui/features_agent/agent_profile/agent_profile_controller/agent_profile_controller.dart';
import 'package:biztidy_agent_app/ui/shared/loading_widget.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

final _profileCardShadow = [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))];

class AgentProfileScreen extends StatefulWidget {
  const AgentProfileScreen({super.key});

  @override
  State<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  late final AgentProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AgentProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryThemeColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: GetBuilder<AgentProfileController>(
        builder: (_) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: controller.showLoading
                ? loadingWidget()
                : Column(
                    children: [
                      _staticHeader(context, controller),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                              // ── Account ──────────────────────────────────
                              _sectionLabel('Account'),
                              _card([
                                _tile(
                                  icon: Icons.lock_outline,
                                  title: 'Change Password',
                                  onTap: () => _showChangePasswordSheet(context, controller),
                                ),
                                _divider(),
                                _tile(
                                  icon: Icons.lock_reset_outlined,
                                  title: 'Forgot Password',
                                  subtitle: 'Send a reset link to your email',
                                  onTap: () => _showForgotPasswordSheet(context, controller),
                                ),
                              ]),
                              verticalSpacer(16),

                              // ── Help Center ──────────────────────────────
                              _sectionLabel('Help Center'),
                              _card([
                                _tile(
                                  icon: Icons.email_outlined,
                                  title: 'Email Us',
                                  subtitle: 'tidy1tech@gmail.com',
                                  onTap: () => _launch('mailto:tidy1tech@gmail.com'),
                                ),
                                _divider(),
                                _tile(
                                  icon: Icons.chat_outlined,
                                  iconColor: const Color(0xFF25D366),
                                  title: 'WhatsApp',
                                  subtitle: 'Chat with us on WhatsApp',
                                  onTap: () => _launch('https://wa.me/2348023179676'),
                                ),
                                _divider(),
                                _tile(
                                  icon: Icons.phone_outlined,
                                  iconColor: AppColors.primaryThemeColor,
                                  title: 'Call Us',
                                  subtitle: '+234 802 317 9676',
                                  onTap: () => _launch('tel:+2348023179676'),
                                ),
                              ]),
                              verticalSpacer(16),

                              // ── Legal ─────────────────────────────────────
                              _sectionLabel('Legal & Info'),
                              _card([
                                _tile(
                                  icon: Icons.info_outline,
                                  title: 'About Us',
                                  onTap: () => _showInfoSheet(context,
                                      title: 'About Us',
                                      content: _aboutUsText),
                                ),
                                _divider(),
                                _tile(
                                  icon: Icons.description_outlined,
                                  title: 'Terms of Use',
                                  onTap: () => _showInfoSheet(context,
                                      title: 'Terms of Use',
                                      content: _termsText),
                                ),
                                _divider(),
                                _tile(
                                  icon: Icons.warning_amber_outlined,
                                  title: 'Disclaimer',
                                  onTap: () => _showInfoSheet(context,
                                      title: 'Disclaimer',
                                      content: _disclaimerText),
                                ),
                                _divider(),
                                _tile(
                                  icon: Icons.privacy_tip_outlined,
                                  title: 'Privacy Policy',
                                  onTap: () => _showInfoSheet(context,
                                      title: 'Privacy Policy',
                                      content: _privacyText),
                                ),
                              ]),
                              verticalSpacer(16),

                              // ── Danger Zone ───────────────────────────────
                              _sectionLabel('Account Actions'),
                              _card([
                                _tile(
                                  icon: Icons.logout,
                                  iconColor: Colors.orange,
                                  title: 'Log Out',
                                  titleColor: Colors.orange,
                                  onTap: () => _confirmLogout(context, controller),
                                ),
                                _divider(),
                                _tile(
                                  icon: Icons.delete_forever_outlined,
                                  iconColor: AppColors.coolRed,
                                  title: 'Delete Account',
                                  titleColor: AppColors.coolRed,
                                  onTap: () => _showDeleteAccountSheet(context, controller),
                                ),
                              ]),
                              verticalSpacer(40),

                              // ── Version ───────────────────────────────────
                              Center(
                                child: Text(
                                  'BizTidy Agent v1.0.0',
                                  style: AppStyles.subStringStyle(12, AppColors.darkGray),
                                ),
                              ),
                              verticalSpacer(20),
                            ],
                          ),
                        ),
                      ],
                    ),
          );
        },
      ),
    );
  }

  // ── Sliver header with profile photo ─────────────────────────────────────
  Widget _staticHeader(BuildContext context, AgentProfileController controller) {
    final photoUrl = controller.agentData?.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Container(
      color: AppColors.primaryThemeColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              // Top row: title
              Row(
                children: [
                  Text('Profile',
                      style: AppStyles.keyStringStyle(18, AppColors.plainWhite)),
                ],
              ),
              verticalSpacer(20),
              // Profile photo — cached, no collapsing
              ClipOval(
                child: hasPhoto
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 96, height: 96,
                          color: AppColors.primaryThemeColor,
                          child: const Icon(Icons.person,
                              color: Colors.white54, size: 48),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 96, height: 96,
                          color: AppColors.primaryThemeColor,
                          child: Icon(Icons.person,
                              color: AppColors.plainWhite, size: 48),
                        ),
                      )
                    : Container(
                        width: 96, height: 96,
                        color: AppColors.primaryThemeColor.withValues(alpha: 0.5),
                        child: Icon(Icons.person,
                            color: AppColors.plainWhite, size: 50),
                      ),
              ),
              verticalSpacer(12),
              Text(
                controller.agentData?.name ?? 'Agent',
                style: AppStyles.keyStringStyle(20, AppColors.plainWhite),
              ),
              verticalSpacer(4),
              Text(
                controller.agentData?.email ?? '',
                style: AppStyles.subStringStyle(
                    13, AppColors.plainWhite.withValues(alpha: 0.8)),
              ),
              verticalSpacer(10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: (controller.agentData?.isApproved == true)
                      ? const Color(0xFF1B8A2E)
                      : const Color(0xFFB35C00),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.agentData?.isApproved == true
                      ? '✓ Verified Agent'
                      : '⏳ Pending Approval',
                  style:
                      AppStyles.regularStringStyle(12, AppColors.plainWhite),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text.toUpperCase(),
            style: AppStyles.subStringStyle(11, AppColors.darkGray)
                .copyWith(letterSpacing: 1.2)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.plainWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _profileCardShadow,
        ),
        child: Column(children: children),
      );

  Widget _divider() => Divider(
      height: 1, indent: 52, endIndent: 16, color: Colors.grey.shade100);

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) =>
      ListTile(
        onTap: onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primaryThemeColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 20, color: iconColor ?? AppColors.primaryThemeColor),
        ),
        title: Text(title,
            style: AppStyles.regularStringStyle(
                14, titleColor ?? AppColors.fullBlack)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: AppStyles.subStringStyle(12, AppColors.darkGray))
            : null,
        trailing: Icon(Icons.chevron_right,
            size: 20, color: AppColors.darkGray.withValues(alpha: 0.5)),
      );

  // ── Change Password Sheet ─────────────────────────────────────────────────
  void _showChangePasswordSheet(
      BuildContext context, AgentProfileController controller) {
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.plainWhite,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              verticalSpacer(16),
              Text('Change Password',
                  style: AppStyles.keyStringStyle(18, AppColors.fullBlack)),
              verticalSpacer(20),
              _passwordField(
                controller: controller.currentPasswordController,
                hint: 'Current password',
                obscure: obscureCurrent,
                onToggle: () => setState(() => obscureCurrent = !obscureCurrent),
              ),
              verticalSpacer(12),
              _passwordField(
                controller: controller.newPasswordController,
                hint: 'New password',
                obscure: obscureNew,
                onToggle: () => setState(() => obscureNew = !obscureNew),
              ),
              verticalSpacer(12),
              _passwordField(
                controller: controller.confirmPasswordController,
                hint: 'Confirm new password',
                obscure: obscureConfirm,
                onToggle: () =>
                    setState(() => obscureConfirm = !obscureConfirm),
              ),
              verticalSpacer(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.changePassword(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThemeColor,
                    foregroundColor: AppColors.plainWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Update Password',
                      style: AppStyles.regularStringStyle(
                          15, AppColors.plainWhite)),
                ),
              ),
              verticalSpacer(10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppStyles.subStringStyle(14, AppColors.darkGray),
          filled: true,
          fillColor: const Color(0xFFF5F6FA),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.darkGray, size: 20),
            onPressed: onToggle,
          ),
        ),
      );

  // ── Delete Account Sheet ──────────────────────────────────────────────────
  void _showDeleteAccountSheet(
      BuildContext context, AgentProfileController controller) {
    final passController = TextEditingController();
    bool obscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.plainWhite,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              verticalSpacer(16),
              Row(
                children: [
                  Icon(Icons.warning_rounded,
                      color: AppColors.coolRed, size: 24),
                  const SizedBox(width: 8),
                  Text('Delete Account',
                      style:
                          AppStyles.keyStringStyle(18, AppColors.coolRed)),
                ],
              ),
              verticalSpacer(12),
              Text(
                'This will permanently delete your account, all your data, and remove you from the BizTidy platform. This action cannot be undone.',
                style: AppStyles.subStringStyle(13, AppColors.darkGray),
              ),
              verticalSpacer(16),
              TextField(
                controller: passController,
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: 'Enter your password to confirm',
                  hintStyle:
                      AppStyles.subStringStyle(14, AppColors.darkGray),
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.darkGray,
                        size: 20),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
              ),
              verticalSpacer(16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel',
                          style: AppStyles.regularStringStyle(
                              14, AppColors.fullBlack)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        controller.deleteAccount(
                            context, passController.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coolRed,
                        foregroundColor: AppColors.plainWhite,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Delete',
                          style: AppStyles.regularStringStyle(
                              14, AppColors.plainWhite)),
                    ),
                  ),
                ],
              ),
              verticalSpacer(10),
            ],
          ),
        ),
      ),
    );
  }

  // ── Confirm Logout ────────────────────────────────────────────────────────
  void _confirmLogout(
      BuildContext context, AgentProfileController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out',
            style: AppStyles.keyStringStyle(17, AppColors.fullBlack)),
        content: Text('Are you sure you want to log out?',
            style: AppStyles.subStringStyle(14, AppColors.darkGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppStyles.regularStringStyle(
                    14, AppColors.primaryThemeColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.signOut(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Log Out',
                style:
                    AppStyles.regularStringStyle(14, AppColors.plainWhite)),
          ),
        ],
      ),
    );
  }

  // ── Info Sheet (About, Terms, etc) ────────────────────────────────────────
  void _showInfoSheet(BuildContext context,
      {required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (ctx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: AppColors.plainWhite,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(title,
                    style:
                        AppStyles.keyStringStyle(18, AppColors.fullBlack)),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  child: Text(content,
                      style: AppStyles.subStringStyle(
                          14, AppColors.fullBlack)
                          .copyWith(height: 1.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── URL Launcher ──────────────────────────────────────────────────────────
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }


  // ── Forgot Password Sheet ─────────────────────────────────────────────────
  void _showForgotPasswordSheet(
      BuildContext context, AgentProfileController controller) {
    final emailCtrl = TextEditingController(
        text: controller.agentData?.email ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.plainWhite,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              verticalSpacer(16),
              Text('Reset Password',
                  style: AppStyles.keyStringStyle(18, AppColors.fullBlack)),
              verticalSpacer(8),
              Text(
                'We will send a password reset link to your email address.',
                style: AppStyles.subStringStyle(13, AppColors.darkGray),
              ),
              verticalSpacer(20),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Your email address',
                  hintStyle:
                      AppStyles.subStringStyle(14, AppColors.darkGray),
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  prefixIcon: Icon(Icons.email_outlined,
                      color: AppColors.darkGray, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              verticalSpacer(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.sendPasswordResetEmail(
                      context, emailCtrl.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThemeColor,
                    foregroundColor: AppColors.plainWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Send Reset Link',
                      style: AppStyles.regularStringStyle(
                          15, AppColors.plainWhite)),
                ),
              ),
              verticalSpacer(10),
            ],
          ),
        ),
      ),
    );
  }

  // ── Static text content ───────────────────────────────────────────────────
  static const _aboutUsText = '''
BizTidy is a platform connecting professional cleaning agents with customers who need cleaning services.

We are committed to providing reliable, high-quality cleaning services through our network of verified agents. Our mission is to make professional cleaning accessible and affordable for everyone while providing agents with a steady stream of work and fair compensation.

BizTidy was founded with the belief that a clean environment improves quality of life — at home and at work.

Contact us: tidy1tech@gmail.com
''';

  static const _termsText = '''
Terms of Use — BizTidy Agent App

1. Eligibility
You must be 18 years or older and legally eligible to work to register as a BizTidy agent.

2. Account Responsibilities
You are responsible for maintaining the confidentiality of your account credentials. You agree to provide accurate information during registration.

3. Service Standards
As an agent, you agree to provide professional, courteous, and thorough cleaning services to all clients. You must arrive on time and complete jobs to the expected standard.

4. Conduct
Agents must treat all customers, their property, and fellow agents with respect. Any form of misconduct may result in immediate suspension or removal from the platform.

5. Payments & Commission
a) Commission Structure: BizTidy operates on a 60/40 commission model. You (the agent) earn 60% of the total job fee. BizTidy retains 40% as a platform commission. In addition, a flat ₦500 Trust & Safety Fee is deducted per completed job from your earnings. Example: on a ₦10,000 job, your earnings = (₦10,000 × 60%) − ₦500 = ₦5,500.

b) Payment Trigger: Your earnings are only calculated and credited after the client submits a star rating for the completed job. Jobs that are completed but not yet rated will show as pending.

c) Payout Process: Payouts are processed weekly. You must add a verified Nigerian bank account registered in your own name to request a withdrawal. BizTidy will not process payments to third-party accounts.

d) Account Verification: Your bank account name must match your registered BizTidy profile name. Any attempt to use another person's account will be blocked and may result in account suspension.

e) Rate Changes: BizTidy reserves the right to adjust the commission structure with at least 7 days' prior notice to agents.

6. Termination
BizTidy reserves the right to suspend or terminate any agent account for violations of these terms.
''';

  static const _disclaimerText = '''
Disclaimer — BizTidy Agent App

The BizTidy platform provides tools and connections to facilitate cleaning services. BizTidy does not guarantee a minimum number of jobs or earnings for any agent.

Agents operate as independent service providers and are responsible for their own tax obligations, insurance, and compliance with local labour laws.

BizTidy is not liable for any loss, damage, injury, or dispute arising from services performed through the platform. Agents are advised to exercise professional judgment at all times.

Information provided in the app is for general purposes and may be subject to change without notice.
''';

  static const _privacyText = '''
Privacy Policy — BizTidy Agent App

1. Information We Collect
We collect your name, email address, phone number, home address, passport photo, and ID document for identity verification purposes.

2. How We Use Your Information
Your information is used to verify your identity, process job assignments, calculate earnings, and communicate with you about the platform.

3. Data Storage
Your data is stored securely on Firebase (Google Cloud). We do not sell your personal information to third parties.

4. Photos & Documents
Passport photos and ID documents are stored securely and are only accessible to BizTidy administrators for verification purposes.

5. Your Rights
You may request deletion of your account and associated data at any time through the app's Delete Account feature.

6. Contact
For privacy concerns, contact us at tidy1tech@gmail.com
''';
}
