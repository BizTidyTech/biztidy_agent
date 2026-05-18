// ignore_for_file: use_build_context_synchronously
import 'package:biztidy_agent_app/app/helpers/agent_sharedprefs.dart';
import 'package:biztidy_agent_app/app/services/agent_firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AgentSplashScreen extends StatefulWidget {
  const AgentSplashScreen({super.key});
  @override
  State<AgentSplashScreen> createState() => _AgentSplashScreenState();
}

class _AgentSplashScreenState extends State<AgentSplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _bizTidyFade;
  late Animation<double> _agentFade;
  late Animation<Offset> _bizTidySlide;
  late Animation<Offset> _agentSlide;

  @override
  void initState() {
    super.initState();

    // BizTidy fades + slides in first
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _bizTidyFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _agentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
    _bizTidySlide = Tween<Offset>(
        begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _agentSlide = Tween<Offset>(
        begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    _fadeController.forward();
    _slideController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { context.go('/agentOnboardingView'); return; }

    // Use Firestore emailVerified (OTP-based) instead of Firebase Auth link
    final agent = await AgentFirebaseService().getAgentById(user.uid);
    if (agent == null) { context.go('/agentOnboardingView'); return; }
    if (agent.emailVerified != true) { context.go('/agentVerifyEmailScreen'); return; }
    if (agent.isApproved != true) { context.go('/agentPendingApprovalScreen'); return; }

    await saveAgentDetailsLocally(agent);
    context.go('/agentHomeScreen');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0F172A),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0F172A),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // BizTidy — large, teal, bold
              SlideTransition(
                position: _bizTidySlide,
                child: FadeTransition(
                  opacity: _bizTidyFade,
                  child: const Text(
                    'BizTidy',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D9E75),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // AGENT — smaller, white, spaced
              SlideTransition(
                position: _agentSlide,
                child: FadeTransition(
                  opacity: _agentFade,
                  child: const Text(
                    'A G E N T',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0x99FFFFFF),
                      letterSpacing: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}