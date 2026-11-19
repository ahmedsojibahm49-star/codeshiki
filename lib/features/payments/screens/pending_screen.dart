import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Payment pending [I11]: wallet TrxID received, manual verification.
///
/// NOTE: nothing is enrolled or granted here — verification is manual, so
/// Pro / enrollment only apply once the payment is confirmed (honest demo
/// behavior).
class PendingScreen extends StatelessWidget {
  const PendingScreen({
    super.key,
    this.courseId,
    this.plan,
    this.total,
    this.coupon,
    this.method,
    this.trxId,
  });

  final String? courseId;
  final String? plan;
  final int? total;
  final String? coupon;
  final String? method;
  final String? trxId;

  String get _method => method ?? 'bKash';

  int get _total =>
      total ??
      discountedTotal(
        price: itemPrice(courseId: courseId, plan: plan),
        couponCode: coupon,
      );

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      appBar: const CsTopBar(title: 'Payment pending', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: cs.warningSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.clockBold,
                  size: 48,
                  color: cs.warning,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'We received your $_method payment',
              textAlign: TextAlign.center,
              style: AppText.h1.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Verification usually takes under 2 hours. We will notify you '
              'as soon as it is confirmed.',
              textAlign: TextAlign.center,
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Item',
                    value: itemTitle(courseId: courseId, plan: plan),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(label: 'Amount', value: formatTaka(_total)),
                  const SizedBox(height: 10),
                  _DetailRow(label: 'Method', value: _method),
                  if (trxId != null) ...[
                    const SizedBox(height: 10),
                    _DetailRow(label: 'TrxID', value: trxId!, mono: true),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            CsButton(
              label: 'Contact support',
              variant: CsButtonVariant.secondary,
              icon: AppIcons.message,
              onPressed: () => context.push('/settings/support'),
            ),
            const SizedBox(height: 12),
            CsButton(
              label: 'Back to home',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

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
            style: (mono ? AppText.code : AppText.label)
                .copyWith(color: cs.textPrimary),
          ),
        ),
      ],
    );
  }
}
