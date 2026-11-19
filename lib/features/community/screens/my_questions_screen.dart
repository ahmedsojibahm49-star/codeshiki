import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/question_card.dart';

/// My questions [G12] — tab-nested (coordinator wires the route).
class MyQuestionsScreen extends ConsumerWidget {
  const MyQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final meName =
        ref.watch(authProvider).user?.name ?? DemoData.me.name;
    final questions = ref
        .watch(forumProvider)
        .where((q) => q.authorName == meName)
        .toList();

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'My questions'),
      body: questions.isEmpty
          ? CsEmptyState(
              icon: AppIcons.messageText,
              title: "You haven't asked anything yet",
              body:
                  'Ask the community — someone is always ready to help.',
              actionLabel: 'Ask a question',
              onAction: () => context.push('/community/ask'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: QuestionCard(
                    question: q,
                    onTap: () =>
                        context.push('/community/question/${q.id}'),
                  ),
                );
              },
            ),
    );
  }
}
