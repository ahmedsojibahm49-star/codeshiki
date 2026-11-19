import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';

/// Filter chip. Selected: orange tint bg + accent text + check.
/// Unselected: surface + border.
class CsFilterChip extends StatelessWidget {
  const CsFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.peachLight : cs.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? cs.primary : cs.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(AppIcons.check, size: 16, color: cs.accent),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppText.label.copyWith(
                  color: selected ? cs.accent : cs.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
