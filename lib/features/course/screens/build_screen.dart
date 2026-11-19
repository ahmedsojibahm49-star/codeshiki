import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';

/// "What you'll build" [C14]: 4 project cards.
class BuildScreen extends StatelessWidget {
  const BuildScreen({super.key, required this.courseId});

  final String courseId;

  static const List<(IconData, String, String, String)> _projects = [
    (
      AppIcons.globe,
      'Portfolio Website',
      'A personal portfolio with your projects, skills and contact form — '
          'deployed live for the world to see.',
      'Module 1 · Beginner',
    ),
    (
      AppIcons.checkSquare,
      'Todo App with Auth',
      'A full todo app with login, saved data and filters — your first '
          'real app with users and state.',
      'Module 2 · Intermediate',
    ),
    (
      AppIcons.card,
      'E-commerce Storefront',
      'Product listings, a working cart and a checkout flow — the kind of '
          'project employers ask about.',
      'Module 3 · Intermediate',
    ),
    (
      AppIcons.documentText,
      'Blog CMS',
      'Create, edit and publish posts with a real database behind it — '
          'the capstone project of the course.',
      'Module 3 · Advanced',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final course = DemoData.courseById(courseId);
    final firstLesson = course?.allLessons.firstOrNull;

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: "What you'll build"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learn by building',
              style: AppText.h2.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              course == null
                  ? 'Every module ends with a project you can add to your portfolio.'
                  : 'Every module of "${course.title}" ends with a project '
                      'you can add to your portfolio.',
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 20),
            for (final (icon, title, description, meta) in _projects) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.borderHairline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.sunken,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 24, color: cs.accent),
                    ),
                    const SizedBox(width: 14),
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
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: AppText.bodySmall.copyWith(
                              color: cs.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            meta,
                            style: AppText.caption.copyWith(
                              color: cs.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            CsButton(
              label: 'Start building',
              icon: AppIcons.play,
              onPressed: firstLesson == null
                  ? () => context.pop()
                  : () => context.push(
                        '/player/${firstLesson.id}?courseId=$courseId',
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
