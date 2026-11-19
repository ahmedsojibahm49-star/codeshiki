import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/cs_course_card.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../theme/app_icons.dart';
import '../../../widgets/cs_top_bar.dart';

/// Category browse [B08]. Path param `id` is the category name
/// (go_router decodes it, so 'Web Dev' arrives as-is).
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final courses = DemoData.courses
        .where((course) => course.category == category)
        .toList();

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: category),
      body: courses.isEmpty
          ? CsEmptyState(
              icon: AppIcons.category,
              title: 'No courses in $category yet',
              body: 'New courses land here first — check back soon, or '
                  'browse a different category.',
              actionLabel: 'Browse all courses',
              onAction: () => context.push('/home/search'),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = courses[index];
                return CsCourseListCard(
                  course: course,
                  onTap: () => context.push('/course/${course.id}'),
                );
              },
            ),
    );
  }
}
