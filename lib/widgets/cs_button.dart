import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

enum CsButtonVariant { primary, secondary, ghost, destructive, pro }

enum CsButtonSize { l, m, s }

/// Primary button. Orange bg + INK text (white on orange fails contrast).
/// Pro variant uses the app's ONLY gradient (#FF8A2A -> #E85D04).
class CsButton extends StatelessWidget {
  const CsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CsButtonVariant.primary,
    this.size = CsButtonSize.l,
    this.fullWidth = true,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final CsButtonVariant variant;
  final CsButtonSize size;
  final bool fullWidth;
  final bool loading;
  final IconData? icon;

  double get _height {
    switch (size) {
      case CsButtonSize.l:
        return 56;
      case CsButtonSize.m:
        return 48;
      case CsButtonSize.s:
        return 36;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final enabled = onPressed != null && !loading;

    Color bg;
    Color fg;
    BorderSide? side;
    switch (variant) {
      case CsButtonVariant.primary:
        bg = cs.primary;
        fg = cs.onPrimary;
      case CsButtonVariant.secondary:
        bg = cs.sunken;
        fg = cs.textPrimary;
      case CsButtonVariant.ghost:
        bg = Colors.transparent;
        fg = cs.accent;
      case CsButtonVariant.destructive:
        bg = cs.danger;
        fg = Colors.white;
      case CsButtonVariant.pro:
        bg = Colors.transparent; // gradient painted by the decorator below
        fg = cs.onPrimary;
    }
    if (variant == CsButtonVariant.secondary) {
      side = BorderSide(color: cs.border);
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: fg,
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: (size == CsButtonSize.s ? AppText.label : AppText.button)
                .copyWith(color: fg),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final button = SizedBox(
      height: _height,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: variant == CsButtonVariant.pro
              ? Colors.transparent
              : bg,
          foregroundColor: fg,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: variant == CsButtonVariant.pro
              ? Colors.transparent
              : bg.withValues(alpha: 0.5),
          disabledForegroundColor: fg.withValues(alpha: 0.6),
          side: side,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: content,
      ),
    );

    if (variant != CsButtonVariant.pro) return button;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: CsScheme.proGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: button,
    );
  }
}
