import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/demo_data.dart';
import '../data/download_platform.dart';
import '../data/hive_boxes.dart';
import '../data/models.dart';

// ===========================================================================
// Settings
// ===========================================================================

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.dataSaver = false,
    this.pushEnabled = true,
    this.studyReminders = true,
  });

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
        themeMode: ThemeMode.values.firstWhere(
          (m) => m.name == json['themeMode'],
          orElse: () => ThemeMode.system,
        ),
        locale: Locale(json['locale'] as String? ?? 'en'),
        dataSaver: json['dataSaver'] as bool? ?? false,
        pushEnabled: json['pushEnabled'] as bool? ?? true,
        studyReminders: json['studyReminders'] as bool? ?? true,
      );

  final ThemeMode themeMode;
  final Locale locale;
  final bool dataSaver;
  final bool pushEnabled;
  final bool studyReminders;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? dataSaver,
    bool? pushEnabled,
    bool? studyReminders,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        dataSaver: dataSaver ?? this.dataSaver,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        studyReminders: studyReminders ?? this.studyReminders,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'locale': locale.languageCode,
        'dataSaver': dataSaver,
        'pushEnabled': pushEnabled,
        'studyReminders': studyReminders,
      };
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final stored = HiveBoxes.settings.mapAt('settings');
    return stored == null
        ? const SettingsState()
        : SettingsState.fromJson(stored);
  }

  void _save() => HiveBoxes.settings.put('settings', state.toJson());

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _save();
  }

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
    _save();
  }

  void toggleDataSaver() {
    state = state.copyWith(dataSaver: !state.dataSaver);
    _save();
  }

  void togglePush() {
    state = state.copyWith(pushEnabled: !state.pushEnabled);
    _save();
  }

  void toggleReminders() {
    state = state.copyWith(studyReminders: !state.studyReminders);
    _save();
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

// ===========================================================================
// Auth (demo only — local accounts in Hive, no network)
// ===========================================================================

class AuthState {
  const AuthState({this.user});

  final UserProfile? user;

  bool get isLoggedIn => user != null;
}

class AuthNotifier extends Notifier<AuthState> {
  static const _accountsKey = 'accounts';
  static const _sessionKey = 'session';
  static const _profileKey = 'profile';
  static const _demoPasswordKey = 'demoPassword';

  /// Applies stored profile overrides (name/bio/avatar) for [email].
  /// The overrides map may be a partial map written by the edit-profile /
  /// account screens; missing keys fall back to [base]. An override stored
  /// for a different email is ignored.
  UserProfile _withProfile(UserProfile base, String email) {
    final profile = HiveBoxes.auth.mapAt(_profileKey);
    if (profile == null) return base;
    final profileEmail = profile['email'] as String?;
    if (profileEmail != null &&
        profileEmail.toLowerCase() != email.toLowerCase()) {
      return base;
    }
    return base.copyWith(
      name: profile['name'] as String? ?? base.name,
      bio: profile['bio'] as String? ?? base.bio,
      avatarPhoto: profile['avatarPhoto'] as String? ?? base.avatarPhoto,
    );
  }

  @override
  AuthState build() {
    final email = HiveBoxes.auth.get(_sessionKey) as String?;
    if (email == null) return const AuthState();
    if (email == DemoData.demoEmail) {
      return AuthState(user: _withProfile(DemoData.me, email));
    }
    final account = _accounts().firstWhere(
      (a) => a['email'] == email,
      orElse: () => <String, dynamic>{},
    );
    if (account.isEmpty) return const AuthState();
    return AuthState(
      user: _withProfile(
        UserProfile(
          name: account['name'] as String,
          email: account['email'] as String,
        ),
        email,
      ),
    );
  }

  List<Map<String, dynamic>> _accounts() =>
      HiveBoxes.auth.mapsAt(_accountsKey);

  void _saveAccounts(List<Map<String, dynamic>> accounts) =>
      HiveBoxes.auth.put(_accountsKey, accounts);

  /// Demo rule: accepts demo@codeshikhi.app/demo1234 AND any locally
  /// signed-up account. Returns false otherwise.
  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final demoPassword = HiveBoxes.auth.get(_demoPasswordKey) as String? ??
        DemoData.demoPassword;
    if (cleanEmail == DemoData.demoEmail && password == demoPassword) {
      await demoLogin();
      return true;
    }
    final account = _accounts().firstWhere(
      (a) => (a['email'] as String).toLowerCase() == cleanEmail,
      orElse: () => <String, dynamic>{},
    );
    if (account.isEmpty || account['password'] != password) return false;
    HiveBoxes.auth.put(_sessionKey, account['email']);
    state = AuthState(
      user: _withProfile(
        UserProfile(
          name: account['name'] as String,
          email: account['email'] as String,
        ),
        account['email'] as String,
      ),
    );
    return true;
  }

  /// Creates a local account and logs in. Returns false if the email is
  /// already registered.
  Future<bool> signup(String name, String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final accounts = _accounts();
    if (cleanEmail == DemoData.demoEmail ||
        accounts.any(
            (a) => (a['email'] as String).toLowerCase() == cleanEmail)) {
      return false;
    }
    accounts.add({
      'name': name.trim(),
      'email': cleanEmail,
      'password': password,
    });
    _saveAccounts(accounts);
    HiveBoxes.auth.put(_sessionKey, cleanEmail);
    state = AuthState(
      user: UserProfile(name: name.trim(), email: cleanEmail),
    );
    return true;
  }

  /// Logs in as the demo account (Rahim Uddin).
  Future<void> demoLogin() async {
    HiveBoxes.auth.put(_sessionKey, DemoData.demoEmail);
    state = AuthState(
      user: _withProfile(DemoData.me, DemoData.demoEmail),
    );
  }

  /// Updates the signed-in user's profile (name/bio/avatar). Stored in Hive
  /// and applied on every build, so edits survive restarts and are visible
  /// immediately. The local account record's name is kept in sync too.
  void updateProfile({String? name, String? bio, String? avatarPhoto}) {
    final user = state.user;
    if (user == null) return;
    final existing = HiveBoxes.auth.mapAt(_profileKey) ?? {};
    final updated = {
      'email': user.email,
      'name': name ?? existing['name'] ?? user.name,
      'bio': bio ?? existing['bio'] ?? user.bio,
      'avatarPhoto':
          avatarPhoto ?? existing['avatarPhoto'] ?? user.avatarPhoto,
    };
    HiveBoxes.auth.put(_profileKey, updated);
    if (user.email.toLowerCase() != DemoData.demoEmail) {
      final accounts = _accounts();
      for (final account in accounts) {
        if ((account['email'] as String).toLowerCase() ==
            user.email.toLowerCase()) {
          account['name'] = updated['name'];
        }
      }
      _saveAccounts(accounts);
    }
    state = AuthState(
      user: user.copyWith(
        name: updated['name'] as String,
        bio: updated['bio'] as String,
        avatarPhoto: updated['avatarPhoto'] as String,
      ),
    );
  }

  /// Changes the signed-in user's password. Returns false when the current
  /// password is wrong or nobody is logged in. The demo account's password
  /// override is stored in Hive (default `demo1234`).
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = state.user;
    if (user == null) return false;
    if (user.email.toLowerCase() == DemoData.demoEmail) {
      final stored = HiveBoxes.auth.get(_demoPasswordKey) as String? ??
          DemoData.demoPassword;
      if (currentPassword != stored) return false;
      HiveBoxes.auth.put(_demoPasswordKey, newPassword);
      return true;
    }
    final accounts = _accounts();
    final index = accounts.indexWhere(
      (a) =>
          (a['email'] as String).toLowerCase() ==
          user.email.toLowerCase(),
    );
    if (index == -1) return false;
    if (accounts[index]['password'] != currentPassword) return false;
    accounts[index]['password'] = newPassword;
    _saveAccounts(accounts);
    return true;
  }

  /// Clears the session; local accounts are kept.
  void logout() {
    HiveBoxes.auth.delete(_sessionKey);
    state = const AuthState();
  }

  /// Demo delete: wipes ALL Hive boxes and resets every provider to defaults.
  Future<void> deleteAccount() async {
    await HiveBoxes.clearAll();
    state = const AuthState();
    ref.invalidate(settingsProvider);
    ref.invalidate(enrollmentProvider);
    ref.invalidate(walletProvider);
    ref.invalidate(downloadsProvider);
    ref.invalidate(forumProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(ordersProvider);
    ref.invalidate(playerProvider);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ===========================================================================
// Enrollment
// ===========================================================================

class EnrollmentState {
  const EnrollmentState({
    this.enrolledCourseIds = const {},
    this.wishlistIds = const {},
    this.completedLessonIds = const {},
    this.quizBest = const {},
  });

  factory EnrollmentState.fromJson(Map<String, dynamic> json) {
    final completed = <String, Set<String>>{};
    final raw = json['completed'] as Map? ?? {};
    for (final entry in raw.entries) {
      completed[entry.key.toString()] = (entry.value as List)
          .map((e) => e.toString())
          .toSet();
    }
    final quizBest = <String, int>{};
    final rawQuiz = json['quizBest'] as Map? ?? {};
    for (final entry in rawQuiz.entries) {
      quizBest[entry.key.toString()] = (entry.value as num).toInt();
    }
    return EnrollmentState(
      enrolledCourseIds:
          (json['enrolled'] as List? ?? []).map((e) => e.toString()).toSet(),
      wishlistIds:
          (json['wishlist'] as List? ?? []).map((e) => e.toString()).toSet(),
      completedLessonIds: completed,
      quizBest: quizBest,
    );
  }

  final Set<String> enrolledCourseIds;
  final Set<String> wishlistIds;
  final Map<String, Set<String>> completedLessonIds;
  final Map<String, int> quizBest;

  Map<String, dynamic> toJson() => {
        'enrolled': enrolledCourseIds.toList(),
        'wishlist': wishlistIds.toList(),
        'completed': completedLessonIds
            .map((k, v) => MapEntry(k, v.toList())),
        'quizBest': quizBest,
      };
}

class EnrollmentNotifier extends Notifier<EnrollmentState> {
  @override
  EnrollmentState build() {
    final stored = HiveBoxes.enrollments.mapAt('state');
    if (stored != null) return EnrollmentState.fromJson(stored);
    // Demo defaults: enrolled in Python + React; 3 React lessons done.
    return const EnrollmentState(
      enrolledCourseIds: {'python-one-night', 'react-js-zero'},
      completedLessonIds: {
        'react-js-zero': {
          'react-js-zero-m1-l1',
          'react-js-zero-m1-l2',
          'react-js-zero-m1-l3',
        },
      },
    );
  }

  void _save() => HiveBoxes.enrollments.put('state', state.toJson());

  bool isEnrolled(String courseId) => state.enrolledCourseIds.contains(courseId);

  bool isWishlisted(String courseId) => state.wishlistIds.contains(courseId);

  bool isLessonCompleted(String courseId, String lessonId) =>
      state.completedLessonIds[courseId]?.contains(lessonId) ?? false;

  /// 0.0–1.0 from completed/total lessons of the course.
  double progressFor(String courseId) {
    final course = DemoData.courseById(courseId);
    if (course == null || course.allLessons.isEmpty) return 0;
    final done = state.completedLessonIds[courseId]?.length ?? 0;
    return (done / course.allLessons.length).clamp(0.0, 1.0);
  }

  void enroll(String courseId) {
    state = EnrollmentState(
      enrolledCourseIds: {...state.enrolledCourseIds, courseId},
      wishlistIds: state.wishlistIds,
      completedLessonIds: state.completedLessonIds,
      quizBest: state.quizBest,
    );
    _save();
  }

  void unenroll(String courseId) {
    final enrolled = {...state.enrolledCourseIds}..remove(courseId);
    state = EnrollmentState(
      enrolledCourseIds: enrolled,
      wishlistIds: state.wishlistIds,
      completedLessonIds: state.completedLessonIds,
      quizBest: state.quizBest,
    );
    _save();
  }

  void toggleWishlist(String courseId) {
    final wishlist = {...state.wishlistIds};
    if (!wishlist.remove(courseId)) wishlist.add(courseId);
    state = EnrollmentState(
      enrolledCourseIds: state.enrolledCourseIds,
      wishlistIds: wishlist,
      completedLessonIds: state.completedLessonIds,
      quizBest: state.quizBest,
    );
    _save();
  }

  void completeLesson(String courseId, String lessonId) {
    final completed = Map<String, Set<String>>.from(state.completedLessonIds);
    completed[courseId] = {...completed[courseId] ?? {}, lessonId};
    state = EnrollmentState(
      enrolledCourseIds: state.enrolledCourseIds,
      wishlistIds: state.wishlistIds,
      completedLessonIds: completed,
      quizBest: state.quizBest,
    );
    _save();
  }

  void recordQuizBest(String lessonId, int correct) {
    final best = Map<String, int>.from(state.quizBest);
    if (correct > (best[lessonId] ?? -1)) {
      best[lessonId] = correct;
      state = EnrollmentState(
        enrolledCourseIds: state.enrolledCourseIds,
        wishlistIds: state.wishlistIds,
        completedLessonIds: state.completedLessonIds,
        quizBest: best,
      );
      _save();
    }
  }
}

final enrollmentProvider =
    NotifierProvider<EnrollmentNotifier, EnrollmentState>(
  EnrollmentNotifier.new,
);

// ===========================================================================
// Wallet (XP / Volts / streak / badges / Pro)
// ===========================================================================

class WalletState {
  const WalletState({
    this.xp = 1240,
    this.volts = 320,
    this.streakDays = 12,
    this.level = 7,
    this.unlockedBadgeIds = const {},
    this.isPro = false,
  });

  factory WalletState.fromJson(Map<String, dynamic> json) => WalletState(
        xp: (json['xp'] as num?)?.toInt() ?? 1240,
        volts: (json['volts'] as num?)?.toInt() ?? 320,
        streakDays: (json['streakDays'] as num?)?.toInt() ?? 12,
        level: (json['level'] as num?)?.toInt() ?? 7,
        unlockedBadgeIds: (json['badges'] as List? ?? [])
            .map((e) => e.toString())
            .toSet(),
        isPro: json['isPro'] as bool? ?? false,
      );

  final int xp;
  final int volts;
  final int streakDays;
  final int level;
  final Set<String> unlockedBadgeIds;
  final bool isPro;

  WalletState copyWith({
    int? xp,
    int? volts,
    int? streakDays,
    int? level,
    Set<String>? unlockedBadgeIds,
    bool? isPro,
  }) =>
      WalletState(
        xp: xp ?? this.xp,
        volts: volts ?? this.volts,
        streakDays: streakDays ?? this.streakDays,
        level: level ?? this.level,
        unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
        isPro: isPro ?? this.isPro,
      );

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'volts': volts,
        'streakDays': streakDays,
        'level': level,
        'badges': unlockedBadgeIds.toList(),
        'isPro': isPro,
      };
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() {
    final stored = HiveBoxes.wallet.mapAt('state');
    if (stored != null) return WalletState.fromJson(stored);
    // Demo defaults: first 5 badges unlocked.
    return const WalletState(
      unlockedBadgeIds: {
        'medal_gold',
        'medal_silver',
        'medal_bronze',
        'medal_wings',
        'medal_star',
      },
    );
  }

  void _save() => HiveBoxes.wallet.put('state', state.toJson());

  static int levelForXp(int xp) => 1 + xp ~/ 200;

  void addXp(int amount) {
    final xp = state.xp + amount;
    state = state.copyWith(xp: xp, level: levelForXp(xp));
    _save();
  }

  /// Returns false when the balance is too low.
  bool spendVolts(int amount) {
    if (state.volts < amount) return false;
    state = state.copyWith(volts: state.volts - amount);
    _save();
    return true;
  }

  void addVolts(int amount) {
    state = state.copyWith(volts: state.volts + amount);
    _save();
  }

  void unlockBadge(String id) {
    if (state.unlockedBadgeIds.contains(id)) return;
    state = state.copyWith(
      unlockedBadgeIds: {...state.unlockedBadgeIds, id},
    );
    _save();
  }

  void setPro(bool value) {
    state = state.copyWith(isPro: value);
    _save();
  }
}

final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);

