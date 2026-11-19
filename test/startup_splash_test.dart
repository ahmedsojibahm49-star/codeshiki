import 'dart:io';

import 'package:codeshikhi/data/startup_storage.dart';
import 'package:codeshikhi/features/auth/screens/intro_screen.dart';
import 'package:codeshikhi/features/auth/screens/splash_screen.dart';
import 'package:codeshikhi/features/auth/screens/startup_error_screen.dart';
import 'package:codeshikhi/main.dart' as app;
import 'package:codeshikhi/providers/startup_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

/// Startup regression: EVERY path_provider call fails on the device
/// (StreamBox v1.0.2 on this user's phone: `ClassNotFoundException` for
/// `android.content.Context` on the documents, support, temp AND cache
/// calls — path_provider_android 2.3.1 resolves all four through the
/// same JNI `Context` binding). CodeShikhi's old `main()` awaited the
/// unguarded `Hive.initFlutter()` before runApp, so the app never
/// started at all — stuck on the launch splash forever.
///
/// Hive init must NOT depend on the platform channel: the pure-Dart
/// direct Android app-data path is tried first, and the app must still
/// start and route past the splash.
///
/// FAILS on the unfixed code: every path_provider attempt throws,
/// bootstrap has no direct path, and the app lands on the startup error
/// screen instead of the intro.
///
/// The direct candidates are injected through the
/// [debugDirectHiveCandidates] test seam (temp dirs) — tests run on a
/// Linux host where `defaultTargetPlatform` is Android, so the real
/// `/data/...` candidates must never be used here.
///
/// NOTE: this file intentionally does NOT use `initHiveForTests()` — the
/// real [app.bootstrap] does the Hive init. And it never calls
/// `Hive.close()` (it hangs under flutter_test — see test_helpers.dart).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory directDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('codeshikhi-direct');
    // A nested path, so the test also proves recursive creation works.
    directDir = Directory('${tempDir.path}/direct/app_flutter');
    // The test seam: point the direct candidates at the temp dir.
    debugDirectHiveCandidates = [directDir.path];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall call) async {
        // Simulate the broken path_provider layer: EVERY call throws.
        throw PlatformException(
          code: 'ClassNotFound',
          message: 'simulated path_provider failure (${call.method})',
        );
      },
    );
  });

  tearDownAll(() async {
    debugDirectHiveCandidates = null;
    await disposeHiveForTests(tempDir);
  });

  /// Pump frames until [finder] matches (or [maxPumps] is reached).
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 60,
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  testWidgets(
      'all path_provider calls failing still starts via the direct path',
      (tester) async {
    // Run the REAL bootstrap (Hive init with direct path + open boxes).
    // runAsync is REQUIRED (real file I/O); runCodeShikhiApp must stay
    // OUTSIDE runAsync so the splash's 1.5s timer runs in the FakeAsync
    // zone.
    final startup = await tester.runAsync(() => bootstrap());
    expect(startup, isNotNull);
    final result = startup!;
    expect(result.storageReady, isTrue);

    // The boxes must live in the DIRECT path — path_provider was never
    // consulted (every one of its calls throws).
    expect(
      File('${directDir.path}/settings.hive').existsSync(),
      isTrue,
    );

    await ignoringOverflows(() async {
      app.runCodeShikhiApp(result);
      await tester.pump();

      // First frame: the splash must be visible (not the error screen).
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(StartupErrorScreen), findsNothing);

      // Splash routes after 1.5s (fresh install: no session, intro
      // unseen) and must land on /intro.
      await tester.pump(const Duration(milliseconds: 1600));
      await pumpUntil(tester, find.byType(IntroScreen));
      expect(find.byType(IntroScreen), findsOneWidget);

      await drainPendingTimers(tester);
    });
  });

  testWidgets('all Hive init failing shows the error screen, not a hang',
      (tester) async {
    // Disable the direct path AND break path_provider: nothing can init.
    debugDirectHiveCandidates = const [];
    final startup = await tester.runAsync(() => bootstrap());
    expect(startup, isNotNull);
    final result = startup!;
    expect(result.storageReady, isFalse);
    expect(result.storageError, isNotNull);
    // The error names every failed attempt (full diagnosis for the user).
    expect(
      result.storageError.toString(),
      contains('Hive init failed in all directories'),
    );

    await ignoringOverflows(() async {
      app.runCodeShikhiApp(result);
      await tester.pump();

      expect(find.byType(StartupErrorScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Copy error'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await drainPendingTimers(tester);
    });
  });
}
