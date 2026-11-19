import 'package:hive_flutter/hive_flutter.dart';

/// Hive box names + init. All boxes store `Map<String, dynamic>` or
/// primitives — NO TypeAdapters, no codegen.
class HiveBoxes {
  HiveBoxes._();

  static const String settingsBox = 'settings';
  static const String authBox = 'auth';
  static const String enrollmentsBox = 'enrollments';
  static const String walletBox = 'wallet';
  static const String downloadsBox = 'downloads';
  static const String forumBox = 'forum';
  static const String notificationsBox = 'notifications';
  static const String ordersBox = 'orders';
  // Lazily-opened feature boxes (player notes, code projects). Opened here
  // too so deleteAccount wipes them; Hive.openBox on an already-open box
  // just returns the existing instance.
  static const String notesBox = 'notes';
  static const String codeBox = 'code';

  static Future<void> init() async {
    await Future.wait([
      Hive.openBox<dynamic>(settingsBox),
      Hive.openBox<dynamic>(authBox),
      Hive.openBox<dynamic>(enrollmentsBox),
      Hive.openBox<dynamic>(walletBox),
      Hive.openBox<dynamic>(downloadsBox),
      Hive.openBox<dynamic>(forumBox),
      Hive.openBox<dynamic>(notificationsBox),
      Hive.openBox<dynamic>(ordersBox),
      Hive.openBox<dynamic>(notesBox),
      Hive.openBox<dynamic>(codeBox),
    ]);
  }

  /// Deletes all demo data (used by AuthState.deleteAccount).
  static Future<void> clearAll() async {
    await Future.wait([
      Hive.box<dynamic>(settingsBox).clear(),
      Hive.box<dynamic>(authBox).clear(),
      Hive.box<dynamic>(enrollmentsBox).clear(),
      Hive.box<dynamic>(walletBox).clear(),
      Hive.box<dynamic>(downloadsBox).clear(),
      Hive.box<dynamic>(forumBox).clear(),
      Hive.box<dynamic>(notificationsBox).clear(),
      Hive.box<dynamic>(ordersBox).clear(),
      Hive.box<dynamic>(notesBox).clear(),
      Hive.box<dynamic>(codeBox).clear(),
    ]);
  }

  static Box<dynamic> get settings => Hive.box<dynamic>(settingsBox);
  static Box<dynamic> get auth => Hive.box<dynamic>(authBox);
  static Box<dynamic> get enrollments => Hive.box<dynamic>(enrollmentsBox);
  static Box<dynamic> get wallet => Hive.box<dynamic>(walletBox);
  static Box<dynamic> get downloads => Hive.box<dynamic>(downloadsBox);
  static Box<dynamic> get forum => Hive.box<dynamic>(forumBox);
  static Box<dynamic> get notifications =>
      Hive.box<dynamic>(notificationsBox);
  static Box<dynamic> get orders => Hive.box<dynamic>(ordersBox);
  static Box<dynamic> get notes => Hive.box<dynamic>(notesBox);
  static Box<dynamic> get code => Hive.box<dynamic>(codeBox);
}

/// Helpers for reading Hive values back as typed Dart collections.
extension HiveReadHelpers on Box<dynamic> {
  Map<String, dynamic>? mapAt(String key) {
    final value = get(key);
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<Map<String, dynamic>> mapsAt(String key) {
    final value = get(key);
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  List<String> stringsAt(String key) {
    final value = get(key);
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
