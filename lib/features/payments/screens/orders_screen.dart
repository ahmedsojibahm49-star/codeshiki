import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Orders list [I12], from [ordersProvider].
///
/// Tab-nested under Profile — the coordinator wires the route; this screen
/// just renders the list and pushes to the order detail.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    return Scaffold(
      appBar: const CsTopBar(title: 'My orders'),
      body: orders.isEmpty
          ? CsEmptyState(
              icon: AppIcons.receipt,
              title: 'No orders yet',
              body: 'Your purchases will show up here.',
              actionLabel: 'Browse courses',
              onAction: () => context.go('/home'),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: orders.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderTile(order: order);
              },
            ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/payments/orders/${order.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(AppIcons.receipt, size: 22, color: cs.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.courseTitle,
                      style: AppText.label.copyWith(color: cs.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.dateLabel} · ${order.invoiceNo}',
                      style:
                          AppText.caption.copyWith(color: cs.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatTaka(order.amount),
                    style: AppText.label.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  _StatusChip(status: order.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final (bg, fg) = switch (status) {
      'Paid' => (cs.successSoft, cs.success),
      'Pending' => (cs.warningSoft, cs.warning),
      'Failed' => (cs.dangerSoft, cs.danger),
      _ => (cs.infoSoft, cs.info),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: AppText.caption.copyWith(color: fg),
      ),
    );
  }
}
