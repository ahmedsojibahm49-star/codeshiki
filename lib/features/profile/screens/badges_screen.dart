import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_badge_image.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/badge_detail_sheet.dart';

/// All badges grid [H05] — tab-nested (coordinator wires the route).
/// Every badge renders from its Flaticon PNG via [CsBadgeImage].
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final unlockedIds = ref.watch(walletProvider).unlockedBadgeIds;
    final badges = DemoData.badges;
    final unlockedCount =
        badges.where((b) => unlockedIds.contains(b.id)).length;

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Badges'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              '$unlockedCount of ${badges.length} unlocked — tap a badge '
              'to see how to earn it.',
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                final unlocked = unlockedIds.contains(badge.id);
                return InkWell(
                  onTap: () => showBadgeDetailSheet(
                    context,
                    badge,
                    unlocked: unlocked,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CsBadgeImage(
                          badge: badge,
                          size: 64,
                          locked: !unlocked,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge.name,
                          style: AppText.caption.copyWith(
                            color: unlocked
                                ? cs.textPrimary
                                : cs.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
