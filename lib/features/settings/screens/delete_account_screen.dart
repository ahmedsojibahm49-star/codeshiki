import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';

/// Delete account, step 1 [K22]: warnings about what gets deleted.
class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  static const List<String> _warnings = [
    'Your profile, name and bio',
    'All course progress, XP, Volts and streaks',
    'Your badges and certificates',
    'Your forum questions and answers',
    'Your orders and payment history',
    'All downloaded lessons on this device',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'Delete account'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.dangerSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(AppIcons.warningBold, size: 40, color: cs.danger),
                const SizedBox(height: 12),
                Text(
                  'This cannot be undone',
                  style: AppText.h2.copyWith(color: cs.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Deleting your account permanently removes everything below. There is no way to recover it.',
                  style: AppText.bodySmall.copyWith(color: cs.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'What gets deleted',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          for (final warning in _warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(AppIcons.close, size: 20, color: cs.danger),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        warning,
                        style: AppText.body.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          CsButton(
            label: 'Continue',
            variant: CsButtonVariant.destructive,
            onPressed: () => context.push('/settings/delete-2'),
          ),
          const SizedBox(height: 12),
          CsButton(
            label: 'Keep my account',
            variant: CsButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
