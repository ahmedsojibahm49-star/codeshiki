// Shared helpers for the CodeShikhi widget tests.
//
// Read this before writing a new widget test — Hive + flutter_test has
// three traps that each cost a debugging session:
//
// 1. NEVER await a Hive write (put/delete/clear/close) inside a widget
//    test. Hive serialises backend writes through future chains
//    (ReadWriteSync); a write started in one test's FakeAsync zone never
//    completes after that zone dies, so any later awaited Hive op chained
//    behind it hangs forever. `HiveBoxes.clearAll()` and `Hive.close()`
//    both hang for this reason. Instead, reset + seed with fire-and-
//    forget `put`/`delete`: Hive stages those in the in-memory keystore
//    synchronously (beginTransaction), and the providers only ever read
//    memory. See [resetHiveSync].
// 2. RenderFlex overflows are test-font artifacts: flutter_tester uses
//    Ahem test fonts (every glyph is a full-em square), so text rows that
//    fit with real fonts overflow in tests (e.g. the Home course-card
//    rating row). [ignoringOverflows] swallows ONLY 'overflowed' errors
//    inside the test body (a setUp override is wiped: the binding
//    installs its own FlutterError.onError at body start).
// 3. Reset debugDefaultTargetPlatformOverride INSIDE the test body
//    (see [withPlatform]): postTest's invariant check runs before
//    tearDown, so a tearDown reset is too late and fails the test.
// 4. Never call `appRouter.go()` before the first pumpWidget: it hangs.
//    Pump first, then navigate with the router attached.
// 5. Never use pumpAndSettle on screens with indeterminate progress
//    indicators (Splash, Player loading) — they schedule frames forever.
//    Advance time with explicit pump(Duration) calls instead.
import 'dart:async';
import 'dart:io';

import 'package:codeshikhi/app.dart';
import 'package:codeshikhi/data/demo_data.dart';
import 'package:codeshikhi/data/hive_boxes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Creates a fresh temp dir, points Hive at it and opens all boxes.
/// Call from setUpAll. Each test file runs in its own isolate with its
/// own temp dir, so files never share Hive state.
Future<Directory> initHiveForTests() async {
  final dir =
      await Directory.systemTemp.createTemp('codeshikhi_test');
  Hive.init(dir.path);
  await HiveBoxes.init();
  return dir;
}

/// Best-effort temp dir cleanup for tearDownAll. Intentionally does NOT
/// call Hive.close() — it hangs under flutter_test (see the header note).
/// The test process exits right after, so the OS reclaims the handles.
Future<void> disposeHiveForTests(Directory dir) async {
  try {
    await dir.delete(recursive: true);
  } catch (_) {
    // Temp dirs are disposable; a failed delete is not a test failure.
  }
}

/// Synchronous Hive reset: deletes every key in every box WITHOUT
/// awaiting. Memory state is cleared synchronously (see the header note),
/// which is what the providers read. Call from setUp and tearDown.
void resetHiveSync() {
  for (final box in [
    HiveBoxes.settings,
    HiveBoxes.auth,
    HiveBoxes.enrollments,
    HiveBoxes.wallet,
    HiveBoxes.downloads,
    HiveBoxes.forum,
    HiveBoxes.notifications,
    HiveBoxes.orders,
    HiveBoxes.notes,
    HiveBoxes.code,
  ]) {
    for (final key in box.keys.toList()) {
      // Fire-and-forget on purpose: the in-memory removal is synchronous;
      // awaiting the disk write can hang (see the header note).
      unawaited(box.delete(key));
    }
  }
}

/// Marks every default-unlocked badge celebrated so ProfileScreen's
/// achievement dialog never pops mid-test. The tab shell is an
/// IndexedStack, so Profile builds eagerly on first frame and its 600ms
/// celebration timer fires whatever tab is showing; the modal dialog
/// would swallow nav taps. Memory writes are synchronous.
void _seedCelebratedBadges() {
  HiveBoxes.settings.put(
    'celebratedBadges',
    DemoData.badges
        .where((b) => b.unlocked)
        .map((b) => b.id)
        .toList(),
  );
}

/// Seeds a logged-in demo user (Rahim Uddin) + seen intro. Memory writes
/// are synchronous; call before pumping.
void seedLoggedIn() {
  HiveBoxes.auth.put('session', DemoData.demoEmail);
  HiveBoxes.settings.put('seenIntro', true);
  _seedCelebratedBadges();
}

/// Seeds a logged-out user who has seen the intro (splash routes to
/// /welcome). Memory writes are synchronous; call before pumping.
void seedLoggedOut() {
  HiveBoxes.settings.put('seenIntro', true);
  _seedCelebratedBadges();
}

/// Advances fake time past the app's bare one-shot timers (splash 1.5s,
/// achievement celebration 600ms). Call at the end of a full-app test:
/// postTest fails the test if any Timer is still pending, and a bare
/// Future.delayed outlives its widget — the splash timer still counts
/// after go('/login') unmounted the splash. (SnackBar timers are fine:
/// ScaffoldMessenger cancels them when the tree disposes.)
Future<void> drainPendingTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
}

/// Runs [body] with RenderFlex overflow errors swallowed (test-font
/// artifacts — see the header note). All other errors are forwarded to
/// the test framework's handler. MUST be called inside the test body,
/// and restores the handler before returning so real failures surface.
Future<void> ignoringOverflows(Future<void> Function() body) async {
  final old = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    old?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = old;
  }
}

/// Sets [debugDefaultTargetPlatformOverride] for [body] and resets it
/// BEFORE returning (postTest checks foundation debug vars before
/// tearDown runs). The default test platform on a Linux host is Linux,
/// NOT Android — always set this explicitly in nav tests.
Future<void> withPlatform(
  TargetPlatform platform,
  Future<void> Function() body,
) async {
  final old = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = old;
  }
}

/// Pumps the full app in a fresh ProviderScope. The global [appRouter]
/// keeps its location between tests in a file: navigate after pumping
/// (never before — see the header note).
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: CodeShikhiApp()),
  );
  await tester.pump();
}

/// Finder for the iOS floating glass pill container in [AppShell]:
/// the only r32 container with a shadow in the app.
Finder get floatingPillFinder => find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).borderRadius ==
              BorderRadius.circular(32) &&
          ((widget.decoration as BoxDecoration).boxShadow?.isNotEmpty ??
              false),
    );
