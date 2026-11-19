import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_top_bar.dart';

/// Leaderboard [H07/H08] — tab-nested (coordinator wires the route).
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const _friendNames = {
    'Arif Hossain',
    'Maliha Akter',
    'Tanvir Hasan',
  };

  List<LeaderboardEntry> get _sorted {
    final list = [...DemoData.leaderboard];
    list.sort((a, b) => b.xp.compareTo(a.xp));
    return list;
  }

  String _medalAsset(int rank) {
    final id = switch (rank) {
      1 => 'medal_gold',
      2 => 'medal_silver',
      _ => 'medal_bronze',
    };
    return DemoData.badges
        .firstWhere((b) => b.id == id)
        .assetPath;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final sorted = _sorted;
    final friends =
        sorted.where((e) => e.isMe || _friendNames.contains(e.name)).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: cs.canvas,
        appBar: const CsTopBar(title: 'Leaderboard'),
        body: Column(
          children: [
            TabBar(
              labelColor: cs.textPrimary,
              unselectedLabelColor: cs.textSecondary,
              indicatorColor: cs.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Weekly'),
                Tab(text: 'Friends'),
                Tab(text: 'All time'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _weeklyTab(context, sorted),
                  _listTab(context, friends),
                  _listTab(context, sorted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weeklyTab(BuildContext context, List<LeaderboardEntry> sorted) {
    final top3 = sorted.take(3).toList();
    final rest = sorted.skip(3).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // Top-3 podium: 2nd — 1st — 3rd.
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _podiumSlot(context, top3[1], 2)),
            Expanded(child: _podiumSlot(context, top3[0], 1)),
            Expanded(child: _podiumSlot(context, top3[2], 3)),
          ],
        ),
        const SizedBox(height: 24),
        ...rest.map((e) => _row(context, e)),
      ],
    );
  }

  Widget _listTab(BuildContext context, List<LeaderboardEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: entries.length,
      itemBuilder: (context, index) => _row(context, entries[index]),
    );
  }

  Widget _podiumSlot(BuildContext context, LeaderboardEntry entry, int rank) {
    final cs = context.cs;
    final big = rank == 1;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: CsAvatar(
                photoAsset: entry.photo,
                name: entry.name,
                size: big ? 72 : 56,
              ),
            ),
            Image.asset(
              _medalAsset(rank),
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.name,
          style: AppText.label.copyWith(
            color: cs.textPrimary,
            fontSize: big ? 15 : 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry.xp} XP',
          style: AppText.caption.copyWith(color: cs.textSecondary),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: big ? cs.primary : cs.sunken,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '#$rank',
            style: AppText.caption.copyWith(
              color: big ? cs.onPrimary : cs.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, LeaderboardEntry entry) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: entry.isMe
              ? cs.primary.withValues(alpha: 0.08)
              : cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: entry.isMe ? cs.primary : cs.border,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '#${entry.rank}',
                style: AppText.label.copyWith(
                  color: entry.isMe ? cs.accent : cs.textSecondary,
                ),
              ),
            ),
            CsAvatar(
              photoAsset: entry.photo,
              name: entry.name,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.isMe ? '${entry.name} (You)' : entry.name,
                style: AppText.label.copyWith(color: cs.textPrimary),
              ),
            ),
            Text(
              '${entry.xp} XP',
              style: AppText.label.copyWith(color: cs.accent),
            ),
          ],
        ),
      ),
    );
  }
}
