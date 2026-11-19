import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/demo_data.dart';
import '../../../../data/hive_boxes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/cs_button.dart';
import '../../../../widgets/cs_course_card.dart';
import '../../../../widgets/cs_top_bar.dart';
import '../../widgets/onboarding_step_header.dart';

/// Onboarding step 4 [A13]. Plan summary + recommended course
/// -> "Start learning" -> /home.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final goal =
        HiveBoxes.settings.get('onboardGoal') as String? ?? 'Web Development';
    final level =
        HiveBoxes.settings.get('onboardLevel') as String? ?? 'Beginner';
    final interests = HiveBoxes.settings.stringsAt('onboardInterests');
    final dailyGoalMin = HiveBoxes.settings.get('dailyGoalMin') as int? ?? 30;
    final course = DemoData.courseById('python-one-night');

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Your plan'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepHeader(step: 4),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: cs.successSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(AppIcons.checkBold, size: 40, color: cs.success),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your plan is ready',
                textAlign: TextAlign.center,
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                "Here's your personalised learning plan.",
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.borderHairline),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      icon: AppIcons.target,
                      label: 'Goal',
                      value: goal,
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      icon: AppIcons.chart,
                      label: 'Level',
                      value: level,
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      icon: AppIcons.timer,
                      label: 'Daily goal',
                      value: '$dailyGoalMin min / day',
                    ),
                    if (interests.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SummaryRow(
                        icon: AppIcons.book,
                        label: 'Interests',
                        value: interests.join(', '),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recommended for you',
                style: AppText.h3.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 12),
              if (course != null)
                CsCourseListCard(
                  course: course,
                  onTap: () => context.push('/course/${course.id}'),
                ),
              const SizedBox(height: 24),
              CsButton(
                label: 'Start learning',
                icon: AppIcons.play,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: cs.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.caption.copyWith(color: cs.textTertiary),
              ),
              const SizedBox(height: 2),
              Text(value, style: AppText.label.copyWith(color: cs.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
