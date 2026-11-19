import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/hive_boxes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/cs_button.dart';
import '../../../../widgets/cs_top_bar.dart';
import '../../widgets/onboarding_step_header.dart';

class _Level {
  const _Level({
    required this.name,
    required this.description,
    required this.icon,
  });

  final String name;
  final String description;
  final IconData icon;
}

const _levels = [
  _Level(
    name: 'Beginner',
    description: "I'm just starting out. No experience needed.",
    icon: AppIcons.book,
  ),
  _Level(
    name: 'Intermediate',
    description: 'I know the basics and want to go deeper.',
    icon: AppIcons.code,
  ),
  _Level(
    name: 'Advanced',
    description: "I'm comfortable coding and want to master it.",
    icon: AppIcons.trophy,
  ),
];

/// Onboarding step 2 [A11]. Pick an experience level -> /onboarding/interests.
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  String? _selected;

  Future<void> _continue() async {
    final level = _selected;
    if (level == null) return;
    await HiveBoxes.settings.put('onboardLevel', level);
    if (!mounted) return;
    context.push('/onboarding/interests');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Your level'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepHeader(step: 2),
              const SizedBox(height: 24),
              Text(
                "What's your experience level?",
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'We will recommend courses that match where you are.',
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 24),
              for (final level in _levels) ...[
                _LevelCard(
                  level: level,
                  selected: _selected == level.name,
                  onTap: () => setState(() => _selected = level.name),
                ),
                const SizedBox(height: 12),
              ],
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

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final _Level level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? cs.primary : cs.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(level.icon, size: 24, color: cs.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.name,
                      style: AppText.label.copyWith(color: cs.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.description,
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? cs.primary : cs.border,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
