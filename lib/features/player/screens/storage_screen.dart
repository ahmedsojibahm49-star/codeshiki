import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';
import '../../../widgets/cs_toast.dart';
import '../file_size.dart';
import '../player_helpers.dart';

/// Download storage overview [D10]: total size, per-course breakdown,
/// clear-all.
class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  int _realBytes = -1; // -1 = still measuring, 0 = none / web

  @override
  void initState() {
    super.initState();
    unawaited(_measureSizes());
  }

  Future<void> _measureSizes() async {
    final paths = ref.read(downloadsProvider).downloadedPaths;
    var total = 0;
    for (final path in paths.values) {
      total += await downloadedFileSize(path);
    }
    if (!mounted) return;
    setState(() => _realBytes = total);
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear all downloads?',
          style: AppText.h3.copyWith(color: context.cs.textPrimary),
        ),
        content: Text(
          'Every downloaded lesson will be deleted from this device.',
          style: AppText.bodySmall.copyWith(
            color: context.cs.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Clear all',
              style: TextStyle(color: context.cs.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final downloads = ref.read(downloadsProvider.notifier);
    final ids = List.of(ref.read(downloadsProvider).downloadedPaths.keys);
    for (final id in ids) {
      await downloads.removeDownload(id);
    }
    if (!mounted) return;
    setState(() => _realBytes = 0);
    showCsToast(context, 'All downloads cleared');
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final downloadsState = ref.watch(downloadsProvider);
    final cs = context.cs;
    final entries = <({Course course, Lesson lesson, String path})>[];
    for (final entry in downloadsState.downloadedPaths.entries) {
      final resolved = resolveLesson(entry.key);
      if (resolved.course != null && resolved.lesson != null) {
        entries.add(
          (
            course: resolved.course!,
            lesson: resolved.lesson!,
            path: entry.value,
          ),
        );
      }
    }
    final byCourse = <String, ({Course course, int count})>{};
    for (final entry in entries) {
      final existing = byCourse[entry.course.id];
      byCourse[entry.course.id] = (
        course: entry.course,
        count: (existing?.count ?? 0) + 1,
      );
    }

    // Real on-device size when measurable; otherwise the demo estimate.
    final String totalLabel;
    if (_realBytes < 0) {
      totalLabel = 'Measuring…';
    } else if (_realBytes > 0) {
      totalLabel = _formatBytes(_realBytes);
    } else {
      totalLabel = demoSizeLabel(entries.length);
    }

    return Scaffold(
      appBar: const CsTopBar(title: 'Storage'),
      body: entries.isEmpty
          ? const CsEmptyState(
              icon: AppIcons.folder,
              title: 'Nothing stored',
              body: 'Downloaded lessons will appear here with their '
                  'storage usage.',
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.raised,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.borderHairline),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        AppIcons.folderOpenBold,
                        size: 36,
                        color: cs.accent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        totalLabel,
                        style: AppText.h1.copyWith(color: cs.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entries.length} lesson'
                        '${entries.length == 1 ? '' : 's'} downloaded'
                        '${_realBytes > 0 ? '' : ' · estimated'}',
                        style: AppText.bodySmall.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'By course',
                  style: AppText.h3.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 12),
                for (final group in byCourse.values)
                  _CourseStorageRow(
                    course: group.course,
                    count: group.count,
                  ),
                const SizedBox(height: 32),
                CsButton(
                  label: 'Clear all downloads',
                  variant: CsButtonVariant.destructive,
                  icon: AppIcons.trash,
                  onPressed: _clearAll,
                ),
              ],
            ),
    );
  }
}

class _CourseStorageRow extends StatelessWidget {
  const _CourseStorageRow({required this.course, required this.count});

  final Course course;
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              width: 56,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              course.title,
              style: AppText.label.copyWith(color: cs.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count · ${demoSizeLabel(count)}',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
        ],
      ),
    );
  }
}
