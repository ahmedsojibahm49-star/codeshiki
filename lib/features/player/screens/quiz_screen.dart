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
import '../../../widgets/cs_top_bar.dart';
import '../player_helpers.dart';
import '../quiz_data.dart';

enum _QuizStep { intro, question, feedback, result }

/// Quiz flow [E10–E14] in one screen with an internal state machine:
/// intro → question → feedback (correct / wrong) → result.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    required this.lessonId,
    this.courseId,
  });

  final String lessonId;
  final String? courseId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  Course? _course;
  Lesson? _lesson;
  late final List<QuizQuestion> _questions;

  _QuizStep _step = _QuizStep.intro;
  int _index = 0;
  int? _selected;
  final List<bool> _results = [];
  bool _xpAwarded = false;

  int get _score => _results.where((r) => r).length;

  @override
  void initState() {
    super.initState();
    final resolved = resolveLesson(widget.lessonId, widget.courseId);
    _course = resolved.course;
    _lesson = resolved.lesson;
    _questions = quizForLesson(_course?.id ?? 'react-js-zero');
  }

  void _checkAnswer() {
    if (_selected == null) return;
    final correct =
        _selected == _questions[_index].correctIndex;
    setState(() {
      _results.add(correct);
      _step = _QuizStep.feedback;
    });
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      setState(() => _step = _QuizStep.result);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _step = _QuizStep.question;
    });
  }

  void _finishQuiz() {
    final lesson = _lesson;
    final course = _course;
    if (lesson == null || course == null) return;
    final enrollment = ref.read(enrollmentProvider.notifier);
    enrollment.completeLesson(course.id, lesson.id);
    enrollment.recordQuizBest(lesson.id, _score);
    if (_score >= 7 && !_xpAwarded) {
      _xpAwarded = true;
      ref.read(walletProvider.notifier).addXp(10);
    }
    context.push(
      '/lesson-complete?lessonId=${lesson.id}&courseId=${course.id}'
      '&score=$_score&total=${_questions.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    final course = _course;
    if (lesson == null || course == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Quiz'),
        body: CsEmptyState(
          icon: AppIcons.target,
          title: 'Quiz not found',
          body: 'This quiz does not exist in the demo catalog.',
          actionLabel: 'Back to Home',
          onAction: () => context.go('/home'),
        ),
      );
    }
    return Scaffold(
      appBar: CsTopBar(title: lesson.title),
      body: switch (_step) {
        _QuizStep.intro => _IntroStep(
            lesson: lesson,
            course: course,
            total: _questions.length,
            onStart: () =>
                setState(() => _step = _QuizStep.question),
          ),
        _QuizStep.question => _QuestionStep(
            question: _questions[_index],
            index: _index,
            total: _questions.length,
            selected: _selected,
            onSelect: (i) => setState(() => _selected = i),
            onCheck: _checkAnswer,
          ),
        _QuizStep.feedback => _FeedbackStep(
            question: _questions[_index],
            selected: _selected!,
            isLast: _index + 1 >= _questions.length,
            onNext: _next,
          ),
        _QuizStep.result => _ResultStep(
            questions: _questions,
            results: _results,
            score: _score,
            onFinish: _finishQuiz,
          ),
      },
    );
  }
}

/// [E10] Quiz intro: title, meta, rules, Start button.
class _IntroStep extends StatelessWidget {
  const _IntroStep({
    required this.lesson,
    required this.course,
    required this.total,
    required this.onStart,
  });

