import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_text_field.dart';

/// Coupon picker bottom sheet [I04]: coupon chips (WELCOME10 −৳150,
/// STUDENT20 −20%) + a manual code field. Apply calls [onApply] with the
/// chosen code and closes the sheet.
class CouponSheet extends StatefulWidget {
  const CouponSheet({
    super.key,
    required this.onApply,
    this.initialCode,
  });

  final ValueChanged<String> onApply;
  final String? initialCode;

  @override
  State<CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<CouponSheet> {
  late final TextEditingController _controller;
  String? _selectedCode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode ?? '');
    final initial = widget.initialCode;
    if (initial != null && DemoData.couponByCode(initial) != null) {
      _selectedCode = initial.toUpperCase();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final code = (_selectedCode ?? _controller.text).trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorText = 'Enter a coupon code');
      return;
    }
    if (DemoData.couponByCode(code) == null) {
      setState(() => _errorText = 'Invalid coupon code');
      return;
    }
    widget.onApply(code);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apply a coupon',
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a coupon or enter a code.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final coupon in DemoData.coupons)
                CsFilterChip(
                  label: '${coupon.code} (${coupon.discountLabel})',
                  selected: _selectedCode == coupon.code,
                  onTap: () {
                    setState(() {
                      _selectedCode = coupon.code;
                      _controller.text = coupon.code;
                      _errorText = null;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
          CsTextField(
            label: 'Coupon code',
            hint: 'WELCOME10',
            controller: _controller,
            errorText: _errorText,
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
              if (_selectedCode != null &&
                  _controller.text.trim().toUpperCase() != _selectedCode) {
                setState(() => _selectedCode = null);
              }
            },
          ),
          const SizedBox(height: 20),
          CsButton(
            label: 'Apply coupon',
            onPressed: _apply,
          ),
        ],
      ),
    );
  }
}

/// Shows the [CouponSheet] and calls [onApply] with the chosen code.
Future<void> showCouponSheet(
  BuildContext context,
  ValueChanged<String> onApply, {
  String? initialCode,
}) {
  return showCsSheet<void>(
    context,
    CouponSheet(onApply: onApply, initialCode: initialCode),
  );
}
