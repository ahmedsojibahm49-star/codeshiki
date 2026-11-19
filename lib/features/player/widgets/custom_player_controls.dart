import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_toast.dart';
import '../player_helpers.dart';

/// Hand-built video overlay controls (orange accent, dark scrim).
///
/// Rendered on top of the [VideoPlayer] when the overlay is visible.
/// The parent owns the controller and all state; this widget only renders
/// [value] and forwards taps.
class CustomPlayerControls extends StatelessWidget {
  const CustomPlayerControls({
    super.key,
    required this.value,
    required this.onPlayPause,
    required this.onSeek,
    required this.onSpeedTap,
    required this.onSubtitlesTap,
    required this.onFullscreenTap,
    required this.isFullscreen,
    required this.speedLabel,
    required this.qualityLabel,
    required this.subtitleLabel,
  });

  final VideoPlayerValue value;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onSpeedTap;
  final VoidCallback onSubtitlesTap;
  final VoidCallback onFullscreenTap;
  final bool isFullscreen;
  final String speedLabel;
  final String qualityLabel;
  final String subtitleLabel;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final duration = value.duration;
    final position = value.position;
    final max = duration.inMilliseconds.toDouble();
    final current = position.inMilliseconds.toDouble().clamp(0.0, max);
    final hasDuration = duration.inMilliseconds > 0;

    return Stack(
      children: [
        // Dark scrim so controls stay readable over any frame.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.65),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
        // Center play / pause.
        Center(
          child: GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                value.isPlaying ? AppIcons.pauseBold : AppIcons.playBold,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Bottom bar: seek slider + time + actions.
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: cs.primary,
                  inactiveTrackColor:
                      Colors.white.withValues(alpha: 0.35),
                  thumbColor: cs.primary,
                  overlayColor: cs.primary.withValues(alpha: 0.25),
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: hasDuration ? current : 0,
                  max: hasDuration ? max : 1,
                  onChanged: hasDuration
                      ? (v) =>
                          onSeek(Duration(milliseconds: v.round()))
                      : null,
                ),
              ),
              Row(
                children: [
                  _ControlButton(
                    icon: value.isPlaying
                        ? AppIcons.pauseBold
                        : AppIcons.playBold,
                    onTap: onPlayPause,
                    tooltip: value.isPlaying ? 'Pause' : 'Play',
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${formatDuration(position)} / '
                    '${formatDuration(duration)}',
                    style: AppText.caption.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  _LabelButton(
                    label: speedLabel,
                    onTap: onSpeedTap,
                    tooltip: 'Playback speed',
                  ),
                  const SizedBox(width: 4),
                  _LabelButton(
                    label: qualityLabel,
                    onTap: () => showCsToast(
                      context,
                      'Demo quality: Auto',
                    ),
                    tooltip: 'Quality',
                  ),
                  const SizedBox(width: 4),
                  _ControlButton(
                    icon: AppIcons.translate,
                    onTap: onSubtitlesTap,
                    tooltip: 'Subtitles: $subtitleLabel',
                    active: subtitleLabel != 'Off',
                  ),
                  _ControlButton(
                    icon: isFullscreen
                        ? AppIcons.fullscreenAlt
                        : AppIcons.fullscreen,
                    onTap: onFullscreenTap,
                    tooltip: isFullscreen
                        ? 'Exit fullscreen'
                        : 'Fullscreen',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      iconSize: 22,
      splashRadius: 20,
      icon: Icon(
        icon,
        color: active ? AppColors.teal : Colors.white,
      ),
    );
  }
}

class _LabelButton extends StatelessWidget {
  const _LabelButton({
    required this.label,
    required this.onTap,
    required this.tooltip,
  });

  final String label;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: AppText.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