// ===========================================================================
// Downloads
// ===========================================================================

class DownloadsState {
  const DownloadsState({
    this.downloadedPaths = const {},
    this.downloadingIds = const {},
  });

  factory DownloadsState.fromJson(Map<String, dynamic> json) {
    final paths = <String, String>{};
    final raw = json['paths'] as Map? ?? {};
    for (final entry in raw.entries) {
      paths[entry.key.toString()] = entry.value.toString();
    }
    return DownloadsState(downloadedPaths: paths);
  }

  final Map<String, String> downloadedPaths; // lessonId -> local file path
  final Set<String> downloadingIds;

  Map<String, dynamic> toJson() => {'paths': downloadedPaths};
}

class DownloadsNotifier extends Notifier<DownloadsState> {
  @override
  DownloadsState build() {
    final stored = HiveBoxes.downloads.mapAt('state');
    return stored == null
        ? const DownloadsState()
        : DownloadsState.fromJson(stored);
  }

  void _save() => HiveBoxes.downloads.put('state', state.toJson());

  bool isDownloaded(String lessonId) =>
      state.downloadedPaths.containsKey(lessonId);

  bool isDownloading(String lessonId) =>
      state.downloadingIds.contains(lessonId);

  /// Downloads the lesson video to the app documents directory.
  /// On web the bytes are discarded and a `web:` marker path is recorded.
  Future<void> downloadLesson(Lesson lesson) async {
    if (lesson.videoUrl.isEmpty) return;
    if (isDownloaded(lesson.id) || isDownloading(lesson.id)) return;
    state = DownloadsState(
      downloadedPaths: state.downloadedPaths,
      downloadingIds: {...state.downloadingIds, lesson.id},
    );
    try {
      final response = await http.get(Uri.parse(lesson.videoUrl));
      if (response.statusCode != 200) {
        throw Exception('Download failed (${response.statusCode})');
      }
      final path = await saveDownload(lesson.id, response.bodyBytes);
      final paths = Map<String, String>.from(state.downloadedPaths)
        ..[lesson.id] = path;
      final downloading = {...state.downloadingIds}..remove(lesson.id);
      state = DownloadsState(
        downloadedPaths: paths,
        downloadingIds: downloading,
      );
      _save();
    } catch (_) {
      final downloading = {...state.downloadingIds}..remove(lesson.id);
      state = DownloadsState(
        downloadedPaths: state.downloadedPaths,
        downloadingIds: downloading,
      );
      rethrow;
    }
  }

