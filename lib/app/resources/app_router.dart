import 'package:biztidy_agent_app/app/services/navigation_service.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_view/agent_create_account_view.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_view/agent_guest_view.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_view/agent_onboarding_view.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_view/agent_pending_approval_screen.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_view/agent_signin_view.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_view/agent_splash_screen.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_view/agent_verify_email_screen.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_home/agent_home_view/agent_home_screen.dart';
import 'package:go_router/go_router.dart';

class AgentAppRouter {
  static final router = GoRouter(
    navigatorKey: NavigationService.navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const AgentSplashScreen()),
      GoRoute(path: '/agentOnboardingView', builder: (c, s) => const AgentOnboardingView()),
      GoRoute(path: '/agentSignInView', builder: (c, s) => const AgentSignInView()),
      GoRoute(path: '/agentCreateAccountView', builder: (c, s) => const AgentCreateAccountView()),
      GoRoute(path: '/agentVerifyEmailScreen', builder: (c, s) => const AgentVerifyEmailScreen()),
      GoRoute(path: '/agentPendingApprovalScreen', builder: (c, s) => const AgentPendingApprovalScreen()),
      GoRoute(path: '/agentHomeScreen', builder: (c, s) => const AgentHomeScreen()),
      GoRoute(path: '/agentGuestView', builder: (c, s) => const AgentGuestView()),
    ],
  );
}
