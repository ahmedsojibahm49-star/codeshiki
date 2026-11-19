import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_section_header.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/question_card.dart';

/// Community forum feed [G01] — tab root.
class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() =>
      _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  static const _tags = [
    'All',
    'react',
    'python',
    'javascript',
    'dsa',
    'flutter',
  ];

  String _selectedTag = 'All';

  void _onTagTap(String tag) {
    if (tag == 'All') {
      setState(() => _selectedTag = tag);
      return;
    }
    context.push('/community/tag/$tag');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final questions = ref.watch(forumProvider);

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Community', showBack: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community/ask'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(AppIcons.plus),
        label: const Text('Ask question'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Search field — taps through to the dedicated search screen.
          GestureDetector(
            onTap: () => context.push('/community/search'),
            child: const AbsorbPointer(
              child: CsTextField(
                hint: 'Search questions…',
                prefixIcon: AppIcons.search,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tag chips.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tags
                  .map(
                    (tag) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CsFilterChip(
                        label: tag,
                        selected: _selectedTag == tag,
                        onTap: () => _onTagTap(tag),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          // My questions row.
          InkWell(
            onTap: () => context.push('/community/my-questions'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.sunken,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.messageText,
                      size: 18,
                      color: cs.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'My questions',
                      style: AppText.label.copyWith(color: cs.textPrimary),
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
          const SizedBox(height: 20),
          const CsSectionHeader(title: 'Recent questions'),
          const SizedBox(height: 12),
          if (questions.isEmpty)
            CsEmptyState(
              icon: AppIcons.messages,
              title: 'No questions yet',
              body: 'Be the first to ask the community something.',
              actionLabel: 'Ask a question',
              onAction: () => context.push('/community/ask'),
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
