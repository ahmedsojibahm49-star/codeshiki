import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_toast.dart';

/// Playback settings chosen from the speed sheet.
class PlaybackSettings {
  const PlaybackSettings({required this.speed, required this.quality});

  final double speed;
  final String quality;
}

const List<double> kSpeedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
const List<String> kQualityOptions = ['Auto', '720p', '480p', '360p'];

String speedLabel(double speed) {
  final text = speed.toStringAsFixed(speed % 1 == 0 ? 0 : 2);
  return '${text}x';
}

/// Speed + quality sheet [E21]. Speed rows apply immediately; quality
/// rows are demo labels — tapping one updates the label and toasts.
class SpeedSheet extends StatefulWidget {
  const SpeedSheet({
    super.key,
    required this.currentSpeed,
    required this.currentQuality,
  });

  final double currentSpeed;
  final String currentQuality;

  @override
  State<SpeedSheet> createState() => _SpeedSheetState();
}

class _SpeedSheetState extends State<SpeedSheet> {
  late double _speed;
  late String _quality;

  @override
  void initState() {
    super.initState();
    _speed = widget.currentSpeed;
    _quality = widget.currentQuality;
  }

  void _pickSpeed(double speed) {
    setState(() => _speed = speed);
    Navigator.of(context).pop(
      PlaybackSettings(speed: _speed, quality: _quality),
    );
  }

  void _pickQuality(String quality) {
    setState(() => _quality = quality);
    showCsToast(context, 'Demo quality: $quality');
    Navigator.of(context).pop(
      PlaybackSettings(speed: _speed, quality: _quality),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Playback speed',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final speed in kSpeedOptions)
                _OptionChip(
                  label: speedLabel(speed),
                  selected: speed == _speed,
                  onTap: () => _pickSpeed(speed),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Quality',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Demo — quality is a label only; the stream stays the same.',
            style: AppText.caption.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 12),
          for (final quality in kQualityOptions)
            _QualityRow(
              label: quality,
              selected: quality == _quality,
              onTap: () => _pickQuality(quality),
            ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.sunken,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppText.label.copyWith(
            color: selected ? cs.onPrimary : cs.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  const _QualityRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.body.copyWith(color: cs.textPrimary),
              ),
            ),
            if (selected)
              Icon(AppIcons.checkBold, size: 22, color: cs.accent),
          ],
        ),
      ),
    );
  }
}

/// Opens the speed/quality sheet. Returns the chosen settings, or null
/// when dismissed.
Future<PlaybackSettings?> showSpeedSheet(
  BuildContext context, {
  required double currentSpeed,
  required String currentQuality,
}) {
  return showCsSheet<PlaybackSettings>(
    context,
    SpeedSheet(
      currentSpeed: currentSpeed,
      currentQuality: currentQuality,
    ),
  );
}