  final Lesson lesson;
  final Course course;
  final int total;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.sunken,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(AppIcons.targetBold, size: 36, color: cs.accent),
          ),
          const SizedBox(height: 20),
          Text(
            lesson.title,
            style: AppText.h1.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            course.title,
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              _MetaChip(
                icon: AppIcons.documentText,
                label: '$total questions',
              ),
              const _MetaChip(icon: AppIcons.clock, label: '~5 min'),
              const _MetaChip(icon: AppIcons.flash, label: '+10 XP at 7+'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'How it works',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          const _RuleRow(
            text: 'Pick one answer for each question, then tap Check.',
          ),
          const _RuleRow(
            text: 'You get instant feedback with an explanation.',
          ),
          const _RuleRow(
            text: 'Score 7 or more to earn +10 bonus XP.',
          ),
          const _RuleRow(
            text: 'Your best score is saved for this quiz.',
          ),
          const SizedBox(height: 32),
          CsButton(
            label: 'Start quiz',
            icon: AppIcons.playBold,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.sunken,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.caption.copyWith(
              color: cs.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.checkBold, size: 20, color: cs.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppText.bodySmall.copyWith(color: cs.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// [E11] Question step: progress, question, 4 options, Check button.
class _QuestionStep extends StatelessWidget {
  const _QuestionStep({
    required this.question,
    required this.index,
    required this.total,
    required this.selected,
    required this.onSelect,
    required this.onCheck,
  });

  final QuizQuestion question;
  final int index;
  final int total;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheck;

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Question ${index + 1} of $total',
                    style: AppText.label.copyWith(color: cs.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    '${(((index) / total) * 100).round()}%',
                    style: AppText.caption.copyWith(color: cs.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: index / total,
                  minHeight: 6,
                  backgroundColor: cs.sunken,
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                question.question,
                style: AppText.h2.copyWith(color: cs.textPrimary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: question.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final isSelected = selected == i;
              return InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.sunken : cs.raised,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? cs.primary : cs.borderHairline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primary
                              : cs.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? cs.primary
                                : cs.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _letters[i],
                          style: AppText.label.copyWith(
                            color: isSelected
                                ? cs.onPrimary
                                : cs.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question.options[i],
                          style: AppText.bodySmall.copyWith(
                            color: cs.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: CsButton(
            label: 'Check answer',
            onPressed: selected == null ? null : onCheck,
          ),
        ),
      ],
    );
  }
}

/// [E12 correct / E13 wrong] Feedback step.
class _FeedbackStep extends StatelessWidget {
  const _FeedbackStep({
    required this.question,
    required this.selected,
    required this.isLast,
    required this.onNext,
  });

  final QuizQuestion question;
  final int selected;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isCorrect = selected == question.correctIndex;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isCorrect ? cs.successSoft : cs.dangerSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isCorrect
                            ? AppIcons.checkBold
                            : AppIcons.closeBold,
                        size: 48,
                        color: isCorrect ? cs.success : cs.danger,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isCorrect ? 'Correct!' : 'Not quite',
                        style: AppText.h2.copyWith(
                          color: isCorrect ? cs.success : cs.danger,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isCorrect
                            ? 'Nice work — you got it right.'
                            : 'The correct answer is '
                                '“${question.options[question.correctIndex]}”.',
                        style: AppText.bodySmall.copyWith(
                          color: cs.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Explanation',
                  style: AppText.h3.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  question.explanation,
                  style: AppText.body.copyWith(color: cs.textSecondary),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: CsButton(
            label: isLast ? 'See results' : 'Next question',
            icon: AppIcons.arrowRightBold,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

/// [E14] Result step: score ring, per-question review, next lesson.
class _ResultStep extends StatelessWidget {
  const _ResultStep({
    required this.questions,
    required this.results,
    required this.score,
    required this.onFinish,
  });

  final List<QuizQuestion> questions;
  final List<bool> results;
  final int score;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final total = questions.length;
    final passed = score >= 7;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: total == 0 ? 0 : score / total,
                          strokeWidth: 10,
                          backgroundColor: cs.sunken,
                          valueColor: AlwaysStoppedAnimation(
                            passed ? cs.success : cs.primary,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score/$total',
                            style: AppText.h1.copyWith(
                              color: cs.textPrimary,
                            ),
                          ),
                          Text(
                            'correct',
                            style: AppText.caption.copyWith(
                              color: cs.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  passed ? 'Great job!' : 'Keep practicing!',
                  style: AppText.h2.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  passed
                      ? 'You earned +10 bonus XP for scoring 7 or more.'
                      : 'Score 7 or more to earn +10 bonus XP.',
                  style: AppText.bodySmall.copyWith(
                    color: cs.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Review answers',
                    style: AppText.h3.copyWith(color: cs.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < questions.length; i++)
                  _ReviewRow(
                    index: i,
                    question: questions[i],
                    correct: results[i],
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: CsButton(
            label: 'Next lesson',
            icon: AppIcons.arrowRightBold,
            onPressed: onFinish,
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.index,
    required this.question,
    required this.correct,
  });

  final int index;
  final QuizQuestion question;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.raised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.borderHairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? AppIcons.checkBold : AppIcons.closeBold,
            size: 22,
            color: correct ? cs.success : cs.danger,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${index + 1}. ${question.question}',
                  style: AppText.bodySmall.copyWith(
                    color: cs.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Answer: ${question.options[question.correctIndex]}',
                  style: AppText.caption.copyWith(
                    color: cs.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
