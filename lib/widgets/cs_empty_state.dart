import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'cs_button.dart';

/// Centered empty state: icon in a sunken circle, title, body, optional action.
class CsEmptyState extends StatelessWidget {
  const CsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.sunken,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: cs.accent),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppText.h3.copyWith(color: cs.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              CsButton(
                label: actionLabel!,
                onPressed: onAction,
                size: CsButtonSize.m,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
