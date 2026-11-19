import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/demo_data.dart';
import '../../../data/hive_boxes.dart';
import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_badge_image.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_section_header.dart';
import '../../../widgets/cs_stat_item.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/achievement_dialog.dart';

/// Profile tab root [H01] + achievement modal [H13].
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Achievement modal [H13]: celebrate the first unlocked badge that
    // has not been celebrated yet (tracked in Hive `settings`).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final wallet = ref.read(walletProvider);
        final celebrated =
            HiveBoxes.settings.stringsAt('celebratedBadges').toSet();
        final pending = wallet.unlockedBadgeIds
            .where((id) => !celebrated.contains(id))
            .toList();
        if (pending.isEmpty) return;
        BadgeInfo? badge;
        for (final b in DemoData.badges) {
          if (b.id == pending.first) badge = b;
        }
        if (badge == null) return;
        // Mark celebrated before showing so a rebuild never re-triggers it.
        HiveBoxes.settings.put(
          'celebratedBadges',
          [...celebrated, badge.id],
        );
        showAchievementDialog(context, badge);
      });
    });
  }

  void _shareProfile(UserProfile user, WalletState wallet) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Check out ${user.name} on CodeShikhi — learning programming '
            'in Bangla! Level ${wallet.level} · ${wallet.xp} XP · '
            '${wallet.streakDays}-day streak.',
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final cs = context.cs;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Log out?',
          style: AppText.h3.copyWith(color: cs.textPrimary),
        ),
        content: Text(
          'You will need to log in again to continue learning.',
          style: AppText.bodySmall.copyWith(color: cs.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Log out',
              style: AppText.label.copyWith(color: cs.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final user = ref.watch(authProvider).user ?? DemoData.me;
    final wallet = ref.watch(walletProvider);
    final unlockedBadges = DemoData.badges
        .where((b) => wallet.unlockedBadgeIds.contains(b.id))
        .toList();
    final myRank = DemoData.leaderboard.firstWhere(
      (e) => e.isMe,
      orElse: () => DemoData.leaderboard.first,
    );

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(
        title: 'Profile',
        showBack: false,
        actions: [
          IconButton(
            onPressed: () => _shareProfile(user, wallet),
            icon: Icon(AppIcons.share, color: cs.textPrimary),
            tooltip: 'Share profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Header: avatar, name, bio, edit.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CsAvatar(
                photoAsset: user.avatarPhoto,
                name: user.name,
                size: 72,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppText.h2.copyWith(color: cs.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.bio,
                      style: AppText.bodySmall
                          .copyWith(color: cs.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    CsButton(
                      label: 'Edit profile',
                      size: CsButtonSize.s,
                      fullWidth: false,
                      variant: CsButtonVariant.secondary,
                      icon: AppIcons.edit,
                      onPressed: () => context.push('/profile/edit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row — each tappable.
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.border),
            ),
            child: Row(
              children: [
                _statTap(
                  context,
                  value: '${wallet.xp}',
                  label: 'XP',
                  onTap: () => context.push('/profile/xp'),
                ),
                _statTap(
                  context,
                  value: '${wallet.streakDays}',
                  label: 'Day streak',
                  onTap: () => context.push('/profile/streak'),
                ),
                _statTap(
                  context,
                  value: '${wallet.volts}',
                  label: 'Volts',
                  onTap: () => context.push('/profile/volts'),
                ),
                _statTap(
                  context,
                  value: '1',
                  label: 'Certificates',
                  onTap: () =>
                      context.push('/my-courses/certificates'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Badges preview.
          CsSectionHeader(
            title: 'Badges',
            actionLabel: 'View all',
            onAction: () => context.push('/profile/badges'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => context.push('/profile/badges'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.border),
              ),
              child: Row(
                children: [
                  ...unlockedBadges.take(4).map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CsBadgeImage(badge: b, size: 48),
                        ),
                      ),
                  const Spacer(),
                  Text(
                    '${unlockedBadges.length} of ${DemoData.badges.length} unlocked',
                    style: AppText.caption
                        .copyWith(color: cs.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Leaderboard preview.
          CsSectionHeader(
            title: 'Leaderboard',
            actionLabel: 'View all',
            onAction: () => context.push('/profile/leaderboard'),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context,
            icon: AppIcons.trophy,
            title: "You're #${myRank.rank} this week",
            subtitle: '${myRank.xp} XP — keep climbing!',
            onTap: () => context.push('/profile/leaderboard'),
          ),
          const SizedBox(height: 24),
          // Learning report.
          CsSectionHeader(title: 'Learning report'),
          const SizedBox(height: 12),
          _menuCard(
            context,
            icon: AppIcons.chart,
            title: 'This week: 12 lessons · 6.5 hours',
            subtitle: 'See your progress, best day and insights',
            onTap: () => context.push('/profile/report'),
          ),
          const SizedBox(height: 24),
          // Menu rows.
          _menuCard(
            context,
            icon: AppIcons.receipt,
            title: 'My orders',
            onTap: () => context.push('/profile/orders'),
          ),
          const SizedBox(height: 8),
          _menuCard(
            context,
            icon: AppIcons.crown,
            title: 'Subscription',
            subtitle: wallet.isPro ? 'Pro member' : 'Free plan',
            onTap: () => context.push('/payments/subscription'),
          ),
          const SizedBox(height: 8),
          _menuCard(
            context,
            icon: AppIcons.settings,
            title: 'Settings',
            onTap: () => context.push('/profile/settings'),
          ),
          const SizedBox(height: 8),
          _menuCard(
            context,
            icon: AppIcons.info,
            title: 'Help center',
            onTap: () => context.push('/settings/help'),
          ),
          const SizedBox(height: 8),
          _menuCard(
            context,
            icon: AppIcons.gift,
            title: 'Invite friends',
            subtitle: 'Earn 50 Volts per friend',
            onTap: () => context.push('/settings/invite'),
          ),
          const SizedBox(height: 8),
          _menuCard(
            context,
            icon: AppIcons.logout,
            title: 'Log out',
            danger: true,
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _statTap(
    BuildContext context, {
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: CsStatItem(value: value, label: label),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool danger = false,
    required VoidCallback onTap,
  }) {
    final cs = context.cs;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: danger ? cs.dangerSoft : cs.sunken,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: danger ? cs.danger : cs.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.label.copyWith(
                      color: danger ? cs.danger : cs.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppText.caption
                          .copyWith(color: cs.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (!danger)
              Icon(
                AppIcons.chevronRight,
                size: 20,
                color: cs.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
