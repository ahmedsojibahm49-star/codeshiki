import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';

/// Dark pill toast with an icon. Errors show a danger icon.
void showCsToast(BuildContext context, String message, {bool isError = false}) {
  final cs = context.cs;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? AppIcons.dangerBold : AppIcons.checkBold,
            size: 20,
            color: isError ? const Color(0xFFFCA5A5) : AppColors.teal,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppText.bodySmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: cs.isDark ? cs.raised : AppColors.ink,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.border),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
