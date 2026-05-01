// ignore_for_file: use_build_context_synchronously
import 'package:biztidy_agent_app/app/helpers/agent_sharedprefs.dart';
import 'package:biztidy_agent_app/ui/shared/custom_button.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AgentPendingApprovalScreen extends StatelessWidget {
  const AgentPendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: 52,
                    color: AppColors.primaryThemeColor,
                  ),
                ),
                verticalSpacer(28),
                Text(
                  'Application Submitted!',
                  style: AppStyles.keyStringStyle(24, AppColors.fullBlack),
                  textAlign: TextAlign.center,
                ),
                verticalSpacer(16),
                Text(
                  'Your application has been received. Our team will review your details and approve your account within 24–48 hours.',
                  style: AppStyles.subStringStyle(15, AppColors.darkGray),
                  textAlign: TextAlign.center,
                ),
                verticalSpacer(28),
                // What happens next
                _stepCard(
                  icon: Icons.search,
                  title: 'Step 1: Review',
                  subtitle: 'We verify your details and background',
                ),
                verticalSpacer(12),
                _stepCard(
                  icon: Icons.check_circle_outline,
                  title: 'Step 2: Approval',
                  subtitle: 'You\'ll receive a notification once approved',
                ),
                verticalSpacer(12),
                _stepCard(
                  icon: Icons.work_outline,
                  title: 'Step 3: Start Working',
                  subtitle: 'Log in and go online to receive jobs',
                ),
                const Spacer(),
                // Check status button
                CustomButton(
                  buttonText: 'Check Approval Status',
                  width: screenWidth(context),
                  onPressed: () async {
                    final agent = await getLocallySavedAgentDetails();
                    if (agent?.agentId != null) {
                      context.go('/agentSignInView');
                    }
                  },
                ),
                verticalSpacer(14),
                CustomButton(
                  buttonText: 'Sign Out',
                  width: screenWidth(context),
                  color: AppColors.plainWhite,
                  borderColor: AppColors.deepBlue,
                  textcolor: AppColors.deepBlue,
                  onPressed: () async {
                    await clearAgentDetailsLocally();
                    context.go('/agentOnboardingView');
                  },
                ),
                verticalSpacer(20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryThemeColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppStyles.regularStringStyle(
                        14, AppColors.fullBlack)),
                Text(subtitle,
                    style:
                        AppStyles.subStringStyle(12, AppColors.darkGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