  Future<void> removeDownload(String lessonId) async {
    final path = state.downloadedPaths[lessonId];
    if (path != null) await deleteDownload(path);
    final paths = Map<String, String>.from(state.downloadedPaths)
      ..remove(lessonId);
    state = DownloadsState(
      downloadedPaths: paths,
      downloadingIds: state.downloadingIds,
    );
    _save();
  }
}

final downloadsProvider =
    NotifierProvider<DownloadsNotifier, DownloadsState>(DownloadsNotifier.new);

// ===========================================================================
// Forum
// ===========================================================================

class ForumNotifier extends Notifier<List<ForumQuestion>> {
  Set<String> _upvotedIds = {};

  @override
  List<ForumQuestion> build() {
    final stored = HiveBoxes.forum.mapsAt('questions');
    _upvotedIds = HiveBoxes.forum.stringsAt('upvoted').toSet();
    if (stored.isEmpty) return DemoData.questions;
    return stored.map(ForumQuestion.fromJson).toList();
  }

  void _save() {
    HiveBoxes.forum.put(
      'questions',
      state.map((q) => q.toJson()).toList(),
    );
    HiveBoxes.forum.put('upvoted', _upvotedIds.toList());
  }

  bool hasUpvoted(String questionId) => _upvotedIds.contains(questionId);

