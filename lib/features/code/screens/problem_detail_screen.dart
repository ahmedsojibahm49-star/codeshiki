import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_top_bar.dart';
import '../code_storage.dart';
import '../problems_data.dart';
import '../widgets/hint_sheet.dart';

/// Problem detail [F22] (`/code/problems/:problemId`): description,
/// examples, constraints, Solve (→ editor), Hint (Pro sheet), Submit.
///
/// Submit is a deterministic demo: the first submit shows 2/3 tests
/// passed with the failing test highlighted; the second submit shows
/// 3/3 passed, awards +30 XP and marks the problem solved. Attempts are
/// tracked in local state.
class ProblemDetailScreen extends ConsumerStatefulWidget {
  const ProblemDetailScreen({super.key, required this.problemId});

  final String problemId;

  @override
  ConsumerState<ProblemDetailScreen> createState() =>
      _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends ConsumerState<ProblemDetailScreen> {
  int _attempts = 0;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _loadSolved();
  }

  Future<void> _loadSolved() async {
    final solved = await CodeStorage.loadSolvedProblems();
    if (!mounted) return;
    setState(() => _solved = solved.contains(widget.problemId));
  }

  Future<void> _submit(PracticeProblem problem) async {
    _attempts++;
    final passedAll = _attempts >= 2;
    if (passedAll && !_solved) {
      ref.read(walletProvider.notifier).addXp(30);
      await CodeStorage.markSolved(widget.problemId);
      if (!mounted) return;
      setState(() => _solved = true);
    }
    if (!mounted) return;
    final results = <CodeTestResult>[];
    for (var i = 0; i < problem.tests.length; i++) {
      results.add(
        CodeTestResult(
          name: problem.tests[i].name,
          passed: passedAll || i < problem.tests.length - 1,
        ),
      );
    }
    await showCsSheet<void>(
      context,
      _SubmitResultSheet(
        problem: problem,
        results: results,
        passedAll: passedAll,
        onTryAgain: () {
          Navigator.of(context).pop();
          context.push('/editor/${problem.id}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final problem = ProblemsData.byId(widget.problemId);

    if (problem == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Problem'),
        body: CsEmptyState(
          icon: AppIcons.target,
          title: 'Problem not found',
          body: 'This practice problem does not exist.',
          actionLabel: 'Go back',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

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

    return Scaffold(
      appBar: CsTopBar(
        title: problem.title,
        actions: [
          IconButton(
            onPressed: () => showHintSheet(
              context,
              problemTitle: problem.title,
              hint: problem.hint,
            ),
            icon: Icon(AppIcons.lamp, color: cs.textPrimary),
            tooltip: 'Hint (Pro)',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  problem.language,
                  style: AppText.caption.copyWith(
                    color: cs.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_solved) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.successSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.checkBold,
                        size: 12,
                        color: cs.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Solved',
                        style: AppText.caption.copyWith(
                          color: cs.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            problem.description,
            style: AppText.body.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 20),
          Text(
            'Examples',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          ...problem.examples.map((example) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input: ${example.input}',
                    style: AppText.code.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Output: ${example.output}',
                    style: AppText.code.copyWith(color: cs.textPrimary),
                  ),
                  if (example.explanation.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      example.explanation,
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'Constraints',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          ...problem.constraints.map((constraint) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•  ',
                    style: AppText.body.copyWith(color: cs.accent),
                  ),
                  Expanded(
                    child: Text(
                      constraint,
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          CsButton(
            label: 'Solve in editor',
            icon: AppIcons.code,
            onPressed: () => context.push('/editor/${problem.id}'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CsButton(
                  label: 'Hint',
                  icon: AppIcons.lamp,
                  variant: CsButtonVariant.secondary,
                  size: CsButtonSize.m,
                  onPressed: () => showHintSheet(
                    context,
                    problemTitle: problem.title,
                    hint: problem.hint,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CsButton(
                  label: 'Submit',
                  icon: AppIcons.send,
                  size: CsButtonSize.m,
                  onPressed: () => _submit(problem),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubmitResultSheet extends StatelessWidget {
  const _SubmitResultSheet({
    required this.problem,
    required this.results,
    required this.passedAll,
    required this.onTryAgain,
  });

  final PracticeProblem problem;
  final List<CodeTestResult> results;
  final bool passedAll;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final passed = results.where((t) => t.passed).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: passedAll ? cs.successSoft : cs.warningSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              passedAll ? AppIcons.checkBold : AppIcons.warning,
              size: 30,
              color: passedAll ? cs.success : cs.warning,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            passedAll
                ? 'All tests passed!'
                : '$passed of ${results.length} tests passed',
            style: AppText.h3.copyWith(color: cs.textPrimary),
            textAlign: TextAlign.center,
          ),
          if (passedAll) ...[
            const SizedBox(height: 8),
            Text(
              '+30 XP earned — nice work!',
              style: AppText.bodySmall.copyWith(color: cs.success),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ...results.map((test) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: test.passed ? cs.sunken : cs.dangerSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    test.passed ? AppIcons.checkBold : AppIcons.closeBold,
                    size: 18,
                    color: test.passed ? cs.success : cs.danger,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      test.name,
                      style: AppText.bodySmall.copyWith(
                        color:
                            test.passed ? cs.textPrimary : cs.danger,
                      ),
                    ),
                  ),
                  Text(
                    test.passed ? 'PASS' : 'FAIL',
                    style: AppText.caption.copyWith(
                      color: test.passed ? cs.success : cs.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          if (passedAll)
            CsButton(
              label: 'Back to problems',
              size: CsButtonSize.m,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).maybePop();
              },
            )
          else
            Row(
              children: [
                Expanded(
                  child: CsButton(
                    label: 'Close',
                    variant: CsButtonVariant.secondary,
                    size: CsButtonSize.m,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CsButton(
                    label: 'Try again',
                    size: CsButtonSize.m,
                    onPressed: onTryAgain,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
