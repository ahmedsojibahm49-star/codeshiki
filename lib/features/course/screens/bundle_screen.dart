import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_course_card.dart';
import '../../../widgets/cs_section_header.dart';
import '../../../widgets/cs_top_bar.dart';

/// Bundle offer [C12]: 3 courses for ৳2,999 (was ৳4,500).
class BundleScreen extends StatelessWidget {
  const BundleScreen({super.key, required this.courseId});

  final String courseId;

  /// The bundle always includes these three courses.
  List<String> get _bundleIds => const [
        'react-js-zero',
        'python-one-night',
        'mern-project-camp',
      ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final List<Course> courses =
        _bundleIds.map(DemoData.courseById).whereType<Course>().toList();
    final totalLessons =
        courses.fold<int>(0, (sum, c) => sum + c.lessonsCount);
    final totalHours =
        courses.fold<double>(0, (sum, c) => sum + c.hours);

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Course bundle'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: CsScheme.proGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.gift, size: 22, color: cs.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Web Dev Bundle',
                        style: AppText.h2.copyWith(color: cs.onPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Three best-selling courses in one bundle — save ৳1,501 '
                    'and learn the full stack, from Python basics to a '
                    'deployed MERN app.',
                    style: AppText.bodySmall.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '৳2,999',
                        style: AppText.display.copyWith(color: cs.onPrimary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '৳4,500',
                        style: AppText.h3.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.7),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalLessons lessons · ${totalHours.toStringAsFixed(1)} hours total',
                    style: AppText.caption.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const CsSectionHeader(title: 'Included in the bundle'),
            const SizedBox(height: 12),
            for (final course in courses) ...[
              CsCourseListCard(
                course: course,
                onTap: () => context.push('/course/${course.id}'),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            for (final perk in const [
              'Lifetime access to all 3 courses',
              'Certificates for every course you finish',
              'All future updates included, free',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(AppIcons.checkBold, size: 20, color: cs.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        perk,
                        style: AppText.body.copyWith(color: cs.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            CsButton(
              label: 'Enroll in bundle — ৳2,999',
              icon: AppIcons.gift,
              onPressed: () => context.push(
                '/payments/checkout?courseId=$courseId',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
