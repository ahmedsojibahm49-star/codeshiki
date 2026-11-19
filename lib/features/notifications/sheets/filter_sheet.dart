import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_sheet.dart';

/// Notification filter values (J02).
class NotifFilter {
  NotifFilter._();

  static const String all = 'all';
  static const String unread = 'unread';
  static const String lesson = 'lesson';
  static const String community = 'community';
  static const String payment = 'payment';

  static const List<String> values = [
    all,
    unread,
    lesson,
    community,
    payment,
  ];

  static String label(String filter, BuildContext context) {
    switch (filter) {
      case unread:
        return 'Unread';
      case lesson:
        return 'Lessons';
      case community:
        return 'Community';
      case payment:
        return 'Payments';
      case all:
      default:
        return context.tr('all');
    }
  }

  /// Whether [type] (an AppNotification.type) belongs to [filter].
  static bool matches(String filter, String type, bool read) {
    switch (filter) {
      case unread:
        return !read;
      case lesson:
        return type == 'lesson' || type == 'course';
      case community:
        return type == 'reply';
      case payment:
        return type == 'payment';
      case all:
      default:
        return true;
    }
  }
}

/// Opens the filter sheet. Returns the newly selected filter, or null when
/// the sheet was dismissed without a change.
Future<String?> showFilterSheet(BuildContext context, String current) {
  return showCsSheet<String>(
    context,
    FilterSheet(current: current),
  );
}

/// Filter sheet [J02]: chips + a "Mark all read" row.
class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key, required this.current});

  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter notifications',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final filter in NotifFilter.values)
                CsFilterChip(
                  label: NotifFilter.label(filter, context),
                  selected: filter == current,
                  onTap: () => Navigator.of(context).pop(filter),
                ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              ref.read(notificationsProvider.notifier).markAllRead();
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(AppIcons.check, size: 20, color: cs.accent),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('markAllRead'),
                    style: AppText.body.copyWith(color: cs.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
