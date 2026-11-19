import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_course_card.dart';
import '../../../widgets/cs_section_header.dart';
import '../../../widgets/cs_stat_item.dart';
import '../../../widgets/cs_top_bar.dart';

/// Instructor profile [C04]: photo, bio, stats, their courses.
class InstructorScreen extends StatelessWidget {
  const InstructorScreen({super.key, required this.courseId});

  final String courseId;

  static const Map<String, String> _bios = {
    'Nusrat Jahan':
        'Senior frontend engineer with 8 years of experience building React '
        'apps for startups in Dhaka and abroad. She has taught over 8,000 '
        'students and loves explaining hard ideas in simple Bangla.',
    'Tanvir Hasan':
        'Python developer and university lecturer. He believes anyone can '
        'learn to code in one focused night — and has the 21,000 students '
        'to prove it.',
    'Maliha Akter':
        'Full-stack engineer and indie hacker. She has shipped production '
        'MERN apps for clients across three continents and now teaches '
        'others to do the same.',
    'Sakib Al Amin':
        'Ex-competitive programmer and interview coach. He has helped '
        'hundreds of students crack DSA interviews at top tech companies.',
  };

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final course = DemoData.courseById(courseId);
    if (course == null) {
      return Scaffold(
        backgroundColor: cs.canvas,
        appBar: const CsTopBar(title: 'Instructor'),
        body: Center(
          child: Text(
            'Course not found',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
        ),
      );
    }

    final instructorCourses = DemoData.courses
        .where((c) => c.instructor == course.instructor)
        .toList();
    final totalStudents = instructorCourses.fold<int>(
      0,
      (sum, c) => sum + c.students,
    );
    final avgRating = instructorCourses.fold<double>(
          0,
          (sum, c) => sum + c.rating,
        ) /
        instructorCourses.length;
    final bio = _bios[course.instructor] ??
        '${course.instructor} is a CodeShikhi instructor teaching '
            '${course.category} in Bangla.';

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Instructor'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CsAvatar(
                    photoAsset: course.instructorPhoto,
                    name: course.instructor,
                    size: 96,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course.instructor,
                    style: AppText.h2.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.teacher, size: 16, color: cs.accent),
                      const SizedBox(width: 6),
                      Text(
                        '${course.category} Instructor',
                        style: AppText.bodySmall.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CsStatItem(
                      value: _compact(totalStudents),
                      label: 'Students',
                    ),
                  ),
                  Container(width: 1, height: 40, color: cs.borderHairline),
                  Expanded(
                    child: CsStatItem(
                      value: '${instructorCourses.length}',
                      label: 'Courses',
                    ),
                  ),
                  Container(width: 1, height: 40, color: cs.borderHairline),
                  Expanded(
                    child: CsStatItem(
                      value: avgRating.toStringAsFixed(1),
                      label: 'Avg. rating',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const CsSectionHeader(title: 'About'),
            const SizedBox(height: 8),
            Text(
              bio,
              style: AppText.body.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 24),
            CsSectionHeader(
              title: 'Courses by ${course.instructor.split(' ').first}',
            ),
            const SizedBox(height: 12),
            for (final c in instructorCourses) ...[
              CsCourseListCard(
                course: c,
                onTap: () {
                  if (c.id == courseId) {
                    context.pop();
                  } else {
                    context.push('/course/${c.id}');
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  String _compact(int value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return '$value';
  }
}