  void addQuestion(String title, String body, List<String> tags) {
    final author = ref.read(authProvider).user;
    final question = ForumQuestion(
      id: 'q-${DateTime.now().millisecondsSinceEpoch}',
      authorName: author?.name ?? DemoData.me.name,
      authorPhoto: author?.avatarPhoto ?? DemoData.me.avatarPhoto,
      title: title,
      body: body,
      tags: tags,
      createdLabel: 'Just now',
    );
    state = [question, ...state];
    _save();
  }

  void toggleUpvote(String questionId) {
    final upvoted = _upvotedIds.contains(questionId);
    if (upvoted) {
      _upvotedIds.remove(questionId);
    } else {
      _upvotedIds.add(questionId);
    }
    state = [
      for (final q in state)
        if (q.id == questionId)
          q.copyWith(upvotes: q.upvotes + (upvoted ? -1 : 1))
        else
          q,
    ];
    _save();
  }

  void addAnswer(String questionId, String text) {
    final author = ref.read(authProvider).user;
    final answer = ForumAnswer(
      id: 'a-${DateTime.now().millisecondsSinceEpoch}',
      authorName: author?.name ?? DemoData.me.name,
      authorPhoto: author?.avatarPhoto ?? DemoData.me.avatarPhoto,
      body: text,
    );
    state = [
      for (final q in state)
        if (q.id == questionId)
          q.copyWith(
            answers: [...q.answers, answer],
            answersCount: q.answersCount + 1,
          )
        else
          q,
    ];
    _save();
  }

