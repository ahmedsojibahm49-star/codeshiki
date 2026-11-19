import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/question_card.dart';

/// Tag page [G10] — tab-nested (coordinator wires the route).
class TagPageScreen extends ConsumerWidget {
  const TagPageScreen({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final questions = ref
        .watch(forumProvider)
        .where((q) => q.tags.contains(tag))
        .toList();

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: '#$tag'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#$tag',
                  style: AppText.h2.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${questions.length} question${questions.length == 1 ? '' : 's'}',
                  style:
                      AppText.bodySmall.copyWith(color: cs.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (questions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: CsEmptyState(
                icon: AppIcons.messages,
                title: 'No questions tagged #$tag yet',
                body: 'Ask the first question about $tag.',
                actionLabel: 'Ask a question',
                onAction: () => context.push('/community/ask'),
              ),
            )
          else
            ...questions.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuestionCard(
                  question: q,
                  onTap: () => context.push('/community/question/${q.id}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
