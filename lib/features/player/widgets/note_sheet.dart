import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_text_field.dart';

/// A single lesson note: free text + the video timestamp it was taken at.
class LessonNote {
  const LessonNote({required this.text, required this.timeLabel});

  factory LessonNote.fromJson(Map<String, dynamic> json) => LessonNote(
        text: json['text'] as String? ?? '',
        timeLabel: json['timeLabel'] as String? ?? '0:00',
      );

  final String text;
  final String timeLabel;

  Map<String, dynamic> toJson() => {'text': text, 'timeLabel': timeLabel};
}

/// Notes storage. The Hive box 'notes' is opened lazily on first use
/// (key `lesson_<id>` -> List of note maps). On web, notes live in
/// memory only for the session.
class NotesStore {
  NotesStore._();

  static final Map<String, List<LessonNote>> _memory = {};
  static Box<dynamic>? _box;

  static String _key(String lessonId) => 'lesson_$lessonId';

  static Future<List<LessonNote>> notesFor(String lessonId) async {
    if (kIsWeb) return List.of(_memory[_key(lessonId)] ?? []);
    _box ??= await Hive.openBox<dynamic>('notes');
    final raw = _box!.get(_key(lessonId));
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => LessonNote.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> addNote(String lessonId, LessonNote note) async {
    if (kIsWeb) {
      _memory.putIfAbsent(_key(lessonId), () => []).add(note);
      return;
    }
    _box ??= await Hive.openBox<dynamic>('notes');
    final notes = await notesFor(lessonId)..add(note);
    await _box!.put(
      _key(lessonId),
      notes.map((n) => n.toJson()).toList(),
    );
  }
}

/// Add-note sheet [E05]: a text field + Save. Returns the entered text,
/// or null when dismissed.
class NoteSheet extends StatefulWidget {
  const NoteSheet({super.key, required this.timeLabel});

  final String timeLabel;

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

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
            'Add note',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'At ${widget.timeLabel} in this lesson',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 16),
          CsTextField(
            controller: _controller,
            hint: 'Write your note…',
            maxLines: 4,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          CsButton(
            label: 'Save note',
            onPressed: _controller.text.trim().isEmpty ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// Opens the add-note sheet. Returns the saved note text, or null.
Future<String?> showNoteSheet(
  BuildContext context, {
  required String timeLabel,
}) {
  return showCsSheet<String>(
    context,
    NoteSheet(timeLabel: timeLabel),
  );
}
