import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../sheets/filter_sheet.dart';
import '../sheets/notif_settings_sheet.dart';

/// Notifications [J01] — tab-nested under Home (coordinator wires it).
/// Lists notifications from [notificationsProvider]; unread rows get an
/// orange dot + tinted background.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _filter = NotifFilter.all;

  IconData _iconFor(String type) {
    switch (type) {
      case 'lesson':
        return AppIcons.video;
      case 'course':
        return AppIcons.book;
      case 'streak':
        return AppIcons.flash;
      case 'reply':
        return AppIcons.messages;
      case 'certificate':
        return AppIcons.award;
      case 'payment':
        return AppIcons.receipt;
      case 'reminder':
        return AppIcons.clock;
      case 'achievement':
        return AppIcons.trophy;
      default:
        return AppIcons.bell;
    }
  }

  Future<void> _openFilter() async {
    final selected = await showFilterSheet(context, _filter);
    if (selected != null && mounted) {
      setState(() => _filter = selected);
    }
  }

  Future<void> _openNotifSettings() async {
    final openAll = await showNotifSettingsSheet(context);
    if (openAll && mounted) {
      context.push('/settings/notifications');
    }
  }

  void _onTap(AppNotification notification) {
    ref.read(notificationsProvider.notifier).markRead(notification.id);
    if (notification.type == 'lesson' || notification.type == 'course') {
      // Demo: no deep-link target yet — mark read + confirm.
      showCsToast(context, 'Opening ${notification.title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final all = ref.watch(notificationsProvider);
    final visible = all
        .where((n) => NotifFilter.matches(_filter, n.type, n.read))
        .toList();
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(
        title: context.tr('notifications'),
        showBack: false,
        actions: [
          IconButton(
            onPressed: _openNotifSettings,
            icon: Icon(AppIcons.settings, color: cs.textPrimary),
            tooltip: 'Notification settings',
          ),
          IconButton(
            onPressed: _openFilter,
            icon: Icon(
              _filter == NotifFilter.all ? AppIcons.filter : AppIcons.filterBold,
              color: _filter == NotifFilter.all ? cs.textPrimary : cs.primary,
            ),
            tooltip: 'Filter',
          ),
          TextButton(
            onPressed: unreadCount == 0
                ? null
                : () =>
                    ref.read(notificationsProvider.notifier).markAllRead(),
            child: Text(
              context.tr('markAllRead'),
              style: AppText.label.copyWith(color: cs.accent),
            ),
          ),
        ],
      ),
      body: visible.isEmpty
          ? _emptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: visible.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = visible[index];
                final unread = !notification.read;
                return InkWell(
                  onTap: () => _onTap(notification),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: unread
                          ? cs.primary.withValues(alpha: 0.08)
                          : cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: unread
                            ? cs.primary.withValues(alpha: 0.25)
                            : cs.borderHairline,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cs.sunken,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _iconFor(notification.type),
                            size: 22,
                            color: cs.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: AppText.body.copyWith(
                                        color: cs.textPrimary,
                                        fontWeight: unread
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (unread)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                        color: cs.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.body,
                                style: AppText.bodySmall.copyWith(
                                  color: cs.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notification.timeLabel,
                                style: AppText.caption.copyWith(
                                  color: cs.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Empty state [J03] — shown when the list (or the active filter) is empty.
  Widget _emptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 100),
      child: CsEmptyState(
        icon: AppIcons.bell,
        title: context.tr('noNotifications'),
        body: _filter == NotifFilter.all
            ? 'When something new happens — a lesson, a reply, a payment — it will show up here.'
            : 'No notifications match this filter. Try a different one.',
        actionLabel:
            _filter == NotifFilter.all ? null : 'Show all',
        onAction: _filter == NotifFilter.all
            ? null
            : () => setState(() => _filter = NotifFilter.all),
      ),
    );
  }
}
