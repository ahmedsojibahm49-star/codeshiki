import 'package:material_ui/material_ui.dart';

import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// Renders a Flaticon badge PNG. When [locked], the image is shown in
/// grayscale with a small lock overlay.
class CsBadgeImage extends StatelessWidget {
  const CsBadgeImage({
    super.key,
    required this.badge,
    this.size = 72,
    this.locked = false,
  });

  final BadgeInfo badge;
  final double size;
  final bool locked;

  // Standard luminance grayscale matrix.
  static const _grayscale = <double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final image = Image.asset(
      badge.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
    final shown = locked
        ? ColorFiltered(
            colorFilter: const ColorFilter.matrix(_grayscale),
            child: image,
          )
        : image;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(opacity: locked ? 0.6 : 1, child: shown),
        if (locked)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: cs.surface,
                shape: BoxShape.circle,
                border: Border.all(color: cs.border),
              ),
              child: Icon(AppIcons.lock, size: 12, color: cs.textSecondary),
            ),
          ),
      ],
    );
  }
}
