import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Processing [I08]: spinner while the (demo) payment confirms, then
/// auto-navigates to success after 2.4s.
class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({
    super.key,
    this.courseId,
    this.plan,
    this.total,
    this.coupon,
    this.method,
  });

  final String? courseId;
  final String? plan;
  final int? total;
  final String? coupon;
  final String? method;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  Timer? _timer;
  late final String _invoiceNo;

  int get _total =>
      widget.total ??
      discountedTotal(
        price: itemPrice(courseId: widget.courseId, plan: widget.plan),
        couponCode: widget.coupon,
      );

  @override
  void initState() {
    super.initState();
    // Mint the invoice here so the success screen reuses it — the
    // double-apply guard on success is keyed by this invoice number.
    _invoiceNo = newInvoiceNo();
    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      context.go(
        withQuery(
          '/payments/success',
          checkoutParams(
            courseId: widget.courseId,
            plan: widget.plan,
            total: _total,
            coupon: widget.coupon,
            method: widget.method,
            invoice: _invoiceNo,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _simulateFailure() {
    _timer?.cancel();
    context.go(
      withQuery(
        '/payments/failed',
        checkoutParams(
          courseId: widget.courseId,
          plan: widget.plan,
          total: _total,
          coupon: widget.coupon,
          method: widget.method,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      appBar: const CsTopBar(title: 'Processing', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Processing payment…',
              textAlign: TextAlign.center,
              style: AppText.h1.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Do not close the app.',
              textAlign: TextAlign.center,
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Item',
                    value: itemTitle(
                      courseId: widget.courseId,
                      plan: widget.plan,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SummaryRow(
                    label: 'Method',
                    value: widget.method ?? 'Card',
                  ),
                  const SizedBox(height: 10),
                  _SummaryRow(label: 'Total', value: formatTaka(_total)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: CsButton(
                label: 'Demo: simulate failure',
                variant: CsButtonVariant.ghost,
                size: CsButtonSize.s,
                fullWidth: false,
                onPressed: _simulateFailure,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
