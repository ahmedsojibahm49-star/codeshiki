import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_sheet.dart';

/// All tags a question can carry.
const List<String> communityTags = [
  'react',
  'python',
  'javascript',
  'dsa',
  'flutter',
  'java',
  'css',
  'firebase',
];

/// Multi-select tag picker. Returns the picked tags, or null on dismiss.
Future<List<String>?> showTagPickerSheet(
  BuildContext context, {
  List<String> initial = const [],
}) {
  return showCsSheet<List<String>>(
    context,
    TagPickerSheet(initial: initial),
  );
}

class TagPickerSheet extends StatefulWidget {
  const TagPickerSheet({super.key, this.initial = const []});

  final List<String> initial;

  @override
  State<TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<TagPickerSheet> {
  late final Set<String> _selected = {...widget.initial};

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
            'Pick tags',
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Tags help the right people find your question.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: communityTags
                .map(
                  (tag) => CsFilterChip(
                    label: tag,
                    selected: _selected.contains(tag),
                    onTap: () => setState(() {
                      if (!_selected.remove(tag)) _selected.add(tag);
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          CsButton(
            label: _selected.isEmpty
                ? 'Done'
                : 'Done (${_selected.length})',
            onPressed: () =>
                Navigator.of(context).pop(_selected.toList()),
          ),
        ],
      ),
    );
  }
}
