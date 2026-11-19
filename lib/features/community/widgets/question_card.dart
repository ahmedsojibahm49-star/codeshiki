import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';

/// Reusable forum question card (feed / search / tag / my-questions).
/// Watches [forumProvider] so the upvote count updates live.
class QuestionCard extends ConsumerWidget {
  const QuestionCard({super.key, required this.question, this.onTap});

  final ForumQuestion question;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    // Live copy from the provider — upvotes/answers update after toggling.
    final live = ref.watch(forumProvider).firstWhere(
          (q) => q.id == question.id,
          orElse: () => question,
        );
    final upvoted =
        ref.read(forumProvider.notifier).hasUpvoted(live.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CsAvatar(
                  photoAsset: live.authorPhoto,
                  name: live.authorName,
                  size: 36,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        live.authorName,
                        style: AppText.label
                            .copyWith(color: cs.textPrimary),
                      ),
                      Text(
                        live.createdLabel,
                        style: AppText.caption
                            .copyWith(color: cs.textTertiary),
                      ),
                    ],
                  ),
                ),
                if (live.accepted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cs.successSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.check,
                            size: 12, color: cs.success),
                        const SizedBox(width: 4),
                        Text(
                          'Solved',
                          style: AppText.caption.copyWith(
                            color: cs.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              live.title,
              style: AppText.body.copyWith(
                color: cs.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              live.body,
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (live.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: live.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.sunken,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: AppText.caption.copyWith(
                            color: cs.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  onTap: () => ref
                      .read(forumProvider.notifier)
                      .toggleUpvote(live.id),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: upvoted
                          ? cs.primary.withValues(alpha: 0.12)
                          : cs.sunken,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          upvoted ? AppIcons.likeBold : AppIcons.like,
                          size: 16,
                          color: upvoted ? cs.accent : cs.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${live.upvotes}',
                          style: AppText.label.copyWith(
                            color:
                                upvoted ? cs.accent : cs.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(AppIcons.message, size: 16, color: cs.textTertiary),
                const SizedBox(width: 6),
                Text(
                  '${live.answersCount} answers',
                  style: AppText.caption
                      .copyWith(color: cs.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
