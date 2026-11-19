import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/question_card.dart';

/// Community search [G09] — tab-nested (coordinator wires the route).
class CommunitySearchScreen extends ConsumerStatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  ConsumerState<CommunitySearchScreen> createState() =>
      _CommunitySearchScreenState();
}

class _CommunitySearchScreenState
    extends ConsumerState<CommunitySearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final questions = ref.watch(forumProvider);
    final query = _query.trim().toLowerCase();
    final results = query.isEmpty
        ? const []
        : questions.where((q) {
            final haystack =
                '${q.title} ${q.body} ${q.tags.join(' ')}'.toLowerCase();
            return haystack.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Search'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          CsTextField(
            hint: 'Search questions, topics, tags…',
            prefixIcon: AppIcons.search,
            controller: _controller,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 16),
          if (query.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'Search by keyword, topic or tag — e.g. “useEffect”, “python”, “dsa”.',
                style:
                    AppText.bodySmall.copyWith(color: cs.textSecondary),
                textAlign: TextAlign.center,
              ),
            )
          else if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: CsEmptyState(
                icon: AppIcons.search,
                title: 'No results for “$_query”',
                body: 'Try different keywords, or ask the community.',
                actionLabel: 'Ask a question',
                onAction: () => context.push('/community/ask'),
              ),
            )
          else ...[
            Text(
              '${results.length} result${results.length == 1 ? '' : 's'}',
              style: AppText.label.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 12),
            ...results.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuestionCard(
                  question: q,
                  onTap: () => context.push('/community/question/${q.id}'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
