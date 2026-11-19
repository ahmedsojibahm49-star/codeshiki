import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';

/// File drawer [F13]: lists the project's files, switches the active file
/// on tap, and adds a new file via a name prompt.
class FileDrawer extends StatelessWidget {
  const FileDrawer({
    super.key,
    required this.projectTitle,
    required this.files,
    required this.activeIndex,
    required this.onSelect,
    required this.onAddFile,
  });

  final String projectTitle;
  final List<ProjectFile> files;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<String> onAddFile;

  Future<void> _promptNewFile(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New file'),
        content: CsTextField(
          label: 'File name',
          hint: 'e.g. helpers.js',
          controller: controller,
          prefixIcon: AppIcons.document,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.isNotEmpty) onAddFile(name);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Drawer(
      backgroundColor: cs.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Files',
                    style: AppText.h3.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    projectTitle,
                    style: AppText.bodySmall.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  final active = index == activeIndex;
                  return ListTile(
                    leading: Icon(
                      active ? AppIcons.documentBold : AppIcons.document,
                      size: 22,
                      color: active ? cs.accent : cs.textSecondary,
                    ),
                    title: Text(
                      file.name,
                      style: AppText.body.copyWith(
                        color:
                            active ? cs.accent : cs.textPrimary,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    selected: active,
                    selectedTileColor: cs.sunken,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelect(index);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CsButton(
                label: 'New file',
                icon: AppIcons.plus,
                variant: CsButtonVariant.secondary,
                size: CsButtonSize.m,
                onPressed: () => _promptNewFile(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
