import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// Check your email [A15]. Instructions + demo shortcut to reset.
class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Check your email'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(AppIcons.messageText, size: 40, color: cs.accent),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Check your email',
                textAlign: TextAlign.center,
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a password reset link to your email. '
                'Open it and follow the instructions to create a new password.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                "Didn't get the email? Check your spam folder.",
                textAlign: TextAlign.center,
                style: AppText.bodySmall.copyWith(color: cs.textTertiary),
              ),
              const Spacer(),
              CsButton(
                label: 'Continue to reset password (demo)',
                onPressed: () => context.push('/reset-password'),
              ),
              const SizedBox(height: 8),
              CsButton(
                label: 'Resend email',
                variant: CsButtonVariant.ghost,
                onPressed: () => showCsToast(context, 'Reset link resent'),
              ),
              const SizedBox(height: 8),
              CsButton(
                label: 'Back to log in',
                variant: CsButtonVariant.ghost,
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
