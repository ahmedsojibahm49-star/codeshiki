import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Payment failed [I10]: reassurance + retry paths.
class FailedScreen extends StatelessWidget {
  const FailedScreen({
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

  String get _methodsPath => withQuery(
        '/payments/methods',
        checkoutParams(
          courseId: courseId,
          plan: plan,
          total: total,
          coupon: coupon,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      appBar: const CsTopBar(title: 'Payment', showBack: false),
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
                  color: cs.dangerSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.closeBold,
                  size: 48,
                  color: cs.danger,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment failed',
              textAlign: TextAlign.center,
              style: AppText.h1.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'No money was taken from your account.',
              textAlign: TextAlign.center,
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'This can happen when the network drops or the payment is '
              'declined. Please try again.',
              textAlign: TextAlign.center,
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 32),
            CsButton(
              label: 'Try again',
              icon: AppIcons.refresh,
              onPressed: () => context.push(_methodsPath),
            ),
            const SizedBox(height: 12),
            CsButton(
              label: 'Choose another method',
              variant: CsButtonVariant.secondary,
              onPressed: () => context.push(_methodsPath),
            ),
            const SizedBox(height: 12),
            CsButton(
              label: 'Back to home',
              variant: CsButtonVariant.ghost,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
