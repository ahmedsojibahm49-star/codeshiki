import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Labeled text field. Sunken fill, hairline border, radius 16.
class CsTextField extends StatelessWidget {
  const CsTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.prefixIcon,
    this.suffix,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppText.label.copyWith(color: cs.textPrimary)),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          style: AppText.body.copyWith(color: cs.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: cs.textTertiary),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
