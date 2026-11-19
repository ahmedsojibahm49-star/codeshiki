import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_sheet.dart';

/// Search filter state, owned by [SearchScreen] and edited in [FiltersSheet].
class FilterState {
  const FilterState({
    this.categories = const {},
    this.access = 'All',
    this.sort = 'Popular',
  });

  /// Empty set = all categories.
  final Set<String> categories;

  /// 'All' | 'Free' | 'Pro' | 'Paid'.
  final String access;

  /// 'Popular' | 'Rating' | 'Newest'.
  final String sort;

  bool get isDefault =>
      categories.isEmpty && access == 'All' && sort == 'Popular';

  FilterState copyWith({
    Set<String>? categories,
    String? access,
    String? sort,
  }) =>
      FilterState(
        categories: categories ?? this.categories,
        access: access ?? this.access,
        sort: sort ?? this.sort,
      );
}

Future<void> showFiltersSheet(
  BuildContext context,
  FilterState initial,
  ValueChanged<FilterState> onApply,
) =>
    showCsSheet(
      context,
      FiltersSheet(initial: initial, onApply: onApply),
    );

/// Search filters sheet [B07]: category multi-select, access, sort.
class FiltersSheet extends StatefulWidget {
  const FiltersSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  final FilterState initial;
  final ValueChanged<FilterState> onApply;

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  static const List<String> _accessOptions = ['All', 'Free', 'Pro', 'Paid'];
  static const List<String> _sortOptions = ['Popular', 'Rating', 'Newest'];

  late Set<String> _categories = Set.of(widget.initial.categories);
  late String _access = widget.initial.access;
  late String _sort = widget.initial.sort;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filters',
                  style: AppText.h2.copyWith(color: cs.textPrimary),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _categories = {};
                  _access = 'All';
                  _sort = 'Popular';
                }),
                child: Text(
                  'Reset',
                  style: AppText.label.copyWith(color: cs.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Category',
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final category in DemoData.categories)
                CsFilterChip(
                  label: category,
                  selected: _categories.contains(category),
                  onTap: () => setState(() {
                    if (!_categories.remove(category)) {
                      _categories.add(category);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Access',
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final option in _accessOptions)
                CsFilterChip(
                  label: option,
                  selected: _access == option,
                  onTap: () => setState(() => _access = option),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Sort by',
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final option in _sortOptions)
                CsFilterChip(
                  label: option,
                  selected: _sort == option,
                  onTap: () => setState(() => _sort = option),
                ),
            ],
          ),
          const SizedBox(height: 24),
          CsButton(
            label: 'Apply filters',
            onPressed: () {
              widget.onApply(
                FilterState(
                  categories: _categories,
                  access: _access,
                  sort: _sort,
                ),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
