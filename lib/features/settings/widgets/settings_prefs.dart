import '../../../data/hive_boxes.dart';

/// Extra toggle preferences that live outside [SettingsState].
/// Stored directly in the Hive `settings` box (plain primitives).
///
/// Documented keys:
/// - `pref_notifSound` (bool, default true) — notification sounds
/// - `pref_notifVibration` (bool, default true) — notification vibration
/// - `pref_lessonReminders` (bool, default true) — lesson reminder notifs
/// - `pref_communityReplies` (bool, default true) — forum reply notifs
/// - `pref_streakAlerts` (bool, default true) — streak-at-risk notifs
/// - `pref_promotions` (bool, default false) — promo / offer notifs
/// - `reminderTime` (int, default 540 = 9:00 AM) — minutes since midnight
/// - `reminderDays` (`List<String>`, default Sat–Thu) — reminder weekdays
/// - `videoQuality` (String, default 'Auto') — Auto / 480p / 720p
/// - `pref_wifiOnlyDownloads` (bool, default true)
/// - `pref_profileVisibility` (String, default 'Public') — Public / Friends
/// - `pref_showXpLeaderboard` (bool, default true)
/// - `pref_analytics` (bool, default true)
/// - `pref_reduceMotion` (bool, default false)
/// - `pref_highContrast` (bool, default false)
/// - `pref_largeTouchTargets` (bool, default false)
/// - `pref_googleLinked` (bool, default true) — Google linked account
class SettingsPrefs {
  SettingsPrefs._();

  static bool boolPref(String key, {bool defaultValue = true}) =>
      HiveBoxes.settings.get(key) as bool? ?? defaultValue;

  static void setBoolPref(String key, bool value) =>
      HiveBoxes.settings.put(key, value);

  static String stringPref(String key, {String defaultValue = ''}) =>
      HiveBoxes.settings.get(key) as String? ?? defaultValue;

  static void setStringPref(String key, String value) =>
      HiveBoxes.settings.put(key, value);

  static int intPref(String key, {int defaultValue = 0}) =>
      (HiveBoxes.settings.get(key) as num?)?.toInt() ?? defaultValue;

  static void setIntPref(String key, int value) =>
      HiveBoxes.settings.put(key, value);

  static List<String> stringListPref(
    String key, {
    List<String> defaultValue = const [],
  }) {
    final value = HiveBoxes.settings.get(key);
    if (value is List) return value.map((e) => e.toString()).toList();
    return List<String>.from(defaultValue);
  }

  static void setStringListPref(String key, List<String> value) =>
      HiveBoxes.settings.put(key, value);
}
