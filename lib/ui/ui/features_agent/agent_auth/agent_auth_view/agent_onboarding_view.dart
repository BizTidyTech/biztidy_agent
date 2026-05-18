import 'package:biztidy_agent_app/ui/shared/custom_button.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AgentOnboardingView extends StatelessWidget {
  const AgentOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.kPrimaryColor,
      ),
      child: Scaffold(
        backgroundColor: AppColors.plainWhite,
        body: Column(
          children: [
            verticalSpacer(70),
            const Spacer(),

            // Professional logo mark
            const _LogoMark(),
            verticalSpacer(28),

            Text(
              'Become a BizTidy Agent',
              style: AppStyles.keyStringStyle(24, AppColors.fullBlack),
              textAlign: TextAlign.center,
            ),
            verticalSpacer(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Join our network of professional cleaning\nagents and earn on your own schedule.',
                style: AppStyles.subStringStyle(15, AppColors.darkGray),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            // Bottom action card
            Container(
              width: screenWidth(context),
              decoration: BoxDecoration(
                color: AppColors.kPrimaryColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                children: [
                  const _BenefitRow(Icons.schedule_rounded, 'Work on your own schedule'),
                  verticalSpacer(12),
                  const _BenefitRow(Icons.payments_outlined, 'Get paid weekly'),
                  verticalSpacer(12),
                  const _BenefitRow(Icons.verified_user_outlined, 'Vetted & trusted platform'),
                  verticalSpacer(32),
                  CustomButton(
                    buttonText: 'Apply to Become an Agent',
                    width: screenWidth(context),
                    onPressed: () => context.push('/agentCreateAccountView'),
                  ),
                  verticalSpacer(14),
                  CustomButton(
                    buttonText: 'I Already Have an Account',
                    width: screenWidth(context),
                    color: AppColors.kPrimaryColor,
                    borderColor: AppColors.deepBlue,
                    textcolor: AppColors.deepBlue,
                    onPressed: () => context.push('/agentSignInView'),
                  ),
                  verticalSpacer(16),
                  GestureDetector(
                    onTap: () => context.go('/agentGuestView'),
                    child: Text(
                      'Explore as Guest',
                      style: AppStyles.subStringStyle(14, AppColors.darkGray)
                          .copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                  verticalSpacer(20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium typographic monogram — replaces generic cleaning-brush icon.
/// Dark-navy core disc with "BT" in Audiowide (brand font) + teal accent,
/// surrounded by two concentric hairline rings for depth.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outermost hairline ring
        Container(
          width: 156,
          height: 156,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryThemeColor.withValues(alpha: 0.18),
              width: 1.5,
            ),
          ),
        ),
        // Second hairline ring
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryThemeColor.withValues(alpha: 0.36),
              width: 1.5,
            ),
          ),
        ),
        // Core — dark navy disc with teal glow shadow
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF002244), Color(0xFF001530)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryThemeColor.withValues(alpha: 0.35),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.kPrimaryColor.withValues(alpha: 0.12),
                blurRadius: 6,
                spreadRadius: 2,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'BT',
              style: TextStyle(
                fontFamily: 'Audiowide',
                fontSize: 28,
                color: AppColors.kPrimaryColor,
                letterSpacing: 2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        // Small teal accent dot — top-right position (jewel detail)
        Positioned(
          top: 26,
          right: 26,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kPrimaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.kPrimaryColor.withValues(alpha: 0.7),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.deepBlue, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: AppStyles.regularStringStyle(15, AppColors.fullBlack),
        ),
      ],
    );
  }
}
