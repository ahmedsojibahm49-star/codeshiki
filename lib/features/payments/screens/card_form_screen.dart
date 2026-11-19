import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Card payment form [I07]: number, expiry, CVC, name.
class CardFormScreen extends StatefulWidget {
  const CardFormScreen({
    super.key,
    this.courseId,
    this.plan,
    this.total,
    this.coupon,
  });

  final String? courseId;
  final String? plan;
  final int? total;
  final String? coupon;

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();
  String? _numberError;
  String? _expiryError;
  String? _cvcError;
  String? _nameError;

  @override
  void dispose() {
    _numberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  int get _total =>
      widget.total ??
      discountedTotal(
        price: itemPrice(courseId: widget.courseId, plan: widget.plan),
        couponCode: widget.coupon,
      );

  bool _validate() {
    final digits = _numberController.text.replaceAll(' ', '');
    final expiry = _expiryController.text;
    var valid = true;
    setState(() {
      _numberError = digits.length != 16 || int.tryParse(digits) == null
          ? 'Enter a valid 16-digit card number'
          : null;
      _expiryError = _isValidExpiry(expiry) ? null : 'Use MM/YY';
      _cvcError = _cvcController.text.length != 3 ||
              int.tryParse(_cvcController.text) == null
          ? '3 digits'
          : null;
      _nameError =
          _nameController.text.trim().isEmpty ? 'Enter the name on card' : null;
      valid = _numberError == null &&
          _expiryError == null &&
          _cvcError == null &&
          _nameError == null;
    });
    return valid;
  }

  static bool _isValidExpiry(String value) {
    final parts = value.split('/');
    if (parts.length != 2) return false;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    if (parts[0].length != 2 || parts[1].length != 2) return false;
    return true;
  }

  void _setControllerText(TextEditingController controller, String text) {
    if (controller.text == text) return;
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Digits only, truncated to [max] characters.
  static String _digitsOnly(String value, int max) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length > max ? digits.substring(0, max) : digits;
  }

  /// Groups card digits in fours: '42424242' -> '4242 4242'.
  void _onNumberChanged(String value) {
    final digits = _digitsOnly(value, 16);
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    _setControllerText(_numberController, buffer.toString());
    if (_numberError != null) setState(() => _numberError = null);
  }

  /// Inserts the '/' in MM/YY as the user types.
  void _onExpiryChanged(String value) {
    final digits = _digitsOnly(value, 4);
    final formatted =
        digits.length > 2 ? '${digits.substring(0, 2)}/${digits.substring(2)}' : digits;
    _setControllerText(_expiryController, formatted);
    if (_expiryError != null) setState(() => _expiryError = null);
  }

  /// Digits only, max 3.
  void _onCvcChanged(String value) {
    final digits = _digitsOnly(value, 3);
    _setControllerText(_cvcController, digits);
    if (_cvcError != null) setState(() => _cvcError = null);
  }

  void _pay() {
    if (!_validate()) return;
    context.push(
      withQuery(
        '/payments/processing',
        checkoutParams(
          courseId: widget.courseId,
          plan: widget.plan,
          total: _total,
          coupon: widget.coupon,
          method: 'Card',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      appBar: const CsTopBar(title: 'Pay with card'),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemTitle(courseId: widget.courseId, plan: widget.plan),
                    style: AppText.label.copyWith(color: cs.textPrimary),
                  ),
                  Text(
                    formatTaka(_total),
                    style: AppText.h3.copyWith(color: cs.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CsTextField(
              label: 'Card number',
              hint: '4242 4242 4242 4242',
              controller: _numberController,
              prefixIcon: AppIcons.card,
              keyboardType: TextInputType.number,
              errorText: _numberError,
              onChanged: _onNumberChanged,
            ),
            const SizedBox(height: 8),
            Text(
              'Demo: use 4242 4242 4242 4242',
              style: AppText.caption.copyWith(color: cs.textTertiary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CsTextField(
                    label: 'Expiry',
                    hint: 'MM/YY',
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    errorText: _expiryError,
                    onChanged: _onExpiryChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CsTextField(
                    label: 'CVC',
                    hint: '123',
                    controller: _cvcController,
                    keyboardType: TextInputType.number,
                    errorText: _cvcError,
                    onChanged: _onCvcChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CsTextField(
              label: 'Name on card',
              hint: 'Rahim Uddin',
              controller: _nameController,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 24),
            CsButton(
              label: 'Pay ${formatTaka(_total)}',
              icon: AppIcons.lock,
              onPressed: _pay,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.shield, size: 16, color: cs.textTertiary),
                const SizedBox(width: 6),
                Text(
                  'Demo checkout — card details never leave this device.',
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
