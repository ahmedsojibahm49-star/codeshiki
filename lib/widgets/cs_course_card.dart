import 'package:material_ui/material_ui.dart';

import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';

/// Horizontal course card: 96x96 cover, title, instructor, rating, and a
/// price/access chip (Free / Pro / ৳price).
class CsCourseListCard extends StatelessWidget {
  const CsCourseListCard({
    super.key,
    required this.course,
    this.onTap,
    this.trailing,
  });

  final Course course;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.borderHairline),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  course.coverPhoto,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style:
                          AppText.label.copyWith(color: cs.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.instructor,
                      style: AppText.caption.copyWith(
                        color: cs.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(AppIcons.starBold, size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toStringAsFixed(1),
                          style: AppText.caption.copyWith(
                            color: cs.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${course.ratingCount})',
                          style: AppText.caption.copyWith(
                            color: cs.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${course.lessonsCount} lessons',
                          style: AppText.caption.copyWith(
                            color: cs.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _AccessChip(course: course),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessChip extends StatelessWidget {
  const _AccessChip({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final String label;
    final Color bg;
    final Color fg;
    if (course.isFree) {
      label = 'Free';
      bg = cs.successSoft;
      fg = cs.success;
    } else if (course.isPro) {
      label = 'Pro';
      bg = AppColors.peachLight;
      fg = cs.accent;
    } else {
      label = '৳${course.price}';
      bg = cs.sunken;
      fg = cs.textPrimary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
