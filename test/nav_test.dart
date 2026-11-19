// Platform navigation tests (the user's explicit platform nav rule):
// Android/Web = docked Material 3 NavigationBar, iOS = floating glass
// pill tab island. Plus the fullscreen editor check (no bottom nav).
import 'dart:io';

import 'package:codeshikhi/navigation/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

/// Unique on-screen anchor per tab (checked after tapping the tab).
const _tabAnchors = {
  'Home': 'Ready to learn something new today?',
  'My Courses': 'In Progress (2)',
  'Code': 'Runs today: 0 / 10',
  'Community': 'Ask question',
  'Profile': 'Edit profile',
};

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

  testWidgets('Android: docked NavigationBar, all 5 tabs switch',
      (tester) async {
    await ignoringOverflows(() async {
      await withPlatform(TargetPlatform.android, () async {
        seedLoggedIn();
        await pumpApp(tester);
        appRouter.go('/home');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Docked bar present, pill absent.
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(floatingPillFinder, findsNothing);

        // Home is the default tab.
        expect(find.text(_tabAnchors['Home']!), findsOneWidget);

        // Tap through the other four tabs (Profile last: it shows an
        // achievement dialog 600ms after first build, and a modal
        // dialog would swallow the next nav tap).
        for (final tab in ['My Courses', 'Code', 'Community', 'Profile']) {
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(tab),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          expect(
            find.text(_tabAnchors[tab]!),
            findsOneWidget,
            reason: 'tab $tab should show its screen',
          );
        }
        await drainPendingTimers(tester);
      });
    });
  });

  testWidgets('iOS: floating pill, no NavigationBar, all 5 tabs switch',
      (tester) async {
    await ignoringOverflows(() async {
      await withPlatform(TargetPlatform.iOS, () async {
        seedLoggedIn();
        await pumpApp(tester);
        appRouter.go('/home');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Floating pill present instead of the docked bar.
        expect(find.byType(NavigationBar), findsNothing);
        expect(floatingPillFinder, findsOneWidget);

        // Home is the default tab.
        expect(find.text(_tabAnchors['Home']!), findsOneWidget);

        for (final tab in ['My Courses', 'Code', 'Community', 'Profile']) {
          await tester.tap(
            find.descendant(
              of: floatingPillFinder,
              matching: find.text(tab),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          expect(
            find.text(_tabAnchors[tab]!),
            findsOneWidget,
            reason: 'tab $tab should show its screen',
          );
        }
        await drainPendingTimers(tester);
      });
    });
  });

  testWidgets('editor opens fullscreen without bottom nav',
      (tester) async {
    await ignoringOverflows(() async {
      await withPlatform(TargetPlatform.android, () async {
        seedLoggedIn();
        await pumpApp(tester);
        appRouter.go('/home');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Open the Counter App project in the editor (top-level route).
        appRouter.go('/editor/counter-app');
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        // Editor content: project title, file tabs, Run button, code.
        // (File names appear twice: once in the tab row, once in the
        // file drawer Scaffold builds eagerly — hence findsWidgets.)
        expect(find.text('Counter App'), findsOneWidget);
        expect(find.text('App.jsx'), findsWidgets);
        expect(find.text('styles.css'), findsWidgets);
        expect(find.text('index.js'), findsWidgets);
        // Two Run buttons: the app-bar action + the key row's Run key.
        expect(find.text('Run'), findsNWidgets(2));
        expect(find.textContaining('useState'), findsWidgets);

        // No bottom nav of either style.
        expect(find.byType(NavigationBar), findsNothing);
        expect(floatingPillFinder, findsNothing);
        await drainPendingTimers(tester);
      });
    });
  });
}
