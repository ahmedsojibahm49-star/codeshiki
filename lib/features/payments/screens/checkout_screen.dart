import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';
import '../sheets/coupon_sheet.dart';

/// Checkout [I03]: item summary, price rows, coupon, continue to payment.
///
/// Reached as `/payments/checkout?courseId=<id>` (course purchase) or
/// `/payments/checkout?plan=pro` (Pro subscription, ৳499/month).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, this.courseId, this.plan});

  final String? courseId;
  final String? plan;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _couponController = TextEditingController();
  String? _appliedCode;
  String? _couponError;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  int get _price =>
      itemPrice(courseId: widget.courseId, plan: widget.plan);

  int get _total => discountedTotal(price: _price, couponCode: _appliedCode);

  int get _discount => _price - _total;

  void _applyCouponCode(String code) {
    final clean = code.trim().toUpperCase();
    final coupon = DemoData.couponByCode(clean);
    if (coupon == null) {
      setState(() {
        _appliedCode = null;
        _couponError = 'Invalid coupon code';
      });
      return;
    }
    setState(() {
      _appliedCode = coupon.code;
      _couponError = null;
      _couponController.text = coupon.code;
    });
    showCsToast(context, 'Coupon applied: ${coupon.discountLabel} off');
  }

  void _continue() {
    context.push(
      withQuery(
        '/payments/methods',
        checkoutParams(
          courseId: widget.courseId,
          plan: widget.plan,
          total: _total,
          coupon: _appliedCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final course = widget.courseId == null
        ? null
        : DemoData.courseById(widget.courseId!);
    final isProPlan = widget.plan == 'pro';
    return Scaffold(
      appBar: const CsTopBar(title: 'Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Item summary.
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (course != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        course.coverPhoto,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: CsScheme.proGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.crownBold,
                        size: 32,
                        color: cs.onPrimary,
                      ),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemTitle(
                            courseId: widget.courseId,
                            plan: widget.plan,
                          ),
                          style: AppText.h3.copyWith(color: cs.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isProPlan
                              ? 'Billed monthly · Cancel anytime'
                              : (course?.instructor ?? ''),
                          style: AppText.bodySmall.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                        if (course != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${course.lessonsCount} lessons · ${course.hours}h',
                            style: AppText.caption.copyWith(
                              color: cs.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Coupon.
            Text(
              'Coupon',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CsTextField(
                    hint: 'Coupon code',
                    controller: _couponController,
                    prefixIcon: AppIcons.discount,
                    errorText: _couponError,
                    onChanged: (_) {
                      if (_couponError != null) {
                        setState(() => _couponError = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                CsButton(
                  label: 'Apply',
                  size: CsButtonSize.m,
                  fullWidth: false,
                  onPressed: () =>
                      _applyCouponCode(_couponController.text),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: CsButton(
                label: 'Browse coupons',
                variant: CsButtonVariant.ghost,
                size: CsButtonSize.s,
                fullWidth: false,
                onPressed: () => showCouponSheet(
                  context,
                  _applyCouponCode,
                  initialCode: _appliedCode,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Price rows.
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _PriceRow(label: 'Price', value: formatTaka(_price)),
                  const SizedBox(height: 10),
                  _PriceRow(
                    label: 'Discount',
                    value: _discount > 0
                        ? '-${formatTaka(_discount)}'
                        : formatTaka(0),
                    valueColor: _discount > 0 ? cs.success : null,
                  ),
                  if (_appliedCode != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Coupon $_appliedCode applied',
                        style: AppText.caption.copyWith(color: cs.success),
                      ),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _PriceRow(
                    label: 'Total',
                    value: formatTaka(_total),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CsButton(
              label: 'Continue to payment',
              icon: AppIcons.arrowRight,
              onPressed: _continue,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.shield, size: 16, color: cs.textTertiary),
                const SizedBox(width: 6),
                Text(
                  'Demo checkout — no real money moves.',
                  style: AppText.caption.copyWith(color: cs.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final style = isTotal ? AppText.h3 : AppText.body;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style.copyWith(
            color: isTotal ? cs.textPrimary : cs.textSecondary,
          ),
        ),
        Text(
          value,
          style: style.copyWith(color: valueColor ?? cs.textPrimary),
        ),
      ],
    );
  }
}
