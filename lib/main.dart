import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'features/auth/screens/startup_error_screen.dart';
import 'providers/startup_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never show a blank screen on a build failure: log the error and
  // render a visible branded error view instead of Flutter's blank
  // release-mode error widget. The previous onError handler (Flutter's
  // default, or the test framework's reporter in tests) is still called.
  // The ErrorWidget override is release/profile only: in debug builds the
  // red error screen is more useful, and flutter_test forbids changing
  // ErrorWidget.builder.
  final defaultOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    debugPrint('CodeShikhi FlutterError: ${details.exception}');
    defaultOnError?.call(details);
  };
  if (!kDebugMode) {
    ErrorWidget.builder = (details) => StartupErrorFallback(details: details);
  }

  // bootstrap() NEVER throws: a storage failure degrades to the startup
  // error screen (with Retry) instead of dying before runApp — an
  // unguarded Hive.initFlutter() here used to leave the Android launch
  // splash up forever.
  final startup = await bootstrap();

  // No orientation lock: fullscreen video needs landscape.
  WidgetsBinding.instance.addObserver(ImmersiveObserver());

  runCodeShikhiApp(startup);
}

/// Attach the app widget. Split out of [main] so widget tests can run
/// the real [bootstrap] (real file I/O) inside `tester.runAsync()` and
/// then call this in the test's FakeAsync zone — calling runApp inside
/// runAsync would run the first frame (and the splash's 1.5s timer) in
/// the real-async zone, where its timeouts use wall time instead of
/// fake time.
void runCodeShikhiApp(BootstrapResult startup) {
  runApp(
    ProviderScope(
      overrides: [
        startupProvider.overrideWith(() => StartupNotifier(startup)),
      ],
      child: const CodeShikhiApp(),
    ),
  );
}
