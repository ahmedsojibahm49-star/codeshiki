import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import 'note_sheet.dart';

/// Lesson detail tabs under the player: Description / Notes / Resources /
/// Discussion [E04–E07].
class LessonTabs extends StatefulWidget {
  const LessonTabs({
    super.key,
    required this.lesson,
    required this.course,
    required this.currentTimeLabel,
  });

  final Lesson lesson;
  final Course course;

  /// Current video position as a "m:ss" label, used as the note timestamp.
  final String Function() currentTimeLabel;

  @override
  State<LessonTabs> createState() => _LessonTabsState();
}

class _LessonTabsState extends State<LessonTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<LessonNote> _notes = [];
  bool _notesLoaded = false;

  final List<_Comment> _comments = [
    const _Comment(
      authorName: 'Arif Hossain',
      authorPhoto: 'assets/photos/person-male-cap.jpg',
      text: 'Finally understood this part — the example at 3:20 made it click!',
      timeLabel: '2h ago',
    ),
    const _Comment(
      authorName: 'Jannat Ferdous',
      authorPhoto: 'assets/photos/person-female-bd.jpg',
      text: 'Can someone explain the last example again? I got lost at the end.',
      timeLabel: '5h ago',
    ),
  ];
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await NotesStore.notesFor(widget.lesson.id);
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _notesLoaded = true;
    });
  }

  Future<void> _addNote() async {
    final text = await showNoteSheet(
      context,
      timeLabel: widget.currentTimeLabel(),
    );
    if (text == null || text.trim().isEmpty) return;
    final note = LessonNote(
      text: text.trim(),
      timeLabel: widget.currentTimeLabel(),
    );
    await NotesStore.addNote(widget.lesson.id, note);
    if (!mounted) return;
    setState(() => _notes.add(note));
    showCsToast(context, 'Note saved');
  }

  void _postComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(
        0,
        _Comment(
          authorName: DemoData.me.name,
          authorPhoto: DemoData.me.avatarPhoto,
          text: text,
          timeLabel: 'Just now',
        ),
      );
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: cs.accent,
          unselectedLabelColor: cs.textSecondary,
          indicatorColor: cs.primary,
          labelStyle: AppText.label,
          unselectedLabelStyle: AppText.label,
          tabs: const [
            Tab(text: 'Description'),
            Tab(text: 'Notes'),
            Tab(text: 'Resources'),
            Tab(text: 'Discussion'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _DescriptionTab(lesson: widget.lesson, course: widget.course),
              _NotesTab(
                notes: _notes,
                loaded: _notesLoaded,
                onAddNote: _addNote,
              ),
              _ResourcesTab(lesson: widget.lesson),
              _DiscussionTab(
                comments: _comments,
                controller: _commentController,
                onPost: _postComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  const _DescriptionTab({required this.lesson, required this.course});

  final Lesson lesson;
  final Course course;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final description = lesson.description.isEmpty
        ? 'In this lesson from "${course.title}", ${course.instructor} '
            'walks you through "${lesson.title}" step by step, with '
            'examples in Bangla. Follow along, take notes, and try the '
            'practice task at the end.'
        : lesson.description;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: AppText.body.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: AppIcons.clock,
            label: 'Duration',
            value: '${lesson.durationMin} min',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: AppIcons.teacher,
            label: 'Instructor',
            value: course.instructor,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: AppIcons.book,
            label: 'Course',
            value: course.title,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.accent),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppText.bodySmall.copyWith(color: cs.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({
    required this.notes,
    required this.loaded,
    required this.onAddNote,
  });

  final List<LessonNote> notes;
  final bool loaded;
  final VoidCallback onAddNote;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      children: [
        Expanded(
          child: !loaded
              ? const Center(child: CircularProgressIndicator())
              : notes.isEmpty
                  ? _EmptyNotes(onAddNote: onAddNote)
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: notes.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.raised,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cs.borderHairline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    AppIcons.note,
                                    size: 16,
                                    color: cs.accent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    note.timeLabel,
                                    style: AppText.caption.copyWith(
                                      color: cs.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                note.text,
                                style: AppText.bodySmall.copyWith(
                                  color: cs.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: CsButton(
            label: 'Add note',
            icon: AppIcons.plus,
            variant: CsButtonVariant.secondary,
            size: CsButtonSize.m,
            onPressed: onAddNote,
          ),
        ),
      ],
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onAddNote});

  final VoidCallback onAddNote;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.sunken,
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.note, size: 32, color: cs.accent),
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture key ideas while you watch — notes are saved '
              'with their video timestamp.',
              style:
                  AppText.bodySmall.copyWith(color: cs.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CsButton(
              label: 'Add your first note',
              onPressed: onAddNote,
              size: CsButtonSize.m,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final resources = [
      _Resource(
        icon: AppIcons.documentText,
        title: 'Slides — ${lesson.title}.pdf',
        subtitle: 'PDF · 2.4 MB',
      ),
      const _Resource(
        icon: AppIcons.code,
        title: 'Starter code.zip',
        subtitle: 'ZIP · 1.1 MB',
      ),
      const _Resource(
        icon: AppIcons.document,
        title: 'Cheat sheet.pdf',
        subtitle: 'PDF · 860 KB',
      ),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: resources.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final resource = resources[index];
        final cs = context.cs;
        return InkWell(
          onTap: () =>
              showCsToast(context, 'Demo: file would open'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.raised,
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
                  child: Icon(
                    resource.icon,
                    size: 22,
                    color: cs.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
                        style: AppText.label.copyWith(
                          color: cs.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resource.subtitle,
                        style: AppText.caption.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.download,
                  size: 20,
                  color: cs.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Resource {
  const _Resource({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _Comment {
  const _Comment({
    required this.authorName,
    required this.authorPhoto,
    required this.text,
    required this.timeLabel,
  });

  final String authorName;
  final String authorPhoto;
  final String text;
  final String timeLabel;
}

class _DiscussionTab extends StatefulWidget {
  const _DiscussionTab({
    required this.comments,
    required this.controller,
    required this.onPost,
  });

  final List<_Comment> comments;
  final TextEditingController controller;
  final VoidCallback onPost;

  @override
  State<_DiscussionTab> createState() => _DiscussionTabState();
}

class _DiscussionTabState extends State<_DiscussionTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: widget.comments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final comment = widget.comments[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CsAvatar(
                    photoAsset: comment.authorPhoto,
                    name: comment.authorName,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                comment.authorName,
                                style: AppText.label.copyWith(
                                  color: cs.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              comment.timeLabel,
                              style: AppText.caption.copyWith(
                                color: cs.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.text,
                          style: AppText.bodySmall.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: CsTextField(
                  controller: widget.controller,
                  hint: 'Ask a question…',
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: widget.controller.text.trim().isEmpty
                    ? null
                    : widget.onPost,
                style: IconButton.styleFrom(backgroundColor: cs.primary),
                icon: Icon(AppIcons.sendBold, color: cs.onPrimary),
                tooltip: 'Post comment',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
