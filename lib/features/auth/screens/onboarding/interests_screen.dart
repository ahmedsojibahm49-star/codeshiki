import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/hive_boxes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/cs_button.dart';
import '../../../../widgets/cs_chip.dart';
import '../../../../widgets/cs_top_bar.dart';
import '../../widgets/onboarding_step_header.dart';

const _interests = [
  'Web Development',
  'Python',
  'Java',
  'DSA',
  'Mobile Apps',
  'AI & ML',
  'Databases',
  'Freelancing',
];

const _dailyGoals = [15, 30, 45, 60];

/// Onboarding step 3 [A12]. Interests (multi-select) + daily goal
/// -> /onboarding/plan.
class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final _selected = <String>{};
  int _dailyGoalMin = 30;

  Future<void> _continue() async {
    await HiveBoxes.settings.put('onboardInterests', _selected.toList());
    await HiveBoxes.settings.put('dailyGoalMin', _dailyGoalMin);
    if (!mounted) return;
    context.push('/onboarding/plan');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Your interests'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepHeader(step: 3),
              const SizedBox(height: 24),
              Text(
                'What are you interested in?',
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick as many as you like.',
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final interest in _interests)
                    CsFilterChip(
                      label: interest,
                      selected: _selected.contains(interest),
                      onTap: () => setState(() {
                        if (!_selected.remove(interest)) {
                          _selected.add(interest);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Daily goal',
                style: AppText.h3.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'How many minutes do you want to study each day?',
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final minutes in _dailyGoals)
                    CsFilterChip(
                      label: '$minutes min',
                      selected: _dailyGoalMin == minutes,
                      onTap: () => setState(() => _dailyGoalMin = minutes),
                    ),
                ],
              ),
              const Spacer(),
              CsButton(
                label: 'Continue',
                onPressed: _selected.isEmpty ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
