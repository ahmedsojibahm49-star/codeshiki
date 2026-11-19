import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';

/// TEMPORARY placeholder screen. Feature builders replace these with real
/// screens; the coordinator wires them in app_router.dart.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.routing, size: 32, color: cs.accent),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppText.h2.copyWith(color: cs.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Coming in this build',
                style: AppText.bodySmall.copyWith(color: cs.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
