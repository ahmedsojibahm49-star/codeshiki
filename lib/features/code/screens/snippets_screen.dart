import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../code_storage.dart';
import '../widgets/syntax_highlighter.dart';

/// One reusable code snippet.
class DemoSnippet {
  const DemoSnippet({
    required this.title,
    required this.language,
    required this.code,
  });

  final String title;
  final String language;
  final String code;
}

/// Snippets [F15] (tab-nested; coordinator wires the route): 4 demo
/// snippets with a highlighted read-only preview, Copy, and "Open in
/// editor". Users can add their own snippets with a simple form.
class SnippetsScreen extends StatefulWidget {
  const SnippetsScreen({super.key});

  @override
  State<SnippetsScreen> createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends State<SnippetsScreen> {
  final List<DemoSnippet> _snippets = [
    const DemoSnippet(
      title: 'Debounce function',
      language: 'JavaScript',
      code: '''function debounce(fn, delay) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

// Usage: wait 300ms after the last keystroke.
const onSearch = debounce((q) => fetchResults(q), 300);
''',
    ),
    const DemoSnippet(
      title: 'Fetch with retry',
      language: 'JavaScript',
      code: '''async function fetchWithRetry(url, retries = 3) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const res = await fetch(url);
      if (res.ok) return res.json();
    } catch (e) {
      if (attempt === retries) throw e;
    }
    await new Promise((r) => setTimeout(r, 1000 * attempt));
  }
}
''',
    ),
    const DemoSnippet(
      title: 'Binary search',
      language: 'Python',
      code: '''def binary_search(nums, target):
    left, right = 0, len(nums) - 1
    while left <= right:
        mid = (left + right) // 2
        if nums[mid] == target:
            return mid
        if nums[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1
''',
    ),
    const DemoSnippet(
      title: 'Sort by key',
      language: 'Python',
      code: '''students = [
    {"name": "Rahim", "xp": 1240},
    {"name": "Arif", "xp": 1680},
    {"name": "Nusrat", "xp": 1420},
]

# Highest XP first.
ranked = sorted(students, key=lambda s: s["xp"], reverse=True)
for s in ranked:
    print(s["name"], s["xp"])
''',
    ),
  ];

  void _openSnippet(DemoSnippet snippet) {
    showCsSheet<void>(
      context,
      _SnippetSheet(
        snippet: snippet,
        onOpenInEditor: () => _openInEditor(snippet),
      ),
    );
  }

  Future<void> _openInEditor(DemoSnippet snippet) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = switch (snippet.language) {
      'Python' => 'snippet.py',
      'Java' => 'Snippet.java',
      _ => 'snippet.js',
    };
    final project = CodeProject(
      id: 'snippet-$stamp',
      title: snippet.title,
      language: snippet.language,
      lastEdited: 'Edited just now',
      files: [ProjectFile(name: fileName, content: snippet.code)],
      runOutput: 'Snippet opened in the editor.\n\n'
          'Tap Run to see its demo output.',
      tests: const [],
    );
    await CodeStorage.addMyProject(project);
    if (!mounted) return;
    Navigator.of(context).pop();
    context.push('/editor/${project.id}');
  }

  Future<void> _showNewSnippetForm() async {
    final titleController = TextEditingController();
    final codeController = TextEditingController();
    var language = 'JavaScript';
    final created = await showCsSheet<bool>(
      context,
      StatefulBuilder(
        builder: (context, setSheetState) {
          final cs = context.cs;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New snippet',
                  style: AppText.h3.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 16),
                CsTextField(
                  label: 'Title',
                  hint: 'e.g. Shuffle an array',
                  controller: titleController,
                ),
                const SizedBox(height: 12),
                Text(
                  'Language',
                  style: AppText.label.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['JavaScript', 'Python', 'Java'].map((lang) {
                    final selected = language == lang;
                    return ChoiceChip(
                      label: Text(lang),
                      selected: selected,
                      selectedColor: cs.sunken,
                      labelStyle: AppText.label.copyWith(
                        color: selected ? cs.accent : cs.textSecondary,
                      ),
                      onSelected: (_) =>
                          setSheetState(() => language = lang),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                CsTextField(
                  label: 'Code',
                  hint: 'Paste or write the code here',
                  controller: codeController,
                  maxLines: 6,
                ),
                const SizedBox(height: 16),
                CsButton(
                  label: 'Save snippet',
                  size: CsButtonSize.m,
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        codeController.text.trim().isEmpty) {
                      showCsToast(
                        context,
                        'Add a title and some code first',
                        isError: true,
                      );
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
    if (created == true && mounted) {
      setState(() {
        _snippets.add(
          DemoSnippet(
            title: titleController.text.trim(),
            language: language,
            code: codeController.text,
          ),
        );
      });
      showCsToast(context, 'Snippet saved');
    }
    titleController.dispose();
    codeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CsTopBar(
        title: 'Snippets',
        actions: [
          IconButton(
            onPressed: _showNewSnippetForm,
            icon: const Icon(AppIcons.plus),
            tooltip: 'New snippet',
          ),
        ],
      ),
      body: _snippets.isEmpty
          ? CsEmptyState(
              icon: AppIcons.codeCircle,
              title: 'No snippets yet',
              body: 'Save the code you reuse — it will show up here.',
              actionLabel: 'New snippet',
              onAction: _showNewSnippetForm,
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: _snippets.length,
              itemBuilder: (context, index) {
                final snippet = _snippets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SnippetRow(
                    snippet: snippet,
                    onTap: () => _openSnippet(snippet),
                  ),
                );
              },
            ),
    );
  }
}

class _SnippetRow extends StatelessWidget {
  const _SnippetRow({required this.snippet, required this.onTap});

  final DemoSnippet snippet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final preview = snippet.code.split('\n').take(2).join('\n');
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.borderHairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      snippet.title,
                      style: AppText.label.copyWith(
                        color: cs.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cs.sunken,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      snippet.language,
                      style: AppText.caption.copyWith(
                        color: cs.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: AppText.code.copyWith(
                      color: cs.textPrimary,
                    ),
                    children: SyntaxHighlighter.highlight(preview, cs),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnippetSheet extends StatelessWidget {
  const _SnippetSheet({
    required this.snippet,
    required this.onOpenInEditor,
  });

  final DemoSnippet snippet;
  final VoidCallback onOpenInEditor;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              snippet.title,
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              snippet.language,
              style: AppText.bodySmall.copyWith(
                color: cs.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.synEditorBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.borderHairline),
                ),
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: AppText.code.copyWith(
                        color: cs.textPrimary,
                      ),
                      children: SyntaxHighlighter.highlight(
                        snippet.code,
                        cs,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CsButton(
                    label: 'Copy',
                    icon: AppIcons.copy,
                    variant: CsButtonVariant.secondary,
                    size: CsButtonSize.m,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: snippet.code),
                      );
                      if (!context.mounted) return;
                      showCsToast(context, 'Snippet copied');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CsButton(
                    label: 'Open in editor',
                    icon: AppIcons.code,
                    size: CsButtonSize.m,
                    onPressed: onOpenInEditor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
