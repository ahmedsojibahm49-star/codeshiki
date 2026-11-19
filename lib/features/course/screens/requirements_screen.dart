import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_section_header.dart';
import '../../../widgets/cs_top_bar.dart';

/// Requirements + device check [C15].
class RequirementsScreen extends StatelessWidget {
  const RequirementsScreen({super.key, required this.courseId});

  final String courseId;

  static const List<(IconData, String, String)> _checks = [
    (
      AppIcons.shield,
      'Android 8.0 or higher',
      'Your device is ready',
    ),
    (
      AppIcons.folder,
      '100 MB free storage',
      'Enough space for downloads',
    ),
    (
      AppIcons.wifi,
      'Internet connection',
      'Needed for streaming lessons',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final course = DemoData.courseById(courseId);

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Requirements'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device check',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'We checked your device against what this course needs.',
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 16),
            for (final (icon, title, subtitle) in _checks) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surface,
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
                          Text(
                            subtitle,
                            style: AppText.caption.copyWith(
                              color: cs.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(AppIcons.checkBold, size: 22, color: cs.success),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 24),
            const CsSectionHeader(title: 'What you need to know'),
            const SizedBox(height: 12),
            for (final item in [
              'No prior coding experience needed — we start from zero.',
              'Basic English reading is helpful; lessons are in Bangla.',
              'A laptop or desktop helps for coding exercises, but every '
                  'lesson works on your phone too.',
              if (course != null)
                'About ${course.hours} hours of learning, at your own pace — '
                    'roughly ${course.lessonsCount} lessons.',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(AppIcons.checkBold, size: 20, color: cs.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: AppText.body.copyWith(color: cs.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            CsButton(
              label: 'Got it',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
