import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../code_storage.dart';
import '../problems_data.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/console_sheet.dart';
import '../widgets/editor_settings_sheet.dart';
import '../widgets/file_drawer.dart';
import '../widgets/key_row.dart';
import '../widgets/limit_sheet.dart';
import '../widgets/rename_dialog.dart';
import '../widgets/share_sheet.dart';

/// Full-screen code editor [F03] — a TOP-LEVEL route (`/editor/:projectId`)
/// with NO bottom nav and NO tab shell.
///
/// The code area is an [Expanded] widget that fills all remaining height
/// below the file tabs. The extra-key row lives in the Scaffold's
/// `bottomNavigationBar`, which the Scaffold keeps above the keyboard.
///
/// Project resolution order: demo projects → practice-problem projects
/// → the user's own Hive projects → stored whole-project overrides
/// (edited contents / renames / added files) applied on top.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  Timer? _autosaveTimer;

  CodeProject? _project;
  Map<String, String> _contents = {};
  int _activeFile = 0;
  EditorSettings _settings = const EditorSettings();
  bool _loading = true;
  bool _notFound = false;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _settings = CodeStorage.loadEditorSettings();
    unawaited(_resolveProject());
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    // Best-effort final save (fire-and-forget: dispose cannot await).
    if (_project != null) unawaited(_persist());
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Project resolution + persistence
  // ---------------------------------------------------------------------------

  Future<void> _resolveProject() async {
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
      // Stored edits (contents / title / added files) win over the base.
      final override = await CodeStorage.loadOverride(widget.projectId);
      if (override != null) project = override;
    }
    if (!mounted) return;
    if (project == null || project.files.isEmpty) {
      setState(() {
        _loading = false;
        _notFound = true;
      });
      return;
    }
    _contents = {
      for (final f in project.files) f.name: f.content,
    };
    _controller.value = TextEditingValue(
      text: _contents[project.files.first.name] ?? '',
      selection: const TextSelection.collapsed(offset: 0),
    );
    unawaited(CodeStorage.saveLastProjectId(widget.projectId));
    setState(() {
      _project = project;
      _loading = false;
    });
  }

  CodeProject _copyProject({String? title, List<ProjectFile>? files}) {
    final project = _project!;
    return CodeProject(
      id: project.id,
      title: title ?? project.title,
      language: project.language,
      files: files ?? project.files,
      lastEdited: 'Edited just now',
      runOutput: project.runOutput,
      tests: project.tests,
    );
  }

  void _saveCurrentFile() {
    final project = _project;
    if (project == null || project.files.isEmpty) return;
    _contents[project.files[_activeFile].name] = _controller.text;
  }

  /// Persists the current project (edited contents, title, added files)
  /// as a whole-project override, and updates the myProjects entry when
  /// the project is one of the user's own.
  Future<void> _persist() async {
    final project = _project;
    if (project == null) return;
    _saveCurrentFile();
    final updated = CodeProject(
      id: project.id,
      title: project.title,
      language: project.language,
      files: [
        for (final f in project.files)
          ProjectFile(
            name: f.name,
            content: _contents[f.name] ?? f.content,
          ),
      ],
      lastEdited: 'Edited just now',
      runOutput: project.runOutput,
      tests: project.tests,
    );
    _project = updated;
    await CodeStorage.saveOverride(updated);
    await CodeStorage.updateMyProject(updated);
  }

  void _onTextChanged(String _) {
    if (!_settings.autosave) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(
      const Duration(milliseconds: 800),
      () => unawaited(_persist()),
    );
  }

  // ---------------------------------------------------------------------------
  // File switching / editing
  // ---------------------------------------------------------------------------

  void _switchFile(int index) {
    final project = _project;
    if (project == null || index == _activeFile) return;
    _saveCurrentFile();
    final name = project.files[index].name;
    _controller.value = TextEditingValue(
      text: _contents[name] ?? '',
      selection: const TextSelection.collapsed(offset: 0),
    );
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() => _activeFile = index);
    unawaited(_persist());
  }

  void _addFile(String name) {
    final project = _project;
    if (project == null) return;
    var fileName = name.trim();
    if (fileName.isEmpty) return;
    final existing = project.files.map((f) => f.name).toSet();
    var suffix = 2;
    final base = fileName;
    while (existing.contains(fileName)) {
      fileName = '$base ($suffix)';
      suffix++;
    }
    _saveCurrentFile();
    final files = [
      ...project.files,
      ProjectFile(name: fileName, content: ''),
    ];
    _contents[fileName] = '';
    setState(() {
      _project = _copyProject(files: files);
      _activeFile = files.length - 1;
      _controller.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    });
    unawaited(_persist());
    showCsToast(context, 'File "$fileName" added');
  }

  void _insert(String text) {
    final selection = _controller.selection;
    final start =
        selection.isValid ? selection.start : _controller.text.length;
    final end = selection.isValid ? selection.end : _controller.text.length;
    final newText = _controller.text.replaceRange(start, end, text);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
    _focusNode.requestFocus();
    _onTextChanged(newText);
  }

  void _insertTab() => _insert(' ' * _settings.tabSize);

  // ---------------------------------------------------------------------------
  // Run (simulated demo) + menu actions
  // ---------------------------------------------------------------------------

  Future<void> _run() async {
    final project = _project;
    if (_running || project == null) return;
    if (CodeStorage.runsToday() >= CodeStorage.dailyRunLimit) {
      await showLimitSheet(context);
      return;
    }
    setState(() => _running = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    CodeStorage.incrementRuns();
    setState(() => _running = false);
    await _persist();
    if (!mounted) return;
    await showConsoleSheet(
      context,
      outputLines: project.runOutput.split('\n'),
      tests: project.tests,
    );
  }

  Future<void> _rename() async {
    final project = _project;
    if (project == null) return;
    final name = await showRenameDialog(context, project.title);
    if (name == null || !mounted) return;
    setState(() => _project = _copyProject(title: name));
    await _persist();
    if (!mounted) return;
    showCsToast(context, 'Project renamed to "$name"');
  }

  void _openSettings() {
    showEditorSettingsSheet(
      context,
      onChanged: (settings) => setState(() => _settings = settings),
    );
  }

  CsScheme _editorScheme(BuildContext context) {
    switch (_settings.theme) {
      case 'light':
        return CsScheme.light();
      case 'dark':
        return CsScheme.dark();
      default:
        return context.cs;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    if (_loading) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Editor'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_notFound || _project == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Editor'),
        body: CsEmptyState(
          icon: AppIcons.code,
          title: 'Project not found',
          body:
              'This project does not exist or was removed. Go back and pick '
              'another project.',
          actionLabel: 'Go back',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    final project = _project!;
    final editorScheme = _editorScheme(context);

    return Scaffold(
      key: _scaffoldKey,
      // resizeToAvoidBottomInset keeps bottomNavigationBar (the extra-key
      // row) above the on-screen keyboard.
      resizeToAvoidBottomInset: true,
      backgroundColor: editorScheme.synEditorBg,
      appBar: CsTopBar(
        title: project.title,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CsButton(
              label: _running ? 'Running…' : 'Run',
              icon: AppIcons.playBold,
              size: CsButtonSize.s,
              fullWidth: false,
              loading: _running,
              onPressed: _running ? null : _run,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(AppIcons.more, color: cs.textPrimary),
            tooltip: 'More options',
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  unawaited(_rename());
                case 'share':
                  unawaited(showShareSheet(context, project));
                case 'settings':
                  _openSettings();
                case 'files':
                  _scaffoldKey.currentState?.openDrawer();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(AppIcons.edit, size: 20, color: cs.textPrimary),
                    const SizedBox(width: 12),
                    const Text('Rename'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(AppIcons.share, size: 20, color: cs.textPrimary),
                    const SizedBox(width: 12),
                    const Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(AppIcons.settings, size: 20, color: cs.textPrimary),
                    const SizedBox(width: 12),
                    const Text('Editor settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'files',
                child: Row(
                  children: [
                    Icon(AppIcons.folder, size: 20, color: cs.textPrimary),
                    const SizedBox(width: 12),
                    const Text('Files'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: FileDrawer(
        projectTitle: project.title,
        files: project.files,
        activeIndex: _activeFile,
        onSelect: _switchFile,
        onAddFile: _addFile,
      ),
      body: Column(
        children: [
          // File tabs row (horizontal scrollable).
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(bottom: BorderSide(color: cs.borderHairline)),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              itemCount: project.files.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final file = project.files[index];
                final active = index == _activeFile;
                return Material(
                  color: active ? cs.sunken : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _switchFile(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            active
                                ? AppIcons.documentBold
                                : AppIcons.document,
                            size: 16,
                            color: active ? cs.accent : cs.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            file.name,
                            style: AppText.label.copyWith(
                              color: active ? cs.accent : cs.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // THE CODE AREA — Expanded: fills the whole remaining screen.
          Expanded(
            child: CodeEditorWidget(
              controller: _controller,
              focusNode: _focusNode,
              scrollController: _scrollController,
              fontSize: _settings.fontSize,
              scheme: editorScheme,
              onChanged: _onTextChanged,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ExtraKeyRow(
        onInsert: _insert,
        onTab: _insertTab,
        onRun: _run,
        running: _running,
      ),
    );
  }
}
