import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/hive_boxes.dart';

/// Android immersive mode: hide ONLY the system navigation bar, KEEP the
/// status bar visible (the user's rule). Uses `SystemUiMode.manual` with
/// just the top overlay — NOT immersiveSticky, which hides the status bar
/// too. Re-applied on resume because the OS restores the bars when the user
/// swipes them back.
void _applyImmersiveMode() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }
}

class _ImmersiveObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _applyImmersiveMode();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await HiveBoxes.init();

  // No orientation lock: fullscreen video needs landscape.
  _applyImmersiveMode();
  WidgetsBinding.instance.addObserver(_ImmersiveObserver());

  runApp(
    const ProviderScope(
      child: CodeShikhiApp(),
    ),
  );
}
