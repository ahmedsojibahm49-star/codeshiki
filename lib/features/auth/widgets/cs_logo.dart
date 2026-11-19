import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';

/// CodeShikhi logo mark: orange rounded square + white ">" + caret bar.
/// (Figma logo: rounded square + chevron ">" + caret bar. No image needed.)
class CsLogo extends StatelessWidget {
  const CsLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '>',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.52,
              height: 1,
              color: Colors.white,
            ),
          ),
          SizedBox(width: size * 0.05),
          Container(
            width: size * 0.07,
            height: size * 0.36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
