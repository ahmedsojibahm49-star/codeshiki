import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';

/// "Step X of 4" label + progress bar for the onboarding flow.
class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({super.key, required this.step, this.total = 4});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $step of $total',
          style: AppText.caption.copyWith(color: cs.textTertiary),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 6,
            color: cs.primary,
            backgroundColor: cs.border,
          ),
        ),
      ],
    );
  }
}
