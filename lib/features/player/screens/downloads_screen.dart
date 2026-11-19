import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';
import '../../../widgets/cs_toast.dart';
import '../player_helpers.dart';

/// Downloads list [D04]: every downloaded lesson, with play + delete.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsState = ref.watch(downloadsProvider);
    final cs = context.cs;
    final entries = <({Course course, Lesson lesson})>[];
    for (final lessonId in downloadsState.downloadedPaths.keys) {
      final resolved = resolveLesson(lessonId);
      if (resolved.course != null && resolved.lesson != null) {
        entries.add(
          (course: resolved.course!, lesson: resolved.lesson!),
        );
      }
    }

    return Scaffold(
      appBar: CsTopBar(
        title: 'Downloads',
        actions: [
          IconButton(
            onPressed: () =>
                context.push('/my-courses/downloads/storage'),
            tooltip: 'Storage',
            icon: Icon(AppIcons.folder, color: cs.textPrimary),
          ),
        ],
      ),
      body: entries.isEmpty
          ? CsEmptyState(
              icon: AppIcons.download,
              title: 'No downloads yet',
              body: 'Download lessons from the player to watch '
                  'them offline, even without internet.',
              actionLabel: 'Browse courses',
              onAction: () => context.go('/home'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _StorageRow(
                  count: entries.length,
                  onTap: () =>
                      context.push('/my-courses/downloads/storage'),
                ),
                const SizedBox(height: 16),
                for (final entry in entries) ...[
                  _DownloadRow(
                    course: entry.course,
                    lesson: entry.lesson,
                    onPlay: () => context.push(
                      '/player/${entry.lesson.id}'
                      '?courseId=${entry.course.id}',
                    ),
                    onDelete: () async {
                      await ref
                          .read(downloadsProvider.notifier)
                          .removeDownload(entry.lesson.id);
                      if (context.mounted) {
                        showCsToast(context, 'Download removed');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _StorageRow extends StatelessWidget {
  const _StorageRow({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.raised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.borderHairline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.sunken,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(AppIcons.folder, size: 22, color: cs.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storage',
                    style: AppText.label.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count lesson${count == 1 ? '' : 's'} · '
                    '${demoSizeLabel(count)} used',
                    style: AppText.caption.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: 20,
              color: cs.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadRow extends StatelessWidget {
  const _DownloadRow({
    required this.course,
    required this.lesson,
    required this.onPlay,
    required this.onDelete,
  });

  final Course course;
  final Lesson lesson;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.raised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.borderHairline),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              course.coverPhoto,
              width: 72,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: AppText.label.copyWith(color: cs.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  course.title,
                  style: AppText.caption.copyWith(
                    color: cs.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${lesson.durationMin} min · ${demoSizeLabel()}',
                  style: AppText.caption.copyWith(
                    color: cs.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPlay,
            tooltip: 'Play offline',
            icon: Icon(AppIcons.playBold, color: cs.accent),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Delete download',
            icon: Icon(AppIcons.trash, color: cs.danger),
          ),
        ],
      ),
    );
  }
}
