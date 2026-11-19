import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Modal bottom sheet, radius 28 top, grabber handle, surface bg.
Future<T?> showCsSheet<T>(BuildContext context, Widget child) {
  final cs = context.cs;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(child: child),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
