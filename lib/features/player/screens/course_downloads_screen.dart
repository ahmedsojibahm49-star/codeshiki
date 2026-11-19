import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';
import '../../../widgets/cs_toast.dart';
import '../player_helpers.dart';

/// Per-course downloads [C16]: video lessons with download states +
/// "Download all".
class CourseDownloadsScreen extends ConsumerStatefulWidget {
  const CourseDownloadsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDownloadsScreen> createState() =>
      _CourseDownloadsScreenState();
}

class _CourseDownloadsScreenState
    extends ConsumerState<CourseDownloadsScreen> {
  bool _downloadingAll = false;

  Future<void> _downloadAll(List<Lesson> videos) async {
    if (_downloadingAll) return;
    final downloads = ref.read(downloadsProvider.notifier);
    final pending = videos
        .where(
          (l) =>
              !downloads.isDownloaded(l.id) &&
              !downloads.isDownloading(l.id),
        )
        .toList();
    if (pending.isEmpty) {
      showCsToast(context, 'All videos already downloaded');
      return;
    }
    setState(() => _downloadingAll = true);
    var failed = 0;
    for (final lesson in pending) {
      try {
        await downloads.downloadLesson(lesson);
      } catch (_) {
        failed++;
      }
      if (!mounted) return;
    }
    if (!mounted) return;
    setState(() => _downloadingAll = false);
    showCsToast(
      context,
      failed == 0
          ? 'All videos downloaded'
          : 'Downloaded with $failed failure${failed == 1 ? '' : 's'}',
      isError: failed > 0,
    );
  }

  Future<void> _toggleDownload(Lesson lesson) async {
    final downloads = ref.read(downloadsProvider.notifier);
    if (downloads.isDownloaded(lesson.id)) {
      await downloads.removeDownload(lesson.id);
      if (mounted) showCsToast(context, 'Download removed');
      return;
    }
    if (downloads.isDownloading(lesson.id)) return;
    showCsToast(context, 'Downloading…');
    try {
      await downloads.downloadLesson(lesson);
      if (mounted) showCsToast(context, 'Downloaded');
    } catch (_) {
      if (mounted) {
        showCsToast(context, 'Download failed — try again', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = DemoData.courseById(widget.courseId);
    if (course == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Downloads'),
        body: CsEmptyState(
          icon: AppIcons.download,
          title: 'Course not found',
          body: 'This course does not exist in the demo catalog.',
          actionLabel: 'Back to Home',
          onAction: () => context.go('/home'),
        ),
      );
    }
    final cs = context.cs;
    final videos =
        course.allLessons.where((l) => l.isVideo).toList();
    final downloadsState = ref.watch(downloadsProvider);
    final downloadedCount = videos
        .where((l) => downloadsState.downloadedPaths.containsKey(l.id))
        .length;

    return Scaffold(
      appBar: CsTopBar(title: 'Downloads'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: AppText.h3.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '$downloadedCount of ${videos.length} videos · '
                  'Total ${demoSizeLabel(videos.length)}',
                  style: AppText.bodySmall.copyWith(
                    color: cs.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                CsButton(
                  label: _downloadingAll
                      ? 'Downloading…'
                      : 'Download all',
                  icon: AppIcons.downloadBold,
                  loading: _downloadingAll,
                  size: CsButtonSize.m,
                  onPressed: downloadedCount == videos.length
                      ? null
                      : () => _downloadAll(videos),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: videos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lesson = videos[index];
                final downloaded = downloadsState.downloadedPaths
                    .containsKey(lesson.id);
                final downloading = downloadsState.downloadingIds
                    .contains(lesson.id);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.raised,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.borderHairline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        downloaded
                            ? AppIcons.checkBold
                            : AppIcons.video,
                        size: 22,
                        color: downloaded ? cs.success : cs.accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: AppText.label.copyWith(
                                color: cs.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${lesson.durationMin} min · '
                              '${downloading ? 'Downloading…' : downloaded ? 'Downloaded' : demoSizeLabel()}',
                              style: AppText.caption.copyWith(
                                color: cs.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (downloading)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          onPressed: () => _toggleDownload(lesson),
                          tooltip: downloaded
                              ? 'Remove download'
                              : 'Download',
                          icon: Icon(
                            downloaded
                                ? AppIcons.trash
                                : AppIcons.download,
                            color: downloaded
                                ? cs.danger
                                : cs.textPrimary,
                          ),
                        ),
                    ],
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
