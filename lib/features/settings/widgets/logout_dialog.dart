import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';

/// Log-out confirmation dialog [K21].
/// "Log out" clears the session via [AuthNotifier.logout] and goes to
/// `/welcome`.
Future<void> showLogoutDialog(BuildContext context) async {
  final cs = context.cs;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        '${context.tr('logout')}?',
        style: AppText.h3.copyWith(color: cs.textPrimary),
      ),
      content: Text(
        'You will need to log in again to continue learning.',
        style: AppText.body.copyWith(color: cs.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            context.tr('cancel'),
            style: AppText.button.copyWith(color: cs.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            context.tr('logout'),
            style: AppText.button.copyWith(color: cs.danger),
          ),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    ProviderScope.containerOf(context)
        .read(authProvider.notifier)
        .logout();
    context.go('/welcome');
  }
}
