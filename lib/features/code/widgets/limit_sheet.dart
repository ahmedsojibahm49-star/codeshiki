import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_sheet.dart';
import '../code_storage.dart';

/// Daily run limit sheet [F19]: shown instead of running when the user
/// has used all 10 free runs today.
Future<void> showLimitSheet(BuildContext context) {
  return showCsSheet<void>(context, const LimitSheet());
}

class LimitSheet extends StatelessWidget {
  const LimitSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.warningSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(AppIcons.warning, size: 30, color: cs.warning),
          ),
          const SizedBox(height: 16),
          Text(
            'Daily run limit reached',
            style: AppText.h3.copyWith(color: cs.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You have used all ${CodeStorage.dailyRunLimit} free runs today. '
            'Your limit resets tomorrow — or go Pro for unlimited runs.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CsButton(
            label: 'Go Pro — unlimited runs',
            variant: CsButtonVariant.pro,
            icon: AppIcons.crown,
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/payments/plans');
            },
          ),
          const SizedBox(height: 8),
          CsButton(
            label: 'Maybe later',
            variant: CsButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
