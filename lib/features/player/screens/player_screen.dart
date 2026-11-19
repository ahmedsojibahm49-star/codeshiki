import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

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
import '../sheets/speed_sheet.dart';
import '../sheets/subtitles_sheet.dart';
import '../video_source.dart';
import '../widgets/custom_player_controls.dart';
import '../widgets/lesson_tabs.dart';

/// Lesson player [E01] + in-place fullscreen [E02/E03].
///
/// Plays the downloaded file when one exists, otherwise streams the
/// lesson video. Quiz/code/reading lessons show an action card instead
/// of a video. Finishing a video marks the lesson complete and opens
/// the lesson-complete screen; leaving mid-lesson hands the position
/// to the mini player.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({
    super.key,
    required this.lessonId,
    this.courseId,
  });

  final String lessonId;
  final String? courseId;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Course? _course;
  Lesson? _lesson;
  Module? _module;

  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _videoError = false;
  bool _showControls = true;
  bool _isFullscreen = false;
  double _speed = 1.0;
  String _quality = 'Auto';
  String _subtitle = 'Off';
  bool _navigatedToComplete = false;
  Duration _lastPosition = Duration.zero;
  Timer? _hideTimer;
  PlayerNotifier? _playerNotifier;

  String get _qualityLabel =>
      _quality == 'Auto' ? 'Auto • 720p' : _quality;

  @override
  void initState() {
    super.initState();
    final resolved = resolveLesson(widget.lessonId, widget.courseId);
    _course = resolved.course;
    _lesson = resolved.lesson;
    _module = resolved.module;
    _playerNotifier = ref.read(playerProvider.notifier);
    if (_lesson != null && _lesson!.isVideo) {
      unawaited(_initVideo());
    }
  }

  Future<void> _initVideo() async {
    final lesson = _lesson;
    if (lesson == null) return;
    setState(() {
      _videoError = false;
      _initialized = false;
    });
    final downloadedPath =
        ref.read(downloadsProvider).downloadedPaths[lesson.id];
    final controller = controllerForVideo(
      localPath: downloadedPath,
      url: lesson.videoUrl,
    );
    _controller = controller;
    controller.addListener(_onVideoTick);
    try {
      await controller.initialize();
    } catch (_) {
      if (!mounted) return;
      setState(() => _videoError = true);
      return;
    }
    if (!mounted) return;
    // Resume where the mini player left off, if this is the same lesson.
    final saved = ref.read(playerProvider);
    if (saved.lessonId == lesson.id && saved.positionSec > 0) {
      await controller.seekTo(
        Duration(seconds: saved.positionSec.round()),
      );
    }
    // Now playing in the full player — the mini player stands down.
    ref.read(playerProvider.notifier).clear();
    await controller.play();
    if (!mounted) return;
    setState(() => _initialized = true);
    _scheduleHideControls();
  }

  void _onVideoTick() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    _lastPosition = controller.value.position;
    final duration = controller.value.duration;
    if (!_navigatedToComplete &&
        duration.inMilliseconds > 0 &&
        _lastPosition >= duration - const Duration(milliseconds: 300)) {
      _finishLesson();
    }
  }

  void _finishLesson() {
    final lesson = _lesson;
    final course = _course;
    if (lesson == null || course == null || _navigatedToComplete) return;
    _navigatedToComplete = true;
    ref
        .read(enrollmentProvider.notifier)
        .completeLesson(course.id, lesson.id);
    ref.read(playerProvider.notifier).clear();
    unawaited(_controller?.pause());
    if (!mounted) return;
    context.push(
      '/lesson-complete?lessonId=${lesson.id}&courseId=${course.id}',
    );
  }

  // ---------------------------------------------------------------------------
  // Fullscreen [E02/E03]
  // ---------------------------------------------------------------------------

  Future<void> _enterFullscreen() async {
    setState(() => _isFullscreen = true);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
  }

  Future<void> _exitFullscreen() async {
    setState(() => _isFullscreen = false);
    await _restorePortrait();
  }

  /// Restores portrait + the app's immersive mode (Android: status bar
  /// only, system nav hidden — same as main.dart applies on launch).
  Future<void> _restorePortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (defaultTargetPlatform == TargetPlatform.android) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      unawaited(_exitFullscreen());
    } else {
      unawaited(_enterFullscreen());
    }
  }

  // ---------------------------------------------------------------------------
  // Controls
  // ---------------------------------------------------------------------------

  void _scheduleHideControls() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      final controller = _controller;
      if (mounted &&
          controller != null &&
          controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHideControls();
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !_initialized) return;
    if (controller.value.isPlaying) {
      unawaited(controller.pause());
      setState(() => _showControls = true);
    } else {
      unawaited(controller.play());
      _scheduleHideControls();
    }
  }

  Future<void> _openSpeedSheet() async {
    final settings = await showSpeedSheet(
      context,
      currentSpeed: _speed,
      currentQuality: _quality,
    );
    if (settings == null) return;
    setState(() {
      _speed = settings.speed;
      _quality = settings.quality;
    });
    unawaited(_controller?.setPlaybackSpeed(settings.speed));
  }

  Future<void> _openSubtitlesSheet() async {
    final choice = await showSubtitlesSheet(context, current: _subtitle);
    if (choice == null || choice == _subtitle) return;
    setState(() => _subtitle = choice);
    if (mounted) showCsToast(context, 'Subtitles: $choice');
  }

  // ---------------------------------------------------------------------------
  // Download (fixes the Figma gap: E01 had no download button)
  // ---------------------------------------------------------------------------

  Future<void> _onDownloadTap() async {
    final lesson = _lesson;
    if (lesson == null) return;
    final downloads = ref.read(downloadsProvider.notifier);
    if (downloads.isDownloaded(lesson.id)) {
      final remove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Remove download?',
            style: AppText.h3.copyWith(color: context.cs.textPrimary),
          ),
          content: Text(
            '“${lesson.title}” will be deleted from this device. '
            'You can download it again any time.',
            style: AppText.bodySmall.copyWith(
              color: context.cs.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Remove',
                style: TextStyle(color: context.cs.danger),
              ),
            ),
          ],
        ),
      );
      if (remove == true) {
        await downloads.removeDownload(lesson.id);
        if (mounted) showCsToast(context, 'Download removed');
      }
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

  void _markReadingComplete() {
    final lesson = _lesson;
    final course = _course;
    if (lesson == null || course == null) return;
    ref
        .read(enrollmentProvider.notifier)
        .completeLesson(course.id, lesson.id);
    context.push(
      '/lesson-complete?lessonId=${lesson.id}&courseId=${course.id}',
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    // Never leave the app rotated after a popped fullscreen player.
    unawaited(_restorePortrait());
    // Leaving mid-lesson: hand the position to the mini player.
    final lesson = _lesson;
    final course = _course;
    if (!_navigatedToComplete &&
        lesson != null &&
        course != null &&
        lesson.isVideo &&
        _lastPosition.inSeconds > 5) {
      _playerNotifier?.setCurrent(
        lessonId: lesson.id,
        courseId: course.id,
        title: lesson.title,
        videoUrl: lesson.videoUrl,
        positionSec: _lastPosition.inSeconds.toDouble(),
      );
    }
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_onVideoTick);
      unawaited(controller.dispose());
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    final course = _course;
    if (lesson == null || course == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Lesson'),
        body: CsEmptyState(
          icon: AppIcons.video,
          title: 'Lesson not found',
          body: 'This lesson does not exist in the demo catalog.',
          actionLabel: 'Back to Home',
          onAction: () => context.go('/home'),
        ),
      );
    }

    if (_isFullscreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_exitFullscreen());
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: _buildVideoPlayer(fullscreen: true),
        ),
      );
    }

    final downloadsState = ref.watch(downloadsProvider);
    final downloaded =
        downloadsState.downloadedPaths.containsKey(lesson.id);
    final downloading = downloadsState.downloadingIds.contains(lesson.id);
    final cs = context.cs;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CsTopBar(
        title: lesson.title,
        actions: [
          if (lesson.isVideo)
            downloading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _onDownloadTap,
                    tooltip: downloaded
                        ? 'Downloaded — tap to remove'
                        : 'Download for offline',
                    icon: Icon(
                      downloaded
                          ? AppIcons.checkBold
                          : AppIcons.download,
                      color: downloaded ? cs.accent : cs.textPrimary,
                    ),
                  ),
          IconButton(
            onPressed: () =>
                _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'Lessons',
            icon: Icon(AppIcons.grid, color: cs.textPrimary),
          ),
        ],
      ),
      endDrawer: _LessonDrawer(
        course: course,
        module: _module,
        currentLessonId: lesson.id,
        onSelect: (selected) {
          Navigator.of(context).pop();
          if (selected.locked) {
            showCsToast(context, 'Locked lesson');
            return;
          }
          if (selected.id == lesson.id) return;
          context.pushReplacement(
            '/player/${selected.id}?courseId=${course.id}',
          );
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoArea(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: AppText.h3.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.instructor} · ${lesson.durationMin} min'
                  '${downloaded ? ' · Downloaded' : ''}',
                  style: AppText.bodySmall.copyWith(
                    color: cs.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LessonTabs(
              lesson: lesson,
              course: course,
              currentTimeLabel: () => formatDuration(_lastPosition),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    final lesson = _lesson!;
    if (!lesson.isVideo) return _buildTypeCard(lesson);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _buildVideoPlayer(fullscreen: false),
    );
  }

  Widget _buildVideoPlayer({required bool fullscreen}) {
    final controller = _controller;
    if (_videoError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AppIcons.warningBold,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load this video',
                style: AppText.body.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              CsButton(
                label: 'Retry',
                onPressed: () => unawaited(_initVideo()),
                size: CsButtonSize.m,
                fullWidth: false,
              ),
            ],
          ),
        ),
      );
    }
    if (controller == null || !_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio == 0
                    ? 16 / 9
                    : controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.isBuffering && _initialized) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (!_showControls && value.isPlaying) {
                  return const SizedBox.shrink();
                }
                return CustomPlayerControls(
                  value: value,
                  onPlayPause: _togglePlayPause,
                  onSeek: (position) {
                    unawaited(controller.seekTo(position));
                    _scheduleHideControls();
                  },
                  onSpeedTap: _openSpeedSheet,
                  onSubtitlesTap: _openSubtitlesSheet,
                  onFullscreenTap: _toggleFullscreen,
                  isFullscreen: _isFullscreen,
                  speedLabel: speedLabel(_speed),
                  qualityLabel: _qualityLabel,
                  subtitleLabel: _subtitle,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Action card for non-video lessons (quiz / code / reading).
  Widget _buildTypeCard(Lesson lesson) {
    final course = _course!;
    final cs = context.cs;
    final IconData icon;
    final String heading;
    final String body;
    final String cta;
    final VoidCallback onCta;
    if (lesson.isQuiz) {
      icon = AppIcons.target;
      heading = 'Quiz lesson';
      body =
          'Test what you learned in "${lesson.title}" — 10 questions, about 5 minutes.';
      cta = 'Start quiz';
      onCta = () => context.push(
            '/quiz/${lesson.id}?courseId=${course.id}',
          );
    } else if (lesson.isCode) {
      icon = AppIcons.code;
      heading = 'Coding lesson';
      body =
          'Open the editor and write real code for "${lesson.title}" — run it and check the tests.';
      cta = 'Open in editor';
      onCta = () => context.push(
            '/editor/${editorProjectForCourse(course.id)}',
          );
    } else {
      icon = AppIcons.documentText;
      heading = 'Reading lesson';
      body = lesson.description.isEmpty
          ? 'Read through "${lesson.title}" and mark it complete when you are done.'
          : lesson.description;
      cta = 'Mark as complete';
      onCta = _markReadingComplete;
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: cs.sunken,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: cs.accent),
            ),
            const SizedBox(height: 12),
            Text(
              heading,
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            CsButton(
              label: cta,
              onPressed: onCta,
              size: CsButtonSize.m,
              fullWidth: false,
              icon: lesson.isQuiz
                  ? AppIcons.playBold
                  : lesson.isCode
                      ? AppIcons.codeBold
                      : AppIcons.checkBold,
            ),
          ],
        ),
      ),
    );
  }
}

