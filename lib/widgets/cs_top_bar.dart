import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';

/// Screen top bar: 44px back caret + H3 title + trailing actions.
/// Usable as a Scaffold `appBar` (implements PreferredSizeWidget).
class CsTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CsTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.showBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return AppBar(
      title: Text(title, style: AppText.h3.copyWith(color: cs.textPrimary)),
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: Icon(
                AppIcons.chevronLeft,
                color: cs.textPrimary,
              ),
              iconSize: 24,
              splashRadius: 22,
              tooltip: 'Back',
            )
          : null,
      actions: actions,
    );
  }
}
