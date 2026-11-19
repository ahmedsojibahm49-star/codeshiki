import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_top_bar.dart';
import '../sheets/path_step_sheet.dart';

/// Learning path [B10]: vertical stepper of 6 steps.
class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  static const List<PathStep> _steps = [
    PathStep(
      title: 'HTML & CSS',
      description:
          'The building blocks of the web — structure a page with HTML and '
          'make it beautiful with CSS, flexbox and responsive layouts.',
      lessons: 8,
      durationLabel: '3h 20m',
      state: PathStepState.done,
    ),
    PathStep(
      title: 'JavaScript',
      description:
          'Make pages interactive — variables, functions, DOM events and '
          'fetching real data from APIs.',
      lessons: 12,
      durationLabel: '5h 10m',
      state: PathStepState.done,
    ),
    PathStep(
      title: 'React',
      description:
          'Components, hooks, state and routing — build modern single-page '
          'apps the way real teams do.',
      lessons: 10,
      durationLabel: '6h 30m',
      state: PathStepState.current,
    ),
    PathStep(
      title: 'Node.js',
      description:
          'JavaScript on the server — Express APIs, authentication and '
          'talking to a database.',
      lessons: 9,
      durationLabel: '5h 45m',
      state: PathStepState.locked,
    ),
    PathStep(
      title: 'MERN Project',
      description:
          'Put it all together — a full-stack app with MongoDB, Express, '
          'React and Node, deployed to production.',
      lessons: 11,
      durationLabel: '12h 00m',
      state: PathStepState.locked,
    ),
    PathStep(
      title: 'Interview Prep',
      description:
          'DSA patterns, system-design basics and mock interviews — get '
          'ready for your first developer job.',
      lessons: 7,
      durationLabel: '4h 00m',
      state: PathStepState.locked,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Learning path'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text(
            'Full-Stack Web Dev Path',
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '2 of 6 steps done — keep going, Rahim!',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 2 / 6,
              minHeight: 8,
              backgroundColor: cs.sunken,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < _steps.length; i++)
            _StepRow(
              step: _steps[i],
              index: i,
              isLast: i == _steps.length - 1,
              onTap: () => showPathStepSheet(context, _steps[i]),
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.index,
    required this.isLast,
    required this.onTap,
  });

  final PathStep step;
  final int index;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isDone = step.state == PathStepState.done;
    final isCurrent = step.state == PathStepState.current;
    final isLocked = step.state == PathStepState.locked;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rail: node circle + connector line.
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone
                      ? cs.primary
                      : isCurrent
                          ? cs.surface
                          : cs.sunken,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent ? cs.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? Icon(
                          AppIcons.checkBold,
                          size: 20,
                          color: cs.onPrimary,
                        )
                      : isLocked
                          ? Icon(
                              AppIcons.lock,
                              size: 18,
                              color: cs.textTertiary,
                            )
                          : Text(
                              '${index + 1}',
                              style: AppText.label.copyWith(
                                color: cs.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? cs.primary : cs.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Step card.
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent ? cs.primary : cs.borderHairline,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Step ${index + 1} · ${step.title}',
                                style: AppText.label.copyWith(
                                  color: isLocked
                                      ? cs.textTertiary
                                      : cs.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? cs.successSoft
                                    : isCurrent
                                        ? cs.warningSoft
                                        : cs.sunken,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isDone
                                    ? 'Done'
                                    : isCurrent
                                        ? 'Current'
                                        : 'Locked',
                                style: AppText.caption.copyWith(
                                  color: isDone
                                      ? cs.success
                                      : isCurrent
                                          ? cs.warning
                                          : cs.textTertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${step.lessons} lessons · ${step.durationLabel}',
                          style: AppText.caption.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
