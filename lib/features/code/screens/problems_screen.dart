import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';
import '../code_storage.dart';
import '../problems_data.dart';

/// Practice problems [F21] (tab-nested; coordinator wires the route):
/// difficulty + solved filters, problem rows → detail screen.
class ProblemsScreen extends StatefulWidget {
  const ProblemsScreen({super.key});

  @override
  State<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  String _difficulty = 'All';
  String _status = 'All';
  Set<String> _solved = {};

  @override
  void initState() {
    super.initState();
    unawaited(_loadSolved());
  }

  Future<void> _loadSolved() async {
    final solved = await CodeStorage.loadSolvedProblems();
    if (!mounted) return;
    setState(() => _solved = solved);
  }

  List<PracticeProblem> get _visible {
    return ProblemsData.problems.where((p) {
      if (_difficulty != 'All' && p.difficulty != _difficulty) return false;
      final solved = _solved.contains(p.id);
      if (_status == 'Solved' && !solved) return false;
      if (_status == 'Unsolved' && solved) return false;
      return true;
    }).toList();
  }

  void _openProblem(PracticeProblem problem) {
    context.push('/code/problems/${problem.id}').then((_) => _loadSolved());
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      appBar: const CsTopBar(title: 'Practice problems'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['All', 'Easy', 'Medium', 'Hard'].map((label) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CsFilterChip(
                    label: label,
                    selected: _difficulty == label,
                    onTap: () => setState(() => _difficulty = label),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['All', 'Solved', 'Unsolved'].map((label) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CsFilterChip(
                    label: label == 'All' ? 'All statuses' : label,
                    selected: _status == label,
                    onTap: () => setState(() => _status = label),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${_solved.length} of ${ProblemsData.problems.length} solved · '
              '30 XP per solved problem',
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _visible.isEmpty
                ? CsEmptyState(
                    icon: AppIcons.target,
                    title: 'No problems here',
                    body: 'Try a different filter to see more problems.',
                    actionLabel: 'Clear filters',
                    onAction: () => setState(() {
                      _difficulty = 'All';
                      _status = 'All';
                    }),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    itemCount: _visible.length,
                    itemBuilder: (context, index) {
                      final problem = _visible[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ProblemRow(
                          problem: problem,
                          solved: _solved.contains(problem.id),
                          onTap: () => _openProblem(problem),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProblemRow extends StatelessWidget {
  const _ProblemRow({
    required this.problem,
    required this.solved,
    required this.onTap,
  });

  final PracticeProblem problem;
  final bool solved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final Color difficultyColor;
    final Color difficultyBg;
    switch (problem.difficulty) {
      case 'Easy':
        difficultyColor = cs.success;
        difficultyBg = cs.successSoft;
      case 'Medium':
        difficultyColor = cs.warning;
        difficultyBg = cs.warningSoft;
      default:
        difficultyColor = cs.danger;
        difficultyBg = cs.dangerSoft;
    }
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.borderHairline),
          ),
          child: Row(
            children: [
              Icon(
                solved ? AppIcons.checkBold : AppIcons.codeCircle,
                size: 26,
                color: solved ? cs.success : cs.accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      problem.title,
                      style: AppText.label.copyWith(
                        color: cs.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            problem.difficulty,
                            style: AppText.caption.copyWith(
                              color: difficultyColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          problem.language,
                          style: AppText.caption.copyWith(
                            color: cs.textTertiary,
                          ),
                        ),
                        if (solved) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Solved',
                            style: AppText.caption.copyWith(
                              color: cs.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                size: 20,
                color: cs.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
