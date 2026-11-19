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
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/tag_picker_sheet.dart';

/// Ask a question [G04]: title, body, optional code block [G05],
/// tag picker [G06], similar questions [G07].
class AskQuestionScreen extends ConsumerStatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  ConsumerState<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends ConsumerState<AskQuestionScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _codeController = TextEditingController();

  bool _includeCode = false;
  List<String> _tags = [];
  String _titleQuery = '';

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Questions sharing a keyword (3+ letters) with the typed title.
  List<ForumQuestion> get _similar {
    final words = _titleQuery
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.length > 2)
        .toSet();
    if (words.isEmpty) return const [];
    return DemoData.questions.where((q) {
      final haystack =
          '${q.title} ${q.body} ${q.tags.join(' ')}'.toLowerCase();
      return words.any(haystack.contains);
    }).toList();
  }

  Future<void> _pickTags() async {
    final picked =
        await showTagPickerSheet(context, initial: _tags);
    if (picked != null) setState(() => _tags = picked);
  }

  void _post() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      showCsToast(
        context,
        'Please add a title and a description',
        isError: true,
      );
      return;
    }
    final code = _codeController.text.trim();
    final fullBody = _includeCode && code.isNotEmpty
        ? '$body\n\n```\n$code\n```'
        : body;
    ref.read(forumProvider.notifier).addQuestion(title, fullBody, _tags);
    showCsToast(context, 'Question posted');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final similar = _similar;

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Ask a question'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          CsTextField(
            label: 'Title',
            hint: 'What do you want to know?',
            controller: _titleController,
            onChanged: (value) => setState(() => _titleQuery = value),
          ),
          if (similar.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Similar questions',
              style: AppText.label.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            ...similar.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () =>
                      context.push('/community/question/${q.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            q.title,
                            style: AppText.bodySmall
                                .copyWith(color: cs.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          AppIcons.chevronRight,
                          size: 18,
                          color: cs.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          CsTextField(
            label: 'Description',
            hint: 'Describe your problem in detail…',
            controller: _bodyController,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          // Code block toggle [G05].
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.border),
            ),
            child: Row(
              children: [
                Icon(AppIcons.code, size: 20, color: cs.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Include a code block',
                    style: AppText.label.copyWith(color: cs.textPrimary),
                  ),
                ),
                Switch(
                  value: _includeCode,
                  activeThumbColor: cs.primary,
                  onChanged: (value) =>
                      setState(() => _includeCode = value),
                ),
              ],
            ),
          ),
          if (_includeCode) ...[
            const SizedBox(height: 16),
            CsTextField(
              label: 'Code',
              hint: 'Paste your code here…',
              controller: _codeController,
              maxLines: 6,
            ),
          ],
          const SizedBox(height: 16),
          // Tag picker [G06].
          OutlinedButton.icon(
            onPressed: _pickTags,
            icon: Icon(AppIcons.plus, size: 18, color: cs.accent),
            label: Text(
              _tags.isEmpty ? 'Pick tags' : 'Tags: ${_tags.join(', ')}',
              style: AppText.label.copyWith(color: cs.accent),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              side: BorderSide(color: cs.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CsButton(
            label: 'Post question',
            icon: AppIcons.send,
            onPressed: _post,
          ),
        ],
      ),
    );
  }
}
