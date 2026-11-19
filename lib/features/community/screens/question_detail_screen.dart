import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/report_sheet.dart';

/// Question detail [G02/G03]: full question, answers, accept + composer.
class QuestionDetailScreen extends ConsumerStatefulWidget {
  const QuestionDetailScreen({super.key, required this.questionId});

  final String questionId;

  @override
  ConsumerState<QuestionDetailScreen> createState() =>
      _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _postAnswer(ForumQuestion question) {
    final text = _answerController.text.trim();
    if (text.isEmpty) {
      showCsToast(context, 'Write your answer first', isError: true);
      return;
    }
    ref.read(forumProvider.notifier).addAnswer(question.id, text);
    _answerController.clear();
    FocusScope.of(context).unfocus();
    showCsToast(context, 'Answer posted');
  }

  void _acceptAnswer(ForumAnswer answer) {
    ref
        .read(forumProvider.notifier)
        .acceptAnswer(widget.questionId, answer.id);
    showCsToast(context, 'Marked as accepted');
  }

  /// Renders a body that may contain ``` fenced code blocks.
  List<Widget> _bodyWidgets(String body, CsScheme cs) {
    final parts = body.split('```');
    final widgets = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.trim().isEmpty) continue;
      if (i.isOdd) {
        widgets.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.synEditorBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                part.trim(),
                style: AppText.code.copyWith(color: cs.textPrimary),
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Text(
            part.trim(),
            style: AppText.body.copyWith(color: cs.textPrimary),
          ),
        );
      }
      if (i < parts.length - 1) widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final questions = ref.watch(forumProvider);
    final question = questions
        .where((q) => q.id == widget.questionId)
        .firstOrNull;

    if (question == null) {
      return Scaffold(
        backgroundColor: cs.canvas,
        appBar: const CsTopBar(title: 'Question'),
        body: const CsEmptyState(
          icon: AppIcons.messages,
          title: 'Question not found',
          body: 'This question may have been removed.',
        ),
      );
    }

    final upvoted =
        ref.read(forumProvider.notifier).hasUpvoted(question.id);
    final answers = question.answers;

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(
        title: 'Question',
        actions: [
          IconButton(
            onPressed: () => showReportSheet(context, question.id),
            icon: Icon(AppIcons.target, color: cs.textSecondary),
            tooltip: 'Report',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CsTextField(
                  hint: 'Write your answer…',
                  controller: _answerController,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: () => _postAnswer(question),
                icon: const Icon(AppIcons.send),
                style: IconButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                ),
                tooltip: 'Post answer',
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text(
            question.title,
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CsAvatar(
                photoAsset: question.authorPhoto,
                name: question.authorName,
                size: 36,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.authorName,
                      style:
                          AppText.label.copyWith(color: cs.textPrimary),
                    ),
                    Text(
                      question.createdLabel,
                      style: AppText.caption
                          .copyWith(color: cs.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._bodyWidgets(question.body, cs),
          if (question.tags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: question.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.sunken,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tag,
                        style: AppText.caption.copyWith(
                          color: cs.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              InkWell(
                onTap: () => ref
                    .read(forumProvider.notifier)
                    .toggleUpvote(question.id),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: upvoted
                        ? cs.primary.withValues(alpha: 0.12)
                        : cs.sunken,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        upvoted ? AppIcons.likeBold : AppIcons.like,
                        size: 18,
                        color: upvoted ? cs.accent : cs.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${question.upvotes} upvotes',
                        style: AppText.label.copyWith(
                          color: upvoted ? cs.accent : cs.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Answers (${answers.length})',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          if (answers.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.border),
              ),
              child: Text(
                'No answers yet — be the first to help.',
                style:
                    AppText.bodySmall.copyWith(color: cs.textSecondary),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...answers.map((answer) {
              final accepted = answer.accepted;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accepted ? cs.successSoft : cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accepted ? cs.success : cs.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CsAvatar(
                            photoAsset: answer.authorPhoto,
                            name: answer.authorName,
                            size: 32,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              answer.authorName,
                              style: AppText.label
                                  .copyWith(color: cs.textPrimary),
                            ),
                          ),
                          if (accepted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.success,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    AppIcons.check,
                                    size: 12,
                                    color: cs.surface,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Accepted answer',
                                    style: AppText.caption.copyWith(
                                      color: cs.surface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        answer.body,
                        style: AppText.bodySmall
                            .copyWith(color: cs.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            AppIcons.like,
                            size: 14,
                            color: cs.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${answer.upvotes}',
                            style: AppText.caption
                                .copyWith(color: cs.textSecondary),
                          ),
                          const Spacer(),
                          if (!answer.accepted)
                            CsButton(
                              label: 'Accept',
                              size: CsButtonSize.s,
                              fullWidth: false,
                              variant: CsButtonVariant.ghost,
                              onPressed: () => _acceptAnswer(answer),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
