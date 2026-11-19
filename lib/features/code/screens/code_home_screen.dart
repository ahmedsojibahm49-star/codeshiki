import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_section_header.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../code_storage.dart';

/// Code tab root [F01]: continue card, my projects, new-project templates,
/// snippets + practice shortcuts, daily run limit indicator.
class CodeHomeScreen extends StatefulWidget {
  const CodeHomeScreen({super.key});

  @override
  State<CodeHomeScreen> createState() => _CodeHomeScreenState();
}

class _CodeHomeScreenState extends State<CodeHomeScreen> {
  List<CodeProject> _myProjects = [];
  String? _lastProjectId;
  bool _searching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final mine = await CodeStorage.loadMyProjects();
    final lastId = await CodeStorage.loadLastProjectId();
    if (!mounted) return;
    setState(() {
      _myProjects = mine;
      _lastProjectId = lastId;
    });
  }

  List<CodeProject> get _allProjects =>
      [...DemoData.codeProjects, ..._myProjects];

  List<CodeProject> get _visibleProjects {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _allProjects;
    return _allProjects
        .where((p) => p.title.toLowerCase().contains(query))
        .toList();
  }

  CodeProject? get _continueProject {
    final all = _allProjects;
    if (all.isEmpty) return null;
    if (_lastProjectId != null) {
      for (final p in all) {
        if (p.id == _lastProjectId) return p;
      }
    }
    return all.first;
  }

  void _openProject(CodeProject project) {
    context.push('/editor/${project.id}').then((_) => _load());
  }

  Future<void> _showTemplates() async {
    final kind = await showCsSheet<String>(
      context,
      const _TemplateSheet(),
    );
    if (kind == null || !mounted) return;
    final project = _projectFromTemplate(kind);
    await CodeStorage.addMyProject(project);
    if (!mounted) return;
    setState(() => _myProjects = [..._myProjects, project]);
    showCsToast(context, '"${project.title}" created');
    _openProject(project);
  }

  CodeProject _projectFromTemplate(String kind) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    switch (kind) {
      case 'react':
        return CodeProject(
          id: 'my-$stamp',
          title: 'React Counter',
          language: 'React',
          lastEdited: 'Edited just now',
          files: const [
            ProjectFile(
              name: 'App.jsx',
              content: '''import { useState } from 'react';
import './styles.css';

export default function App() {
  const [count, setCount] = useState(0);

  return (
    <main className="card">
      <h1>Counter</h1>
      <p className="count">{count}</p>
      <div className="row">
        <button onClick={() => setCount(count - 1)}>-</button>
        <button onClick={() => setCount(0)}>Reset</button>
        <button onClick={() => setCount(count + 1)}>+</button>
      </div>
    </main>
  );
}
''',
            ),
            ProjectFile(
              name: 'styles.css',
              content: '''.card {
  max-width: 320px;
  margin: 48px auto;
  padding: 24px;
  border-radius: 20px;
  background: #fff7f0;
  text-align: center;
  font-family: system-ui, sans-serif;
}

.count {
  font-size: 64px;
  font-weight: 800;
  color: #f97316;
}

.row {
  display: flex;
  gap: 12px;
  justify-content: center;
}
''',
            ),
          ],
          runOutput: '''✓ Build passed in 1.1s
✓ App rendered — Counter shows 0''',
          tests: const [
            CodeTestResult(name: 'renders initial count 0', passed: true),
            CodeTestResult(name: 'increments on + tap', passed: true),
            CodeTestResult(name: 'resets to 0', passed: true),
          ],
        );
      case 'python':
        return CodeProject(
          id: 'my-$stamp',
          title: 'Python Script',
          language: 'Python',
          lastEdited: 'Edited just now',
          files: const [
            ProjectFile(
              name: 'main.py',
              content: '''def main():
    print("Hello from CodeShikhi!")


if __name__ == "__main__":
    main()
''',
            ),
          ],
          runOutput: '''Hello from CodeShikhi!

✓ Program finished with exit code 0''',
          tests: const [
            CodeTestResult(name: 'prints greeting', passed: true),
          ],
        );
      case 'java':
      default:
        return CodeProject(
          id: 'my-$stamp',
          title: 'Java Class',
          language: 'Java',
          lastEdited: 'Edited just now',
          files: const [
            ProjectFile(
              name: 'Main.java',
              content: '''class Main {
    public static void main(String[] args) {
        System.out.println("Hello from CodeShikhi!");
    }
}
''',
            ),
          ],
          runOutput: '''Hello from CodeShikhi!

✓ Program finished with exit code 0''',
          tests: const [
            CodeTestResult(name: 'prints greeting', passed: true),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final runs = CodeStorage.runsToday();
    final limit = CodeStorage.dailyRunLimit;
    final continueProject = _continueProject;

    return Scaffold(
      appBar: CsTopBar(
        title: 'Code',
        showBack: false,
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) _query = '';
            }),
            icon: Icon(
              _searching ? AppIcons.close : AppIcons.search,
              color: cs.textPrimary,
            ),
            tooltip: 'Search projects',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (_searching) ...[
            CsTextField(
              hint: 'Search projects by title',
              prefixIcon: AppIcons.search,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
          ],
          // Daily run limit indicator.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.borderHairline),
            ),
            child: Row(
              children: [
                Icon(AppIcons.playCircle, size: 22, color: cs.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Runs today: $runs / $limit',
                    style: AppText.label.copyWith(color: cs.textPrimary),
                  ),
                ),
                Text(
                  runs >= limit ? 'Limit reached' : 'Free runs',
                  style: AppText.bodySmall.copyWith(
                    color: runs >= limit ? cs.danger : cs.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (continueProject != null && _query.isEmpty) ...[
            const SizedBox(height: 20),
            const CsSectionHeader(title: 'Continue'),
            const SizedBox(height: 12),
            _ContinueCard(
              project: continueProject,
              onTap: () => _openProject(continueProject),
            ),
          ],
          const SizedBox(height: 20),
          CsSectionHeader(
            title: 'My projects',
            actionLabel: 'New project',
            onAction: _showTemplates,
          ),
          const SizedBox(height: 12),
          if (_visibleProjects.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Text(
                'No projects match "$_query".',
                style: AppText.bodySmall.copyWith(
                  color: cs.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._visibleProjects.map(
              (project) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProjectRow(
                  project: project,
                  onTap: () => _openProject(project),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const CsSectionHeader(title: 'Practice & reuse'),
          const SizedBox(height: 12),
          _NavRow(
            icon: AppIcons.codeCircle,
            title: 'Snippets',
            subtitle: 'Reusable code, ready to copy',
            onTap: () => context.push('/code/snippets'),
          ),
          const SizedBox(height: 10),
          _NavRow(
            icon: AppIcons.target,
            title: 'Practice problems',
            subtitle: 'Solve problems, earn XP',
            onTap: () => context.push('/code/problems'),
          ),
          const SizedBox(height: 20),
          CsButton(
            label: 'New project',
            icon: AppIcons.plus,
            onPressed: _showTemplates,
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.project, required this.onTap});

  final CodeProject project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: cs.sunken,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.codeBold,
                  size: 24,
                  color: cs.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: AppText.label.copyWith(
                        color: cs.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${project.language} · ${project.lastEdited}',
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.playCircle,
                size: 28,
                color: cs.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({required this.project, required this.onTap});

  final CodeProject project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(AppIcons.code, size: 22, color: cs.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: AppText.label.copyWith(
                        color: cs.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _LangChip(label: project.language),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${project.lastEdited} · '
                            '${project.files.length} '
                            '${project.files.length == 1 ? 'file' : 'files'}',
                            style: AppText.caption.copyWith(
                              color: cs.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                size: 20,
                color: cs.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.sunken,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          color: cs.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: cs.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.label.copyWith(
                        color: cs.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                size: 20,
                color: cs.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateSheet extends StatelessWidget {
  const _TemplateSheet();

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
            'New project',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Start from a template, then make it yours.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 16),
          _TemplateRow(
            title: 'React Counter',
            subtitle: 'App.jsx + styles.css — a working counter',
            language: 'React',
            onTap: () => Navigator.of(context).pop('react'),
          ),
          _TemplateRow(
            title: 'Python Script',
            subtitle: 'main.py — a tiny starter script',
            language: 'Python',
            onTap: () => Navigator.of(context).pop('python'),
          ),
          _TemplateRow(
            title: 'Java Class',
            subtitle: 'Main.java — hello world, class style',
            language: 'Java',
            onTap: () => Navigator.of(context).pop('java'),
          ),
        ],
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({
    required this.title,
    required this.subtitle,
    required this.language,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.sunken,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(AppIcons.code, size: 22, color: cs.accent),
      ),
      title: Text(
        title,
        style: AppText.label.copyWith(color: cs.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: AppText.bodySmall.copyWith(color: cs.textSecondary),
      ),
      trailing: _LangChip(label: language),
      onTap: onTap,
    );
  }
}
