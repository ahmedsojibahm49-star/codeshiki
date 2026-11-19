// Badges grid, lesson player, theme toggle, and language toggle tests.
//
// The player test tolerates the missing video platform in widget tests:
// VideoPlayerController.initialize() throws (no platform implementation)
// and PlayerScreen catches it into its error state — the test verifies
// the lesson title + player chrome render either way. SystemChrome calls
// from the player's dispose are swallowed with a mock method handler.
import 'dart:io';

import 'package:codeshikhi/data/demo_data.dart';
import 'package:codeshikhi/features/player/screens/player_screen.dart';
import 'package:codeshikhi/features/profile/screens/badges_screen.dart';
import 'package:codeshikhi/features/settings/screens/theme_screen.dart';
import 'package:codeshikhi/i18n/app_strings.dart';
import 'package:codeshikhi/providers/app_providers.dart';
import 'package:codeshikhi/theme/app_theme.dart';
import 'package:codeshikhi/widgets/cs_badge_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

/// Pumps [screen] directly with a fresh Riverpod scope.
Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump();
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await initHiveForTests();
  });

  tearDownAll(() async {
    await disposeHiveForTests(tempDir);
  });

  setUp(resetHiveSync);
  tearDown(resetHiveSync);

  testWidgets('badges grid renders all 12 badge images', (tester) async {
    await ignoringOverflows(() async {
      seedLoggedIn();
      // GridView.builder only builds visible cells: use a tall viewport
      // so all 4 rows (12 badges) are built at once.
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpScreen(tester, const BadgesScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CsBadgeImage), findsNWidgets(12));
      // Fresh Hive -> wallet defaults: the first 5 badges unlocked.
      expect(
        find.text(
          '5 of 12 unlocked — tap a badge to see how to earn it.',
        ),
        findsOneWidget,
      );
      // Every badge image loads from its Flaticon asset path.
      for (final badge in DemoData.badges) {
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName ==
                    badge.assetPath,
          ),
          findsOneWidget,
          reason: 'badge ${badge.id} should render ${badge.assetPath}',
        );
      }
    });
  });

  testWidgets('player screen renders the lesson without a video platform',
      (tester) async {
    await ignoringOverflows(() async {
      seedLoggedIn();
      // PlayerScreen.dispose restores portrait via SystemChrome, which
      // has no platform implementation in widget tests: swallow it.
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      final lesson = DemoData.courseById('react-js-zero')!.allLessons.first;
      expect(lesson.type, 'video');
      await pumpScreen(
        tester,
        PlayerScreen(
          lessonId: lesson.id,
          courseId: 'react-js-zero',
        ),
      );
      // Let the (failing) video init settle into the error state.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Lesson title + player chrome render despite no video platform.
      expect(find.text('Welcome to React'), findsWidgets);
      expect(find.text('Description'), findsOneWidget);
      expect(
        find.text('Could not load this video'),
        findsOneWidget,
        reason: 'video init fails in widget tests; the error state shows',
      );
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  test('theme toggle updates settings + AppTheme brightness', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(settingsProvider).themeMode, ThemeMode.system);
    container.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
    expect(container.read(settingsProvider).themeMode, ThemeMode.dark);
    expect(AppTheme.dark().brightness, Brightness.dark);
    expect(AppTheme.light().brightness, Brightness.light);
  });

  testWidgets('theme screen Dark card sets dark mode', (tester) async {
    await ignoringOverflows(() async {
      seedLoggedIn();
      await pumpScreen(tester, const ThemeScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Dark'));
      await tester.pump();
      await tester.tap(find.text('Dark'));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ThemeScreen)),
      );
      expect(
        container.read(settingsProvider).themeMode,
        ThemeMode.dark,
      );
    });
  });

  testWidgets('language toggle returns Bangla strings via tr',
      (tester) async {
    // Provider-level: setLocale persists the Bangla locale.
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(settingsProvider.notifier).setLocale(const Locale('bn'));
    expect(container.read(settingsProvider).locale, const Locale('bn'));

    // Widget-level: context.tr resolves Bangla for a known key. The
    // delegates mirror app.dart: without a bn-capable
    // GlobalMaterialLocalizations the framework throws.
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('bn'),
        supportedLocales: const [Locale('en'), Locale('bn')],
        // Plural delegates: includes the bn-capable Cupertino delegate too.
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Builder(
          builder: (context) => Text(context.tr('home')),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('হোম'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });
}