  /// Marks one answer accepted (and the question solved). Only one answer
  /// per question can be accepted; accepting another moves the mark.
  void acceptAnswer(String questionId, String answerId) {
    state = [
      for (final q in state)
        if (q.id == questionId)
          q.copyWith(
            accepted: true,
            answers: [
              for (final a in q.answers)
                ForumAnswer(
                  id: a.id,
                  authorName: a.authorName,
                  authorPhoto: a.authorPhoto,
                  body: a.body,
                  upvotes: a.upvotes,
                  accepted: a.id == answerId,
                ),
            ],
          )
        else
          q,
    ];
    _save();
  }
}

final forumProvider =
    NotifierProvider<ForumNotifier, List<ForumQuestion>>(ForumNotifier.new);

// ===========================================================================
// Notifications
// ===========================================================================

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    final stored = HiveBoxes.notifications.mapsAt('items');
    if (stored.isEmpty) return DemoData.notifications;
    return stored.map(AppNotification.fromJson).toList();
  }

  void _save() {
    HiveBoxes.notifications.put(
      'items',
      state.map((n) => n.toJson()).toList(),
    );
  }

  int get unreadCount => state.where((n) => !n.read).length;

  void markAllRead() {
    state = [for (final n in state) n.copyWith(read: true)];
    _save();
  }

  void markRead(String id) {
    state = [
      for (final n in state) if (n.id == id) n.copyWith(read: true) else n,
    ];
    _save();
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

/// Reactive unread count — watch this in badges (the notifier getter above
/// does not rebuild listeners).
final unreadCountProvider = Provider<int>(
  (ref) =>
      ref.watch(notificationsProvider).where((n) => !n.read).length,
);

// ===========================================================================
// Orders
// ===========================================================================

class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    final stored = HiveBoxes.orders.mapsAt('items');
    if (stored.isEmpty) return DemoData.orders;
    return stored.map(Order.fromJson).toList();
  }

  void _save() {
    HiveBoxes.orders.put(
      'items',
      state.map((o) => o.toJson()).toList(),
    );
  }

  void addOrder(Order order) {
    state = [order, ...state];
    _save();
  }
}

