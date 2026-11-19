import 'package:material_ui/material_ui.dart';

import '../../../theme/app_icons.dart';
import '../../../widgets/cs_text_field.dart';

/// Rename dialog [F05]. Returns the trimmed new title, or null when the
/// user cancels or leaves the field empty. The caller renames the project
/// locally and persists it.
Future<String?> showRenameDialog(
  BuildContext context,
  String currentTitle,
) {
  return showDialog<String>(
    context: context,
    builder: (context) => RenameDialog(currentTitle: currentTitle),
  );
}

class RenameDialog extends StatefulWidget {
  const RenameDialog({super.key, required this.currentTitle});

  final String currentTitle;

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    Navigator.of(context).pop(name.isEmpty ? null : name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename project'),
      content: CsTextField(
        label: 'Project name',
        controller: _controller,
        prefixIcon: AppIcons.edit,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
