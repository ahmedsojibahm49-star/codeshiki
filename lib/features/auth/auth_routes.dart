import 'package:go_router/go_router.dart';

import 'screens/check_email_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/new_password_screen.dart';
import 'screens/onboarding/goal_screen.dart';
import 'screens/onboarding/interests_screen.dart';
import 'screens/onboarding/level_screen.dart';
import 'screens/onboarding/plan_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/welcome_screen.dart';

/// Auth + onboarding routes. Wired into [appRouter] in
/// `lib/navigation/app_router.dart`.
final List<RouteBase> authRoutes = [
  GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
  GoRoute(path: '/intro', builder: (context, state) => const IntroScreen()),
  GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
  GoRoute(path: '/verify', builder: (context, state) => const VerifyScreen()),
  GoRoute(
    path: '/forgot',
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: '/forgot-sent',
    builder: (context, state) => const CheckEmailScreen(),
  ),
  GoRoute(
    path: '/reset-password',
    builder: (context, state) => const NewPasswordScreen(),
  ),
  GoRoute(
    path: '/onboarding/goal',
    builder: (context, state) => const GoalScreen(),
  ),
  GoRoute(
    path: '/onboarding/level',
    builder: (context, state) => const LevelScreen(),
  ),
  GoRoute(
    path: '/onboarding/interests',
    builder: (context, state) => const InterestsScreen(),
  ),
  GoRoute(
    path: '/onboarding/plan',
    builder: (context, state) => const PlanScreen(),
  ),
];
