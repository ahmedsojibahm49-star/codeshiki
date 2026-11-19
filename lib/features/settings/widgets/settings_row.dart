import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';

/// A settings section: small caps label + a rounded card of rows.
class CsSettingsSection extends StatelessWidget {
  const CsSettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppText.caption.copyWith(
              color: cs.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.borderHairline),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, indent: 68, color: cs.borderHairline),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A tappable settings row: icon tile + title (+ optional subtitle) +
/// trailing value text + caret.
class CsSettingsRow extends StatelessWidget {
  const CsSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.destructive = false,
    this.showCaret = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showCaret;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final titleColor = destructive ? cs.danger : cs.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: destructive ? cs.dangerSoft : cs.sunken,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: destructive ? cs.danger : cs.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body.copyWith(color: titleColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style:
                          AppText.caption.copyWith(color: cs.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value!,
                  style: AppText.bodySmall.copyWith(
                    color: cs.textSecondary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
            if (showCaret) ...[
              const SizedBox(width: 6),
              Icon(
                AppIcons.chevronRight,
                size: 18,
                color: cs.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A settings row with a trailing switch instead of a caret.
class CsSettingsToggleRow extends StatelessWidget {
  const CsSettingsToggleRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.sunken,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: cs.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.body.copyWith(color: cs.textPrimary),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppText.caption.copyWith(color: cs.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: cs.primary,
          ),
        ],
      ),
    );
  }
}
