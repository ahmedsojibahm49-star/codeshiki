import 'package:codeshikhi/data/demo_data.dart';
import 'package:codeshikhi/data/models.dart';
import 'package:codeshikhi/i18n/app_strings.dart';
import 'package:codeshikhi/providers/app_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoData', () {
    test('has 4 courses with the specified titles and prices', () {
      expect(DemoData.courses.length, 4);
      final byId = {for (final c in DemoData.courses) c.id: c};
      expect(byId['react-js-zero']!.title, 'React JS from Zero');
      expect(byId['react-js-zero']!.price, 1500);
      expect(byId['react-js-zero']!.access, 'paid');
      expect(byId['python-one-night']!.title, 'Python in One Night');
      expect(byId['python-one-night']!.access, 'free');
      expect(byId['mern-project-camp']!.title, 'Full-Stack MERN Project Camp');
      expect(byId['mern-project-camp']!.access, 'pro');
      expect(byId['dsa-java']!.title, 'DSA with Java');
      expect(byId['dsa-java']!.price, 1500);
    });

    test('each course has 3 modules and ~10 lessons', () {
      for (final course in DemoData.courses) {
        expect(course.modules.length, 3, reason: course.id);
        expect(course.allLessons.length, greaterThanOrEqualTo(10));
        expect(course.allLessons.length, lessThanOrEqualTo(11));
      }
    });

    test('first lesson of every course is unlocked', () {
      for (final course in DemoData.courses) {
        expect(course.allLessons.first.locked, isFalse, reason: course.id);
      }
    });

    test('demo user values match the spec', () {
      expect(DemoData.me.name, 'Rahim Uddin');
      expect(DemoData.me.email, 'demo@codeshikhi.app');
      expect(DemoData.demoXp, 1240);
      expect(DemoData.demoVolts, 320);
      expect(DemoData.demoStreakDays, 12);
      expect(DemoData.demoLevel, 7);
    });

    test('Rahim is rank 3 on the leaderboard', () {
      final me = DemoData.leaderboard.firstWhere((e) => e.isMe);
      expect(me.rank, 3);
      expect(me.xp, 1240);
      expect(DemoData.leaderboard.length, 8);
    });

    test('12 badges, first 5 unlocked', () {
      expect(DemoData.badges.length, 12);
      expect(
        DemoData.badges.take(5).every((b) => b.unlocked),
        isTrue,
      );
      expect(
        DemoData.badges.skip(5).every((b) => !b.unlocked),
        isTrue,
      );
    });

    test('coupons apply correctly', () {
      expect(DemoData.couponByCode('WELCOME10')!.applyTo(1500), 1350);
      expect(DemoData.couponByCode('STUDENT20')!.applyTo(1500), 1200);
      expect(DemoData.couponByCode('NOPE'), isNull);
    });

    test('9 sample videos', () {
      expect(DemoData.sampleVideos.length, 9);
    });

    test('forum has 6 questions', () {
      expect(DemoData.questions.length, 6);
      for (final q in DemoData.questions) {
        expect(q.answers.length, greaterThanOrEqualTo(2));
      }
    });

    test('notifications has 8 items', () {
      expect(DemoData.notifications.length, 8);
    });

    test('code projects exist with real file contents', () {
      expect(DemoData.codeProjects.length, 3);
      for (final p in DemoData.codeProjects) {
        expect(p.files, isNotEmpty);
        expect(p.runOutput, isNotEmpty);
        expect(p.tests, isNotEmpty);
      }
    });
  });

  group('Models', () {
    test('Course JSON round-trip', () {
      final course = DemoData.courses.first;
      final restored = Course.fromJson(course.toJson());
      expect(restored.id, course.id);
      expect(restored.allLessons.length, course.allLessons.length);
      expect(restored.modules.length, course.modules.length);
    });

    test('ForumQuestion JSON round-trip', () {
      final q = DemoData.questions.first;
      final restored = ForumQuestion.fromJson(q.toJson());
      expect(restored.answers.length, q.answers.length);
      expect(restored.tags, q.tags);
    });
  });

  group('Wallet', () {
    test('level = 1 + xp ~/ 200', () {
      expect(WalletNotifier.levelForXp(1240), 7);
      expect(WalletNotifier.levelForXp(0), 1);
      expect(WalletNotifier.levelForXp(200), 2);
    });
  });

  group('i18n', () {
    test('EN and BN maps cover the same keys', () {
      final en = AppStrings.values['en']!;
      final bn = AppStrings.values['bn']!;
      expect(bn.keys.toSet(), en.keys.toSet());
      expect(en.length, 120); // every key from the foundation brief
    });

    test('lookup falls back to English', () {
      expect(AppStrings.lookup('home', 'xx'), 'Home');
      expect(AppStrings.lookup('home', 'bn'), 'হোম');
    });
  });
}
