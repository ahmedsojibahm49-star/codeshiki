import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../widgets/cs_logo.dart';

/// Welcome [A05]. Log in / Create account / Continue as guest (demo login).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  Future<void> _continueAsGuest(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).demoLogin();
    if (!context.mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: CsLogo(size: 88)),
              const SizedBox(height: 24),
              Text(
                'CodeShikhi',
                textAlign: TextAlign.center,
                style: AppText.display.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'Learn coding in Bangla.\nBuild real projects. Earn certificates.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const Spacer(),
              CsButton(
                label: 'Log in',
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: 12),
              CsButton(
                label: 'Create account',
                variant: CsButtonVariant.secondary,
                onPressed: () => context.push('/signup'),
              ),
              const SizedBox(height: 8),
              CsButton(
                label: 'Continue as guest',
                variant: CsButtonVariant.ghost,
                onPressed: () => _continueAsGuest(context, ref),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
