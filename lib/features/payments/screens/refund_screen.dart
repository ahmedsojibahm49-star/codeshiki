import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Refund request [I18]: reason + details, submitted per order.
class RefundScreen extends ConsumerStatefulWidget {
  const RefundScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends ConsumerState<RefundScreen> {
  final _detailsController = TextEditingController();
  String? _selectedReason;

  static const _reasons = [
    'Accidental purchase',
    'Course not as expected',
    'Technical issue',
    'Other',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedReason == null) {
      showCsToast(context, 'Please choose a reason', isError: true);
      return;
    }
    showCsToast(context, 'Refund request submitted');
    context.go('/profile/orders');
  }

  Order? _findOrder(List<Order> orders, String orderId) {
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final orders = ref.watch(ordersProvider);
    final orderId = widget.orderId;
    final order = orderId == null
        ? null
        : _findOrder(orders, orderId);
    return Scaffold(
      appBar: const CsTopBar(title: 'Request refund'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (order != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.courseTitle,
                            style: AppText.label.copyWith(
                              color: cs.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.invoiceNo,
                            style: AppText.caption.copyWith(
                              color: cs.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatTaka(order.amount),
                      style: AppText.h3.copyWith(color: cs.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Why are you requesting a refund?',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final reason in _reasons)
                  CsFilterChip(
                    label: reason,
                    selected: _selectedReason == reason,
                    onTap: () => setState(() => _selectedReason = reason),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            CsTextField(
              label: 'Details (optional)',
              hint: 'Tell us what happened…',
              controller: _detailsController,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Text(
              'Refunds are reviewed within 3 working days. Approved refunds '
              'go back to your original payment method.',
              style: AppText.caption.copyWith(color: cs.textTertiary),
            ),
            const SizedBox(height: 24),
            CsButton(
              label: 'Submit request',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