final ordersProvider =
    NotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

// ===========================================================================
// Mini player
// ===========================================================================

class PlayerState {
  const PlayerState({
    this.lessonId,
    this.courseId,
    this.title,
    this.videoUrl,
    this.positionSec = 0,
    this.isPlaying = false,
  });

  final String? lessonId;
  final String? courseId;
  final String? title;
  final String? videoUrl;
  final double positionSec;
  final bool isPlaying;

  bool get hasCurrent => lessonId != null;

  PlayerState copyWith({
    String? lessonId,
    String? courseId,
    String? title,
    String? videoUrl,
    double? positionSec,
    bool? isPlaying,
  }) =>
      PlayerState(
        lessonId: lessonId ?? this.lessonId,
        courseId: courseId ?? this.courseId,
        title: title ?? this.title,
        videoUrl: videoUrl ?? this.videoUrl,
        positionSec: positionSec ?? this.positionSec,
        isPlaying: isPlaying ?? this.isPlaying,
      );
}

class PlayerNotifier extends Notifier<PlayerState> {
  @override
  PlayerState build() => const PlayerState();

  void setCurrent({
    required String lessonId,
    required String courseId,
    required String title,
    required String videoUrl,
    double positionSec = 0,
    bool isPlaying = true,
  }) {
    state = PlayerState(
      lessonId: lessonId,
      courseId: courseId,
      title: title,
      videoUrl: videoUrl,
      positionSec: positionSec,
      isPlaying: isPlaying,
    );
  }

  void updatePosition(double positionSec) {
    if (!state.hasCurrent) return;
    state = state.copyWith(positionSec: positionSec);
  }

  void setPlaying(bool playing) {
    if (!state.hasCurrent) return;
    state = state.copyWith(isPlaying: playing);
  }

  void togglePlaying() {
    if (!state.hasCurrent) return;
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void clear() {
    state = const PlayerState();
  }
}

final playerProvider =
    NotifierProvider<PlayerNotifier, PlayerState>(PlayerNotifier.new);
