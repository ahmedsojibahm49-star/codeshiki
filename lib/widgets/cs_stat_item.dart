import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Big value + small label, for profile stats rows.
class CsStatItem extends StatelessWidget {
  const CsStatItem({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppText.h2.copyWith(color: cs.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppText.caption.copyWith(color: cs.textSecondary),
        ),
      ],
    );
  }
}
