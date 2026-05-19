import 'package:biztidy_agent_app/ui/shared/custom_button.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AgentGuestView extends StatelessWidget {
  const AgentGuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryThemeColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.plainWhite,
        appBar: AppBar(
          backgroundColor: AppColors.primaryThemeColor,
          iconTheme: IconThemeData(color: AppColors.plainWhite),
          title: Text('Guest Mode',
              style: AppStyles.keyStringStyle(18, AppColors.plainWhite)),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/agentOnboardingView'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacer(20),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryThemeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline,
                      size: 52, color: AppColors.primaryThemeColor),
                ),
              ),
              verticalSpacer(20),
              Center(
                child: Text('Browsing as Guest',
                    style: AppStyles.keyStringStyle(22, AppColors.fullBlack)),
              ),
              verticalSpacer(8),
              Center(
                child: Text(
                  'You can explore the app but you\'ll need an account to accept jobs and earn.',
                  style: AppStyles.subStringStyle(14, AppColors.darkGray),
                  textAlign: TextAlign.center,
                ),
              ),
              verticalSpacer(32),

              // What guests can see
              _sectionHeader('What you can explore'),
              verticalSpacer(12),
              _featureRow(Icons.info_outline, 'About BizTidy', available: true),
              _featureRow(Icons.payments_outlined, 'How earnings work', available: true),
              _featureRow(Icons.help_outline, 'FAQs & Help Center', available: true),
              _featureRow(Icons.description_outlined, 'Terms & Privacy Policy', available: true),

              verticalSpacer(20),
              _sectionHeader('Requires an account'),
              verticalSpacer(12),
              _featureRow(Icons.work_outline, 'Accept & manage jobs', available: false),
              _featureRow(Icons.account_balance_wallet_outlined, 'View your earnings', available: false),
              _featureRow(Icons.toggle_on_outlined, 'Go online to receive jobs', available: false),

              verticalSpacer(32),

              // Info tiles
              _infoCard(
                icon: Icons.payments_outlined,
                title: 'How Earnings Work',
                body: 'Agents earn a commission for each completed job. Payments are processed weekly directly to your account.',
              ),
              verticalSpacer(12),
              _infoCard(
                icon: Icons.verified_user_outlined,
                title: 'Verification Process',
                body: 'All agents go through an identity verification and background check. This keeps our platform safe for agents and customers.',
              ),
              verticalSpacer(12),
              _infoCard(
                icon: Icons.schedule,
                title: 'Flexible Schedule',
                body: 'You choose when you work. Go online to receive jobs and go offline when you\'re unavailable. No minimum hours required.',
              ),

              verticalSpacer(32),
              CustomButton(
                buttonText: 'Apply to Become an Agent',
                width: screenWidth(context),
                onPressed: () => context.go('/agentCreateAccountView'),
              ),
              verticalSpacer(12),
              CustomButton(
                buttonText: 'Sign In to My Account',
                width: screenWidth(context),
                color: AppColors.plainWhite,
                borderColor: AppColors.primaryThemeColor,
                textcolor: AppColors.primaryThemeColor,
                onPressed: () => context.go('/agentSignInView'),
              ),
              verticalSpacer(30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Text(
        text,
        style: AppStyles.keyStringStyle(15, AppColors.fullBlack),
      );

  Widget _featureRow(IconData icon, String text, {required bool available}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(
              available ? Icons.check_circle : Icons.lock_outline,
              size: 20,
              color: available ? AppColors.normalGreen : AppColors.darkGray,
            ),
            const SizedBox(width: 10),
            Text(text,
                style: AppStyles.regularStringStyle(
                    14,
                    available
                        ? AppColors.fullBlack
                        : AppColors.darkGray)),
          ],
        ),
      );

  Widget _infoCard(
          {required IconData icon,
          required String title,
          required String body}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryThemeColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primaryThemeColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryThemeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primaryThemeColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppStyles.regularStringStyle(
                          14, AppColors.fullBlack)),
                  verticalSpacer(4),
                  Text(body,
                      style:
                          AppStyles.subStringStyle(13, AppColors.darkGray)),
                ],
              ),
            ),
          ],
        ),
      );
}