/// Lesson list drawer [E08]: all lessons of the course with
/// done / current / locked states.
class _LessonDrawer extends ConsumerWidget {
  const _LessonDrawer({
    required this.course,
    required this.module,
    required this.currentLessonId,
    required this.onSelect,
  });

  final Course course;
  final Module? module;
  final String currentLessonId;
  final ValueChanged<Lesson> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final enrollment = ref.watch(enrollmentProvider);
    final progress =
        ref.read(enrollmentProvider.notifier).progressFor(course.id);
    return Drawer(
      backgroundColor: cs.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: AppText.h3.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: cs.sunken,
                      valueColor: AlwaysStoppedAnimation(cs.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).round()}% complete',
                    style: AppText.caption.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final m in course.modules) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Text(
                        m.title,
                        style: AppText.label.copyWith(color: cs.accent),
                      ),
                    ),
                    for (final lesson in m.lessons)
                      _LessonDrawerRow(
                        lesson: lesson,
                        isCurrent: lesson.id == currentLessonId,
                        isDone: enrollment.completedLessonIds[course.id]
                                ?.contains(lesson.id) ??
                            false,
                        onTap: () => onSelect(lesson),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonDrawerRow extends StatelessWidget {
  const _LessonDrawerRow({
    required this.lesson,
    required this.isCurrent,
    required this.isDone,
    required this.onTap,
  });

  final Lesson lesson;
  final bool isCurrent;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final IconData icon;
    final Color iconColor;
    if (lesson.locked) {
      icon = AppIcons.lock;
      iconColor = cs.textTertiary;
    } else if (isDone) {
      icon = AppIcons.checkBold;
      iconColor = cs.success;
    } else if (isCurrent) {
      icon = AppIcons.playBold;
      iconColor = cs.accent;
    } else if (lesson.isQuiz) {
      icon = AppIcons.target;
      iconColor = cs.textSecondary;
    } else if (lesson.isCode) {
      icon = AppIcons.code;
      iconColor = cs.textSecondary;
    } else if (lesson.isReading) {
      icon = AppIcons.documentText;
      iconColor = cs.textSecondary;
    } else {
      icon = AppIcons.play;
      iconColor = cs.textSecondary;
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isCurrent ? cs.sunken : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: AppText.bodySmall.copyWith(
                      color: isCurrent
                          ? cs.textPrimary
                          : cs.textSecondary,
                      fontWeight:
                          isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${lesson.durationMin} min'
                    '${lesson.locked ? ' · Locked' : ''}',
                    style: AppText.caption.copyWith(
                      color: cs.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
