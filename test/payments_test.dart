// Payments tests: WELCOME10 coupon math on the Pro checkout, free-course
// enrollment state, and Volts redemption.
//
// Screens are pumped directly (they take constructor args, no route args)
// inside a ProviderScope + MaterialApp. No network is touched: no test
// exercises the downloads provider or real payment calls.
import 'dart:io';

import 'package:codeshikhi/data/demo_data.dart';
import 'package:codeshikhi/data/hive_boxes.dart';
import 'package:codeshikhi/features/course/screens/course_detail_screen.dart';
import 'package:codeshikhi/features/payments/screens/checkout_screen.dart';
import 'package:codeshikhi/features/payments/screens/redeem_screen.dart';
import 'package:codeshikhi/providers/app_providers.dart';
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

  test('WELCOME10 coupon is exactly price - 150', () {
    final coupon = DemoData.couponByCode('WELCOME10');
    expect(coupon, isNotNull);
    expect(coupon!.applyTo(499), 349);
    expect(coupon.applyTo(1500), 1350);
  });

  testWidgets('WELCOME10 applies -৳150 to the Pro checkout total',
      (tester) async {
    await ignoringOverflows(() async {
      seedLoggedIn();
      await pumpScreen(tester, const CheckoutScreen(plan: 'pro'));

      // Pro plan is ৳499/month before any coupon: Price row + Total row.
      expect(find.text('৳499'), findsNWidgets(2));
      expect(find.text('Total'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'WELCOME10');
      await tester.tap(find.text('Apply'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Coupon WELCOME10 applied'), findsOneWidget);
      expect(find.text('-৳150'), findsOneWidget);
      expect(find.text('৳349'), findsOneWidget);
    });
  });

  testWidgets('invalid coupon shows an error and keeps the full price',
      (tester) async {
    await ignoringOverflows(() async {
      seedLoggedIn();
      await pumpScreen(tester, const CheckoutScreen(plan: 'pro'));

      await tester.enterText(find.byType(TextField), 'NOPE');
      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(find.text('Invalid coupon code'), findsOneWidget);
      expect(find.text('৳499'), findsNWidgets(2));
      expect(find.text('৳349'), findsNothing);
    });
  });

  testWidgets('free-course enroll changes state + CTA', (tester) async {
    await ignoringOverflows(() async {
      seedLoggedIn();
      // Demo defaults already enroll python-one-night; start unenrolled
      // so the test exercises the real enroll path.
      HiveBoxes.enrollments.put('state', {
        'enrolled': <String>[],
        'wishlist': <String>[],
        'completed': <String, dynamic>{},
        'quizBest': <String, dynamic>{},
      });
      await pumpScreen(
        tester,
        const CourseDetailScreen(courseId: 'python-one-night'),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Enroll for free'), findsOneWidget);

      await tester.tap(find.text('Enroll for free'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Enroll for free?'), findsOneWidget);

      await tester.tap(find.text('Enroll'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // CTA flips to Continue learning and the provider holds the course.
      expect(find.text('Continue learning'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourseDetailScreen)),
      );
      expect(
        container
            .read(enrollmentProvider)
            .enrolledCourseIds
            .contains('python-one-night'),
        isTrue,
      );
    });
  });

  testWidgets('redeem deducts 100 Volts for the AI hint pack',
      (tester) async {
    await ignoringOverflows(() async {
      seedLoggedIn();
      // Fresh Hive -> wallet defaults (320 Volts).
      await pumpScreen(tester, const RedeemScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('320 Volts'), findsOneWidget);

      await tester.tap(find.text('AI hint pack'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Redeem AI hint pack?'), findsOneWidget);

      await tester.tap(find.text('Redeem'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('220 Volts'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(RedeemScreen)),
      );
      expect(container.read(walletProvider).volts, 220);
    });
  });
}
