import 'package:go_router/go_router.dart';

import 'screens/about_screen.dart';
import 'screens/accessibility_screen.dart';
import 'screens/account_screen.dart';
import 'screens/article_screen.dart';
import 'screens/data_saver_screen.dart';
import 'screens/delete_account_screen.dart';
import 'screens/delete_confirm_screen.dart';
import 'screens/help_screen.dart';
import 'screens/invite_screen.dart';
import 'screens/language_screen.dart';
import 'screens/notif_prefs_screen.dart';
import 'screens/password_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/support_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/theme_screen.dart';

/// Settings routes (K02–K24). Top-level pushed routes (no tab bar).
/// [SettingsScreen] itself is tab-nested under Profile and is wired by the
/// coordinator — it is intentionally NOT in this list.
final List<RouteBase> settingsRoutes = [
  GoRoute(
    path: '/settings/account',
    builder: (context, state) => const AccountScreen(),
  ),
  GoRoute(
    path: '/settings/password',
    builder: (context, state) => const ChangePasswordScreen(),
  ),
  GoRoute(
    path: '/settings/language',
    builder: (context, state) => const LanguageScreen(),
  ),
  GoRoute(
    path: '/settings/theme',
    builder: (context, state) => const ThemeScreen(),
  ),
  GoRoute(
    path: '/settings/reminders',
    builder: (context, state) => const RemindersScreen(),
  ),
  GoRoute(
    path: '/settings/notifications',
    builder: (context, state) => const NotifPrefsScreen(),
  ),
  GoRoute(
    path: '/settings/data-saver',
    builder: (context, state) => const DataSaverScreen(),
  ),
  GoRoute(
    path: '/settings/privacy',
    builder: (context, state) => const PrivacyScreen(),
  ),
  GoRoute(
    path: '/settings/accessibility',
    builder: (context, state) => const AccessibilityScreen(),
  ),
  GoRoute(
    path: '/settings/help',
    builder: (context, state) => const HelpScreen(),
  ),
  GoRoute(
    path: '/settings/help/:articleId',
    builder: (context, state) => HelpArticleScreen(
      articleId: state.pathParameters['articleId'] ?? '',
    ),
  ),
  GoRoute(
    path: '/settings/support',
    builder: (context, state) => const SupportScreen(),
  ),
  GoRoute(
    path: '/settings/about',
    builder: (context, state) => const AboutScreen(),
  ),
  GoRoute(
    path: '/settings/terms',
    builder: (context, state) => const TermsScreen(),
  ),
  GoRoute(
    path: '/settings/invite',
    builder: (context, state) => const InviteScreen(),
  ),
  GoRoute(
    path: '/settings/delete-1',
    builder: (context, state) => const DeleteAccountScreen(),
  ),
  GoRoute(
    path: '/settings/delete-2',
    builder: (context, state) => const DeleteConfirmScreen(),
  ),
];
