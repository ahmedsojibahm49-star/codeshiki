import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Round avatar: photo when [photoAsset] is set, initials in an orange
/// tint circle otherwise.
class CsAvatar extends StatelessWidget {
  const CsAvatar({
    super.key,
    this.photoAsset,
    required this.name,
    this.size = 48,
  });

  final String? photoAsset;
  final String name;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final hasPhoto = photoAsset != null && photoAsset!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.peachLight,
        border: Border.all(color: cs.borderHairline),
        image: hasPhoto
            ? DecorationImage(
                image: AssetImage(photoAsset!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? null
          : Text(
              _initials,
              style: AppText.label.copyWith(
                color: cs.accent,
                fontSize: size * 0.36,
              ),
            ),
    );
  }
}
