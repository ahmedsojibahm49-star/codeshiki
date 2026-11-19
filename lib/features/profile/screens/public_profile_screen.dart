import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/demo_data.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_badge_image.dart';
import '../../../widgets/cs_stat_item.dart';
import '../../../widgets/cs_top_bar.dart';

/// Read-only public profile [H10]. Shows the named learner when [name]
/// matches a leaderboard entry, otherwise the current user.
class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({super.key, this.name});

  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final me = ref.watch(authProvider).user ?? DemoData.me;
    final wallet = ref.watch(walletProvider);

    final entry = name == null
        ? null
        : DemoData.leaderboard
            .where((e) => e.name == name)
            .firstOrNull;
    final displayName = entry?.name ?? me.name;
    final photo = entry?.photo ?? me.avatarPhoto;
    final xp = entry?.xp ?? wallet.xp;
    final isMe = entry == null || entry.isMe;
    final unlockedBadges = DemoData.badges
        .where((b) => wallet.unlockedBadgeIds.contains(b.id))
        .toList();

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(
        title: 'Profile',
        actions: [
          IconButton(
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                text:
                    'Check out $displayName on CodeShikhi — $xp XP and counting!',
              ),
            ),
            icon: Icon(AppIcons.share, color: cs.textPrimary),
            tooltip: 'Share profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Center(
            child: Column(
              children: [
                CsAvatar(photoAsset: photo, name: displayName, size: 88),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: AppText.h2.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  isMe ? me.bio : 'Learning on CodeShikhi',
                  style:
                      AppText.bodySmall.copyWith(color: cs.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CsStatItem(value: '$xp', label: 'XP'),
                ),
                Expanded(
                  child: CsStatItem(
                    value: '${1 + xp ~/ 200}',
                    label: 'Level',
                  ),
                ),
                Expanded(
                  child: CsStatItem(
                    value: '${unlockedBadges.length}',
                    label: 'Badges',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Badges',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.border),
            ),
            child: Row(
              children: [
                ...unlockedBadges.take(5).map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CsBadgeImage(badge: b, size: 48),
                      ),
                    ),
                const Spacer(),
                Text(
                  '${unlockedBadges.length} unlocked',
                  style: AppText.caption.copyWith(color: cs.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
