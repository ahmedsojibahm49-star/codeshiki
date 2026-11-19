import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Mobile-wallet payment [I06]: send money, paste the TrxID, submit.
class WalletPayScreen extends StatefulWidget {
  const WalletPayScreen({
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
  State<WalletPayScreen> createState() => _WalletPayScreenState();
}

class _WalletPayScreenState extends State<WalletPayScreen> {
  final _trxController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _trxController.dispose();
    super.dispose();
  }

  String get _method => widget.method ?? 'bKash';

  int get _total =>
      widget.total ??
      discountedTotal(
        price: itemPrice(courseId: widget.courseId, plan: widget.plan),
        couponCode: widget.coupon,
      );

  void _submit() {
    final trxId = _trxController.text.trim();
    if (trxId.length != 10) {
      setState(
        () => _errorText = 'TrxID must be exactly 10 characters',
      );
      return;
    }
    context.push(
      withQuery(
        '/payments/pending',
        checkoutParams(
          courseId: widget.courseId,
          plan: widget.plan,
          total: _total,
          coupon: widget.coupon,
          method: _method,
          trxId: trxId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      appBar: CsTopBar(title: 'Pay with $_method'),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: methodDotColor(context, _method),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Send $_method money to',
                        style: AppText.bodySmall.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          demoWalletNumber,
                          style: AppText.h1.copyWith(color: cs.textPrimary),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            const ClipboardData(text: demoWalletNumber),
                          );
                          if (!context.mounted) return;
                          showCsToast(context, 'Number copied');
                        },
                        icon: Icon(AppIcons.copy, color: cs.accent),
                        tooltip: 'Copy number',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount',
                        style: AppText.bodySmall.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                      Text(
                        formatTaka(_total),
                        style: AppText.h3.copyWith(color: cs.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How it works',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 12),
            _StepRow(
              number: '1',
              text: 'Send ${formatTaka(_total)} to the number above from '
                  'your $_method app.',
            ),
            const SizedBox(height: 10),
            const _StepRow(
              number: '2',
              text: 'Copy the TrxID from the confirmation message.',
            ),
            const SizedBox(height: 10),
            const _StepRow(
              number: '3',
              text: 'Paste the TrxID below and submit.',
            ),
            const SizedBox(height: 24),
            CsTextField(
              label: 'Transaction ID (TrxID)',
              hint: 'e.g. 9HX7K2M4PQ',
              controller: _trxController,
              errorText: _errorText,
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Demo: any 10 characters, e.g. 9HX7K2M4PQ',
              style: AppText.caption.copyWith(color: cs.textTertiary),
            ),
            const SizedBox(height: 24),
            CsButton(
              label: 'Submit TrxID',
              icon: AppIcons.send,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: cs.sunken,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppText.label.copyWith(color: cs.accent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: AppText.bodySmall.copyWith(color: cs.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
