import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// Course reviews [C05] + write-a-review sheet [C06].
/// New reviews are kept in local state (demo — no backend).
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late List<Review> _reviews = List.of(DemoData.reviews);

  /// Demo rating breakdown (5★ → 1★ share of all ratings).
  static const List<double> _breakdown = [0.78, 0.15, 0.04, 0.02, 0.01];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final course = DemoData.courseById(widget.courseId);
    if (course == null) {
      return Scaffold(
        backgroundColor: cs.canvas,
        appBar: const CsTopBar(title: 'Reviews'),
        body: Center(
          child: Text(
            'Course not found',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Reviews'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Rating summary --------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        course.rating.toStringAsFixed(1),
                        style: AppText.display.copyWith(
                          color: cs.textPrimary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < 5; i++)
                            Icon(
                              i < course.rating.round()
                                  ? AppIcons.starBold
                                  : AppIcons.star,
                              size: 16,
                              color: cs.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${course.ratingCount} reviews',
                        style: AppText.caption.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i == 4 ? 0 : 8,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${5 - i}',
                                  style: AppText.caption.copyWith(
                                    color: cs.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  AppIcons.starBold,
                                  size: 12,
                                  color: cs.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: _breakdown[i],
                                      minHeight: 6,
                                      backgroundColor: cs.sunken,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        cs.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '${(_breakdown[i] * 100).round()}%',
                                    style: AppText.caption.copyWith(
                                      color: cs.textTertiary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CsButton(
              label: 'Write a review',
              variant: CsButtonVariant.secondary,
              icon: AppIcons.edit,
              onPressed: () => showWriteReviewSheet(
                context,
                (review) {
                  setState(() => _reviews = [review, ..._reviews]);
                  showCsToast(context, 'Thanks! Your review was posted.');
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What learners say',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 12),
            for (final review in _reviews) ...[
              _ReviewCard(review: review),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CsAvatar(
                photoAsset: review.authorPhoto,
                name: review.authorName,
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: AppText.label.copyWith(color: cs.textPrimary),
                    ),
                    Text(
                      review.timeLabel,
                      style: AppText.caption.copyWith(
                        color: cs.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 5; i++)
                    Icon(
                      i < review.rating.round()
                          ? AppIcons.starBold
                          : AppIcons.star,
                      size: 14,
                      color: cs.primary,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.text,
            style: AppText.body.copyWith(color: cs.textPrimary),
          ),
        ],
      ),
    );
  }
}

Future<void> showWriteReviewSheet(
  BuildContext context,
  ValueChanged<Review> onSubmit,
) =>
    showCsSheet(context, WriteReviewSheet(onSubmit: onSubmit));

/// Write-a-review sheet [C06]: star selector + text.
class WriteReviewSheet extends StatefulWidget {
  const WriteReviewSheet({super.key, required this.onSubmit});

  final ValueChanged<Review> onSubmit;

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  final _controller = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final canSubmit = _controller.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write a review',
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'How was your experience with this course?',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(() => _rating = i),
                    icon: Icon(
                      i <= _rating ? AppIcons.starBold : AppIcons.star,
                      size: 36,
                      color: cs.primary,
                    ),
                    splashRadius: 24,
                    tooltip: '$i star${i == 1 ? '' : 's'}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CsTextField(
            label: 'Your review',
            hint: 'Share what you liked (or what could be better)…',
            controller: _controller,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          CsButton(
            label: 'Post review',
            onPressed: canSubmit
                ? () {
                    widget.onSubmit(
                      Review(
                        authorName: DemoData.me.name,
                        authorPhoto: DemoData.me.avatarPhoto,
                        rating: _rating.toDouble(),
                        text: _controller.text.trim(),
                        timeLabel: 'Just now',
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
