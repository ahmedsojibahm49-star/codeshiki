import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/hive_boxes.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../widgets/cs_logo.dart';

/// Splash [A01]. Shows the logo, then routes after 1.5s:
/// logged in -> /home, seen intro -> /welcome, otherwise -> /intro.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), _routeNext);
  }

  void _routeNext() {
    if (!mounted) return;
    if (ref.read(authProvider).isLoggedIn) {
      context.go('/home');
    } else if (HiveBoxes.settings.get('seenIntro') == true) {
      context.go('/welcome');
    } else {
      context.go('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CsLogo(size: 96),
            const SizedBox(height: 24),
            Text(
              'CodeShikhi',
              style: AppText.display.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Learn coding in Bangla.',
              style: AppText.body.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: cs.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
