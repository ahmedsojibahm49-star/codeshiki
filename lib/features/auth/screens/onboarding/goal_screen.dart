import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/hive_boxes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/cs_button.dart';
import '../../../../widgets/cs_chip.dart';
import '../../../../widgets/cs_top_bar.dart';
import '../../widgets/onboarding_step_header.dart';

const _goals = ['Web Development', 'Python', 'Java', 'DSA', 'Freelancing'];

/// Onboarding step 1 [A10]. Pick one goal -> /onboarding/level.
class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String? _selected;

  Future<void> _continue() async {
    final goal = _selected;
    if (goal == null) return;
    await HiveBoxes.settings.put('onboardGoal', goal);
    if (!mounted) return;
    context.push('/onboarding/level');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Your goal', showBack: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepHeader(step: 1),
              const SizedBox(height: 24),
              Text(
                "What's your goal?",
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick one to start with. You can change it later.',
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final goal in _goals)
                    CsFilterChip(
                      label: goal,
                      selected: _selected == goal,
                      onTap: () => setState(() => _selected = goal),
                    ),
                ],
              ),
              const Spacer(),
              CsButton(
                label: 'Continue',
                onPressed: _selected == null ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
