import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Order detail [I13]: invoice block + download + refund entry.
/// Path param: `orderId`.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  Order? _findOrder(List<Order> orders) {
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final orders = ref.watch(ordersProvider);
    final order = _findOrder(orders);
    if (order == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Order'),
        body: CsEmptyState(
          icon: AppIcons.receipt,
          title: 'Order not found',
          body: 'This order may have been removed.',
          actionLabel: 'Back to orders',
          onAction: () => context.go('/profile/orders'),
        ),
      );
    }
    return Scaffold(
      appBar: const CsTopBar(title: 'Order details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.receiptBold, size: 22, color: cs.accent),
                      const SizedBox(width: 10),
                      Text(
                        'Invoice',
                        style: AppText.h2.copyWith(color: cs.textPrimary),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: order.status == 'Paid'
                              ? cs.successSoft
                              : cs.infoSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          order.status,
                          style: AppText.caption.copyWith(
                            color: order.status == 'Paid'
                                ? cs.success
                                : cs.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _InvoiceRow(label: 'Invoice no', value: order.invoiceNo),
                  const SizedBox(height: 12),
                  _InvoiceRow(label: 'Date', value: order.dateLabel),
                  const SizedBox(height: 12),
                  _InvoiceRow(label: 'Item', value: order.courseTitle),
                  const SizedBox(height: 12),
                  _InvoiceRow(
                    label: 'Amount',
                    value: formatTaka(order.amount),
                  ),
                  const SizedBox(height: 12),
                  _InvoiceRow(
                    label: 'Payment method',
                    value: order.paymentMethod,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CsButton(
              label: 'Download invoice',
              variant: CsButtonVariant.secondary,
              icon: AppIcons.download,
              onPressed: () =>
                  showCsToast(context, 'Invoice downloaded (demo)'),
            ),
            const SizedBox(height: 12),
            CsButton(
              label: 'Request refund',
              variant: CsButtonVariant.ghost,
              onPressed: () => context.push(
                '/payments/refund?orderId=${order.id}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.bodySmall.copyWith(color: cs.textSecondary),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
        ),
      ],
    );
  }
}
