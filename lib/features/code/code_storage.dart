import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/hive_boxes.dart';
import '../../data/models.dart';

/// Editor preferences, persisted in the `settings` Hive box.
class EditorSettings {
  const EditorSettings({
    this.fontSize = 14,
    this.theme = 'follow',
    this.tabSize = 2,
    this.autosave = true,
  });

  /// Font size in logical pixels (12–20).
  final double fontSize;

  /// 'follow' (app theme) | 'light' | 'dark'.
  final String theme;

  /// Spaces inserted by the Tab key (2 or 4).
  final int tabSize;

  /// Persist edits automatically while typing.
  final bool autosave;

  EditorSettings copyWith({
    double? fontSize,
    String? theme,
    int? tabSize,
    bool? autosave,
  }) =>
      EditorSettings(
        fontSize: fontSize ?? this.fontSize,
        theme: theme ?? this.theme,
        tabSize: tabSize ?? this.tabSize,
        autosave: autosave ?? this.autosave,
      );
}

/// Local persistence for the Code feature.
///
/// * User-created projects (`myProjects`), whole-project edit overrides
///   (`projectOverrides`), solved problem ids and the last-opened project
///   live in a lazily opened `code` Hive box. On web Hive is skipped and
///   everything stays in memory for the session (per the feature brief).
/// * The daily run counter and editor settings live in the already-open
///   `settings` box (keys `runsToday` / `runsDate` / `editorFontSize` /
///   `editorTheme` / `editorTabSize` / `editorAutosave`).
class CodeStorage {
  CodeStorage._();

  static const String _boxName = 'code';
  static const String _myProjectsKey = 'myProjects';
  static const String _overridesKey = 'projectOverrides';
  static const String _solvedKey = 'solvedProblems';
  static const String _lastProjectKey = 'lastProjectId';

  static const int dailyRunLimit = 10;

  static Box<dynamic>? _box;

  /// In-memory fallback used on web (Hive box never opened there).
  static final Map<String, dynamic> _memory = {};

  static Future<Box<dynamic>?> _codeBox() async {
    if (kIsWeb) return null;
    if (_box != null && _box!.isOpen) return _box;
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<dynamic>(_boxName);
      return _box;
    }
    _box = await Hive.openBox<dynamic>(_boxName);
    return _box;
  }

  static Future<dynamic> _get(String key) async {
    final box = await _codeBox();
    if (box == null) return _memory[key];
    return box.get(key);
  }

  static Future<void> _put(String key, dynamic value) async {
    final box = await _codeBox();
    if (box == null) {
      _memory[key] = value;
      return;
    }
    await box.put(key, value);
  }

  static List<CodeProject> _parseProjects(dynamic value) {
    if (value is! List) return [];
    final projects = <CodeProject>[];
    for (final item in value) {
      if (item is Map) {
        try {
          projects.add(
            CodeProject.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          // Skip a single corrupt entry rather than losing the whole list.
        }
      }
    }
    return projects;
  }

  // ---------------------------------------------------------------------------
  // My projects
  // ---------------------------------------------------------------------------

  static Future<List<CodeProject>> loadMyProjects() async =>
      _parseProjects(await _get(_myProjectsKey));

  static Future<void> saveMyProjects(List<CodeProject> projects) async {
    await _put(
      _myProjectsKey,
      projects.map((p) => p.toJson()).toList(),
    );
  }

  static Future<void> addMyProject(CodeProject project) async {
    final projects = await loadMyProjects();
    projects.removeWhere((p) => p.id == project.id);
    projects.add(project);
    await saveMyProjects(projects);
  }

  /// Replaces the stored copy of [project] when it is one of the user's
  /// own projects; a no-op for demo / problem projects.
  static Future<void> updateMyProject(CodeProject project) async {
    final projects = await loadMyProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index == -1) return;
    projects[index] = project;
    await saveMyProjects(projects);
  }

  // ---------------------------------------------------------------------------
  // Whole-project overrides (edited contents, renames, added files)
  // ---------------------------------------------------------------------------

  static Future<Map<String, dynamic>> _loadOverrides() async {
    final value = await _get(_overridesKey);
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static Future<CodeProject?> loadOverride(String projectId) async {
    final overrides = await _loadOverrides();
    final raw = overrides[projectId];
    if (raw is Map) {
      try {
        return CodeProject.fromJson(Map<String, dynamic>.from(raw));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveOverride(CodeProject project) async {
    final overrides = await _loadOverrides();
    overrides[project.id] = project.toJson();
    await _put(_overridesKey, overrides);
  }

  // ---------------------------------------------------------------------------
  // Solved problems + last opened project
  // ---------------------------------------------------------------------------

  static Future<Set<String>> loadSolvedProblems() async {
    final value = await _get(_solvedKey);
    if (value is List) return value.map((e) => e.toString()).toSet();
    return {};
  }

  static Future<void> markSolved(String problemId) async {
    final solved = await loadSolvedProblems();
    solved.add(problemId);
    await _put(_solvedKey, solved.toList());
  }

  static Future<String?> loadLastProjectId() async {
    final value = await _get(_lastProjectKey);
    return value is String ? value : null;
  }

  static Future<void> saveLastProjectId(String projectId) async {
    await _put(_lastProjectKey, projectId);
  }

  // ---------------------------------------------------------------------------
  // Daily run counter (settings box, synchronous — box is open at startup)
  // ---------------------------------------------------------------------------

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Runs used today (0–10). Resets automatically when the date changes.
  static int runsToday() {
    final box = HiveBoxes.settings;
    final storedDate = box.get('runsDate') as String?;
    if (storedDate != _todayKey()) {
      box.put('runsDate', _todayKey());
      box.put('runsToday', 0);
      return 0;
    }
    return (box.get('runsToday') as num?)?.toInt() ?? 0;
  }

  /// Increments the counter and returns the new value.
  static int incrementRuns() {
    final next = runsToday() + 1;
    HiveBoxes.settings.put('runsToday', next);
    return next;
  }

  // ---------------------------------------------------------------------------
  // Editor settings (settings box, synchronous)
  // ---------------------------------------------------------------------------

  static EditorSettings loadEditorSettings() {
    final box = HiveBoxes.settings;
    final fontSize =
        (box.get('editorFontSize') as num?)?.toDouble() ?? 14.0;
    final theme = box.get('editorTheme') as String? ?? 'follow';
    final tabSize = (box.get('editorTabSize') as num?)?.toInt() ?? 2;
    final autosave = box.get('editorAutosave') as bool? ?? true;
    return EditorSettings(
      fontSize: fontSize.clamp(12.0, 20.0),
      theme: (theme == 'light' || theme == 'dark') ? theme : 'follow',
      tabSize: tabSize == 4 ? 4 : 2,
      autosave: autosave,
    );
  }

  static void saveEditorSettings(EditorSettings settings) {
    final box = HiveBoxes.settings;
    box.put('editorFontSize', settings.fontSize);
    box.put('editorTheme', settings.theme);
    box.put('editorTabSize', settings.tabSize);
    box.put('editorAutosave', settings.autosave);
  }
}
