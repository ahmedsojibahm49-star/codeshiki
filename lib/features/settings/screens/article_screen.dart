import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/help_articles.dart';

/// Help article [K16]: path param `articleId` -> real help text +
/// "Was this helpful?" feedback.
class HelpArticleScreen extends StatefulWidget {
  const HelpArticleScreen({super.key, required this.articleId});

  final String articleId;

  @override
  State<HelpArticleScreen> createState() => _HelpArticleScreenState();
}

class _HelpArticleScreenState extends State<HelpArticleScreen> {
  bool _voted = false;

  void _vote(bool helpful) {
    setState(() => _voted = true);
    showCsToast(context, 'Thanks for your feedback');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final article = helpArticleById(widget.articleId);
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: article?.title ?? 'Help article'),
      body: article == null
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Sorry, this help article could not be found.',
                  style: AppText.body.copyWith(color: cs.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(
                  article.title,
                  style: AppText.h2.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 16),
                for (final paragraph in article.paragraphs) ...[
                  Text(
                    paragraph,
                    style: AppText.body.copyWith(
                      color: cs.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.borderHairline),
                  ),
                  child: _voted
                      ? Row(
                          children: [
                            Icon(
                              AppIcons.checkBold,
                              size: 20,
                              color: cs.success,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Thanks for your feedback!',
                                style: AppText.body.copyWith(
                                  color: cs.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Was this helpful?',
                              style: AppText.body.copyWith(
                                color: cs.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CsButton(
                                    label: 'Yes',
                                    icon: AppIcons.like,
                                    onPressed: () => _vote(true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CsButton(
                                    label: 'No',
                                    variant: CsButtonVariant.secondary,
                                    onPressed: () => _vote(false),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
