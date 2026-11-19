import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_course_card.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_top_bar.dart';
import '../sheets/filters_sheet.dart';

/// Search [B05/B06]: live text filter, filters sheet, recents, empty state.
/// CsTextField has no autofocus/focusNode, so the field is a styled raw
/// TextField (same sunken fill, radius 16) with autofocus.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  FilterState _filters = const FilterState();
  List<String> _recents = ['React hooks', 'Python basics', 'DSA with Java'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Course> get _results {
    final query = _query.trim().toLowerCase();
    var list = DemoData.courses.where((course) {
      if (query.isNotEmpty) {
        final haystack =
            '${course.title} ${course.instructor} ${course.category}'
                .toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      if (_filters.categories.isNotEmpty &&
          !_filters.categories.contains(course.category)) {
        return false;
      }
      switch (_filters.access) {
        case 'Free':
          if (!course.isFree) return false;
        case 'Pro':
          if (!course.isPro) return false;
        case 'Paid':
          if (!course.isPaid) return false;
      }
      return true;
    }).toList();
    switch (_filters.sort) {
      case 'Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Newest':
        list = list.reversed.toList();
      case 'Popular':
        list.sort((a, b) => b.students.compareTo(a.students));
    }
    return list;
  }

  void _runSearch(String query) {
    setState(() => _query = query);
    if (query.trim().isEmpty) return;
    setState(() {
      _recents = [
        query.trim(),
        ..._recents.where((r) => r.toLowerCase() != query.trim().toLowerCase()),
      ].take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final results = _results;
    final showRecents = _query.trim().isEmpty && _filters.isDefault;

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Search'),
      body: Column(
        children: [
          // --- Search field + filter button ------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _query = value),
                    onSubmitted: _runSearch,
                    style: AppText.body.copyWith(color: cs.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search courses, topics, instructors…',
                      hintStyle: AppText.body.copyWith(
                        color: cs.textTertiary,
                      ),
                      prefixIcon: Icon(
                        AppIcons.search,
                        size: 20,
                        color: cs.textTertiary,
                      ),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(
                                AppIcons.close,
                                size: 20,
                                color: cs.textTertiary,
                              ),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                            ),
                      filled: true,
                      fillColor: cs.sunken,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.borderHairline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.borderHairline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _filters.isDefault ? cs.surface : cs.primary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _filters.isDefault
                              ? cs.borderHairline
                              : cs.primary,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => showFiltersSheet(
                          context,
                          _filters,
                          (applied) => setState(() => _filters = applied),
                        ),
                        icon: Icon(
                          AppIcons.filter,
                          size: 22,
                          color: _filters.isDefault
                              ? cs.textPrimary
                              : cs.onPrimary,
                        ),
                        tooltip: 'Filters',
                      ),
                    ),
                    if (!_filters.isDefault)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: cs.danger,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.canvas, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // --- Active filter chips ----------------------------------------
          if (!_filters.isDefault)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final category in _filters.categories) ...[
                    CsFilterChip(
                      label: category,
                      selected: true,
                      onTap: () => setState(
                        () => _filters = _filters.copyWith(
                          categories: {..._filters.categories}..remove(
                            category,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_filters.access != 'All') ...[
                    CsFilterChip(
                      label: _filters.access,
                      selected: true,
                      onTap: () => setState(
                        () => _filters = _filters.copyWith(access: 'All'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_filters.sort != 'Popular') ...[
                    CsFilterChip(
                      label: 'Sort: ${_filters.sort}',
                      selected: true,
                      onTap: () => setState(
                        () => _filters = _filters.copyWith(sort: 'Popular'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (!_filters.isDefault) const SizedBox(height: 12),

          // --- Body: recents / results / empty state ----------------------
          Expanded(
            child: showRecents
                ? _Recents(
                    recents: _recents,
                    onSelect: (recent) {
                      _controller.text = recent;
                      setState(() => _query = recent);
                    },
                    onClear: () => setState(() => _recents = []),
                  )
                : results.isEmpty
                    ? CsEmptyState(
                        icon: AppIcons.search,
                        title: "No results for '$_query'",
                        body: 'Try a different keyword, or clear your '
                            'filters to see every course.',
                        actionLabel: 'Clear search',
                        onAction: () {
                          _controller.clear();
                          setState(() {
                            _query = '';
                            _filters = const FilterState();
                          });
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                        itemCount: results.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final course = results[index];
                          return CsCourseListCard(
                            course: course,
                            onTap: () =>
                                context.push('/course/${course.id}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _Recents extends StatelessWidget {
  const _Recents({
    required this.recents,
    required this.onSelect,
    required this.onClear,
  });

  final List<String> recents;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        if (recents.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent searches',
                  style: AppText.h3.copyWith(color: cs.textPrimary),
                ),
              ),
              TextButton(
                onPressed: onClear,
                child: Text(
                  'Clear all',
                  style: AppText.label.copyWith(color: cs.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final recent in recents)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                AppIcons.clock,
                size: 20,
                color: cs.textTertiary,
              ),
              title: Text(
                recent,
                style: AppText.body.copyWith(color: cs.textPrimary),
              ),
              trailing: Icon(
                AppIcons.arrowUp,
                size: 18,
                color: cs.textTertiary,
              ),
              onTap: () => onSelect(recent),
            ),
          const SizedBox(height: 16),
        ],
        Text(
          'Popular right now',
          style: AppText.h3.copyWith(color: cs.textPrimary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final term in [
              'React',
              'Python',
              'JavaScript',
              'MERN',
              'Interview prep',
            ])
              CsFilterChip(
                label: term,
                selected: false,
                onTap: () => onSelect(term),
              ),
          ],
        ),
      ],
    );
  }
}
