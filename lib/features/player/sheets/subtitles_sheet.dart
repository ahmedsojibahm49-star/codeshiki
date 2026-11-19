import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_sheet.dart';

const List<String> kSubtitleOptions = ['Off', 'English', 'Bangla'];

/// Subtitles sheet [E22]. Demo: the choice is kept as local player state
/// (no subtitle tracks exist on the sample videos).
class SubtitlesSheet extends StatelessWidget {
  const SubtitlesSheet({super.key, required this.current});

  final String current;

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
            'Subtitles',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          for (final option in kSubtitleOptions)
            InkWell(
              onTap: () => Navigator.of(context).pop(option),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: AppText.body.copyWith(
                          color: cs.textPrimary,
                        ),
                      ),
                    ),
                    if (option == current)
                      Icon(
                        AppIcons.checkBold,
                        size: 22,
                        color: cs.accent,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens the subtitles sheet. Returns the chosen option, or null when
/// dismissed.
Future<String?> showSubtitlesSheet(
  BuildContext context, {
  required String current,
}) {
  return showCsSheet<String>(
    context,
    SubtitlesSheet(current: current),
  );
}
