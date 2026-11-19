import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../code_storage.dart';
import '../problems_data.dart';
import '../widgets/syntax_highlighter.dart';

/// Public project page [F17] (`/code/project/:projectId`): title, author,
/// description, stars, read-only highlighted code preview, Fork + Run.
///
/// Resolution mirrors the editor: demo projects → problem projects →
/// the user's own projects → stored overrides.
class ProjectPageScreen extends StatefulWidget {
  const ProjectPageScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectPageScreen> createState() => _ProjectPageScreenState();
}

class _ProjectPageScreenState extends State<ProjectPageScreen> {
  CodeProject? _project;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    CodeProject? project;
    for (final p in DemoData.codeProjects) {
      if (p.id == widget.projectId) project = p;
    }
    project ??= ProblemsData.problemProjects[widget.projectId];
    if (project == null) {
      final mine = await CodeStorage.loadMyProjects();
      for (final p in mine) {
        if (p.id == widget.projectId) project = p;
      }
    }
    if (project != null) {
      final override = await CodeStorage.loadOverride(widget.projectId);
      if (override != null) project = override;
    }
    if (!mounted) return;
    setState(() {
      _project = project;
      _loading = false;
    });
  }

  /// Deterministic star count from the id (stable across runs).
  int get _stars {
    var sum = 0;
    for (final unit in widget.projectId.codeUnits) {
      sum += unit;
    }
    return 40 + (sum % 200);
  }

  Future<void> _fork() async {
    final project = _project;
    if (project == null) return;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final fork = CodeProject(
      id: 'fork-$stamp',
      title: '${project.title} (fork)',
      language: project.language,
      files: project.files,
      lastEdited: 'Edited just now',
      runOutput: project.runOutput,
      tests: project.tests,
    );
    await CodeStorage.addMyProject(fork);
    if (!mounted) return;
    showCsToast(context, 'Forked to your projects');
    context.push('/editor/${fork.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    if (_loading) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Project'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final project = _project;
    if (project == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Project'),
        body: CsEmptyState(
          icon: AppIcons.code,
          title: 'Project not found',
          body: 'This public project does not exist or was removed.',
          actionLabel: 'Go back',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    final firstFile =
        project.files.isNotEmpty ? project.files.first : null;

    return Scaffold(
      appBar: const CsTopBar(title: 'Project'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            project.title,
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CsAvatar(
                photoAsset: DemoData.me.avatarPhoto,
                name: DemoData.me.name,
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DemoData.me.name,
                      style: AppText.label.copyWith(
                        color: cs.textPrimary,
                      ),
                    ),
                    Text(
                      project.lastEdited,
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.starBold,
                      size: 16,
                      color: cs.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_stars',
                      style: AppText.label.copyWith(
                        color: cs.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'A ${project.language} project with ${project.files.length} '
            '${project.files.length == 1 ? 'file' : 'files'}, built in '
            'CodeShikhi. Fork it to make your own copy, or run it to see '
            'the demo output.',
            style: AppText.body.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CsButton(
                  label: 'Fork',
                  icon: AppIcons.copy,
                  size: CsButtonSize.m,
                  onPressed: _fork,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CsButton(
                  label: 'Run',
                  icon: AppIcons.playBold,
                  variant: CsButtonVariant.secondary,
                  size: CsButtonSize.m,
                  onPressed: () =>
                      context.push('/editor/${project.id}'),
                ),
              ),
            ],
          ),
          if (firstFile != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  AppIcons.document,
                  size: 18,
                  color: cs.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  firstFile.name,
                  style: AppText.label.copyWith(
                    color: cs.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 320),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.synEditorBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.borderHairline),
              ),
              child: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    style: AppText.code.copyWith(
                      color: cs.textPrimary,
                    ),
                    children: SyntaxHighlighter.highlight(
                      firstFile.content,
                      cs,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (project.files.length > 1) ...[
            const SizedBox(height: 16),
            Text(
              'More files',
              style: AppText.label.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            ...project.files.skip(1).map((file) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.document,
                      size: 18,
                      color: cs.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      file.name,
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
