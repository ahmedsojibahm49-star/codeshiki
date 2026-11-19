import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../i18n/app_strings.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';

/// The app shell: tab navigation + mini player.
///
/// PLATFORM NAV RULE (user's explicit rule):
/// - Android + Web: Material 3 [NavigationBar] DOCKED at the bottom.
/// - iOS: FLOATING glass pill tab island, exactly as Figma designed
///   (height 64, radius 32, side margins 20, bottom margin 12 above the
///   home indicator, surface at 0.85 opacity + backdrop blur).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double _pillHeight = 64;
  static const double _pillSideMargin = 20;
  static const double _pillBottomMargin = 12;
  static const double _miniPlayerHeight = 56;

  bool get _useDocked =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final hasMiniPlayer = player.hasCurrent;

    if (_useDocked) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasMiniPlayer) const _MiniPlayerBar(),
            _DockedNavBar(navigationShell: navigationShell),
          ],
        ),
      );
    }

    // iOS floating pill: Stack the pill over the body; pad the body so
    // content is never hidden behind the pill (or the mini player).
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final pillBottom = _pillBottomMargin + bottomSafe;
    final miniPlayerBottom = pillBottom + _pillHeight + 8;
    final bodyBottomPadding = pillBottom +
        _pillHeight +
        (hasMiniPlayer ? _miniPlayerHeight + 8 : 0);

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bodyBottomPadding),
            child: navigationShell,
          ),
          if (hasMiniPlayer)
            Positioned(
              left: _pillSideMargin,
              right: _pillSideMargin,
              bottom: miniPlayerBottom,
              height: _miniPlayerHeight,
              child: const _MiniPlayerBar(floating: true),
            ),
          Positioned(
            left: _pillSideMargin,
            right: _pillSideMargin,
            bottom: pillBottom,
            height: _pillHeight,
            child: _FloatingPill(navigationShell: navigationShell),
          ),
        ],
      ),
    );
  }
}

/// Android/Web docked bottom navigation.
class _DockedNavBar extends StatelessWidget {
  const _DockedNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: navigationShell.goBranch,
      destinations: [
        NavigationDestination(
          icon: const Icon(AppIcons.tabHome),
          selectedIcon: const Icon(AppIcons.tabHomeBold),
          label: context.tr('home'),
        ),
        NavigationDestination(
          icon: const Icon(AppIcons.tabCourses),
          selectedIcon: const Icon(AppIcons.tabCoursesBold),
          label: context.tr('myCourses'),
        ),
        NavigationDestination(
          icon: const Icon(AppIcons.tabCode),
          selectedIcon: const Icon(AppIcons.tabCodeBold),
          label: context.tr('code'),
        ),
        NavigationDestination(
          icon: const Icon(AppIcons.tabCommunity),
          selectedIcon: const Icon(AppIcons.tabCommunityBold),
          label: context.tr('community'),
        ),
        NavigationDestination(
          icon: const Icon(AppIcons.tabProfile),
          selectedIcon: const Icon(AppIcons.tabProfileBold),
          label: context.tr('profile'),
        ),
      ],
    );
  }
}

/// iOS floating glass pill tab island.
class _FloatingPill extends StatelessWidget {
  const _FloatingPill({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: cs.borderHairline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _PillItem(
                icon: AppIcons.tabHome,
                boldIcon: AppIcons.tabHomeBold,
                label: context.tr('home'),
                selected: navigationShell.currentIndex == 0,
                onTap: () => navigationShell.goBranch(0),
              ),
              _PillItem(
                icon: AppIcons.tabCourses,
                boldIcon: AppIcons.tabCoursesBold,
                label: context.tr('myCourses'),
                selected: navigationShell.currentIndex == 1,
                onTap: () => navigationShell.goBranch(1),
              ),
              _PillItem(
                icon: AppIcons.tabCode,
                boldIcon: AppIcons.tabCodeBold,
                label: context.tr('code'),
                selected: navigationShell.currentIndex == 2,
                onTap: () => navigationShell.goBranch(2),
              ),
              _PillItem(
                icon: AppIcons.tabCommunity,
                boldIcon: AppIcons.tabCommunityBold,
                label: context.tr('community'),
                selected: navigationShell.currentIndex == 3,
                onTap: () => navigationShell.goBranch(3),
              ),
              _PillItem(
                icon: AppIcons.tabProfile,
                boldIcon: AppIcons.tabProfileBold,
                label: context.tr('profile'),
                selected: navigationShell.currentIndex == 4,
                onTap: () => navigationShell.goBranch(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillItem extends StatelessWidget {
  const _PillItem({
    required this.icon,
    required this.boldIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData boldIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final color = selected ? cs.accent : cs.textSecondary;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? boldIcon : icon, size: 24, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppText.caption.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact mini-player bar shown above the nav when a lesson is playing
/// (or paused mid-lesson). Tapping it returns to the player screen.
class _MiniPlayerBar extends ConsumerWidget {
  const _MiniPlayerBar({this.floating = false});

  final bool floating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final player = ref.watch(playerProvider);
    if (!player.hasCurrent) return const SizedBox.shrink();

    final bar = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/player/${player.lessonId}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cs.raised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.borderHairline),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  player.isPlaying ? AppIcons.pauseBold : AppIcons.playBold,
                  size: 18,
                  color: cs.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  player.title ?? '',
                  style: AppText.label.copyWith(color: cs.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).togglePlaying(),
                icon: Icon(
                  player.isPlaying ? AppIcons.pause : AppIcons.play,
                  color: cs.textPrimary,
                ),
                iconSize: 22,
                splashRadius: 20,
              ),
              IconButton(
                onPressed: () => ref.read(playerProvider.notifier).clear(),
                icon: Icon(AppIcons.close, color: cs.textSecondary),
                iconSize: 22,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );

    if (!floating) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: bar,
      );
    }
    return bar;
  }
}
