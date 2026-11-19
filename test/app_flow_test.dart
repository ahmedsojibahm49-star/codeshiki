// Login flow tests: splash -> welcome -> login -> home (demo login),
// login validation errors, and wrong-password errors.
//
// NOTE: the router redirect sends a logged-in /splash straight to /home,
// so the splash screen only appears for logged-out users.
import 'dart:io';

import 'package:codeshikhi/data/demo_data.dart';
import 'package:codeshikhi/navigation/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

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

  testWidgets('demo login: splash -> welcome -> login -> home',
      (tester) async {
    await ignoringOverflows(() async {
      await withPlatform(TargetPlatform.android, () async {
        seedLoggedOut();
        await pumpApp(tester);

        // Splash shows first (logged out), then routes to Welcome after
        // its 1.5s timer.
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        expect(find.text('Continue as guest'), findsOneWidget);
        expect(
          find.text('Ready to learn something new today?'),
          findsNothing,
        );

        // Welcome -> Login.
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Log in'),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Welcome back'), findsOneWidget);

        // Email field is pre-filled with the demo account.
        expect(find.text(DemoData.demoEmail), findsOneWidget);

        // One-tap demo login -> Home. The button sits below the fold in
        // the 800x600 test viewport: scroll it into view first.
        await tester.ensureVisible(find.text('Demo login'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.tap(find.text('Demo login'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(
          find.text('Ready to learn something new today?'),
          findsOneWidget,
        );
        await drainPendingTimers(tester);
      });
    });
  });

  testWidgets('invalid login shows errors and does not reach Home',
      (tester) async {
    await ignoringOverflows(() async {
      await withPlatform(TargetPlatform.android, () async {
        seedLoggedOut();
        await pumpApp(tester);
        // Stale location from the previous test is /home; navigate with
        // the router attached. Attaching logged-out redirects through
        // /splash. Route building lags the location by a frame or two,
        // and the splash stays mounted through its 300ms exit
        // transition — so finish that transition in sub-timer steps
        // (pump(duration) elapses the clock BEFORE building the frame,
        // so one 2s pump would fire the splash's 1.5s timer while it
        // is still mounted and navigate to /welcome mid-test).
        appRouter.go('/login');
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Welcome back'), findsOneWidget);
        await tester.pump(const Duration(seconds: 2));

        // Bad email + short password.
        await tester.enterText(
          find.byType(TextField).first,
          'not-an-email',
        );
        await tester.enterText(find.byType(TextField).last, '123');
        // (No ensureVisible: the Log in button is already in view, and
        // ensureVisible requires a single match.)
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Log in'),
        );
        await tester.pump();

        expect(
          find.text('Enter a valid email address'),
          findsOneWidget,
        );
        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );
        // Still on the login screen, not Home.
        expect(find.text('Welcome back'), findsOneWidget);
        expect(
          find.text('Ready to learn something new today?'),
          findsNothing,
        );
        await drainPendingTimers(tester);
      });
    });
  });

  testWidgets('wrong password shows a general error', (tester) async {
    await ignoringOverflows(() async {
      await withPlatform(TargetPlatform.android, () async {
        seedLoggedOut();
        await pumpApp(tester);
        // Same splash-transition sequencing as the test above: finish
        // the exit transition in 400ms steps so the splash unmounts
        // before its 1.5s timer fires.
        appRouter.go('/login');
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Welcome back'), findsOneWidget);
        await tester.pump(const Duration(seconds: 2));

        // Valid format, wrong credentials.
        await tester.enterText(
          find.byType(TextField).first,
          DemoData.demoEmail,
        );
        await tester.enterText(find.byType(TextField).last, 'wrongpass12');
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Log in'),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Wrong email or password'), findsOneWidget);
        expect(
          find.text('Ready to learn something new today?'),
          findsNothing,
        );
        await drainPendingTimers(tester);
      });
    });
  });
}
