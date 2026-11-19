# CodeShikhi — Foundation CONTRACT

Public API surface for feature builders. Do NOT change these names, paths,
or signatures without coordinating — screens are built against them.

## Imports

- Material widgets: `package:material_ui/material_ui.dart` (Flutter 3.50
  deprecated `flutter/material.dart`; do NOT import it).
- Colors: `context.cs.*` ONLY — never hardcode hex in screens.
- Strings: `context.tr('key')` (120 keys, EN + BN, `lib/i18n/app_strings.dart`).

## Theme (`lib/theme/`)

- `AppColors` — static const tokens (Warm Ember). Use via `CsScheme`.
- `CsScheme` / `context.cs`: `isDark`, `canvas`, `surface`, `raised`,
  `sunken`, `textPrimary`, `textSecondary`, `textTertiary`, `accent`,
  `border`, `borderHairline`, `primary`, `onPrimary` (INK — never white on
  orange), `teal`, `success`, `successSoft`, `danger`, `dangerSoft`,
  `warning`, `warningSoft`, `info`, `infoSoft`, `synKeyword`, `synString`,
  `synFunction`, `synNumber`, `synComment`, `synEditorBg`,
  `CsScheme.proGradient` (the ONLY gradient).
- `AppFonts`: `display`='BricolageGrotesque', `ui`='Geist',
  `mono`='JetBrainsMono', `bangla`='AnekBangla'.
- `AppText`: `display`, `h1`, `h2`, `h3`, `body`, `bodySmall`, `caption`,
  `label`, `button`, `code` (no colors baked in — apply `context.cs.*`).
- `AppTheme.light({bool bangla})` / `dark({bool bangla})` /
  `forLocale(locale, brightness)`.
- `AppIcons` — every icon in Linear + Bold (`X` / `XBold`). Tabs:
  `tabHome`, `tabCourses`, `tabCode`, `tabCommunity`, `tabProfile` (+Bold).
  Verified mappings: trophy→`cup`, target→`flag`, plus→`add`,
  users→`people`, globe→`global`, mic→`microphone`,
  shield→`shield_tick`. See `lib/theme/app_icons.dart` for the full list.

## Data (`lib/data/`)

Models (`models.dart`, all with `fromJson`/`toJson`, plain maps in Hive):
`Course`, `Module`, `Lesson`, `UserProfile`, `ForumQuestion`, `ForumAnswer`,
`AppNotification`, `Order`, `BadgeInfo`, `LeaderboardEntry`, `Review`,
`Coupon` (+`applyTo(price)`), `CodeProject`, `ProjectFile`,
`CodeTestResult`. Extensions beyond the brief: `Course.instructorPhoto`,
`ForumQuestion.answers`, `CodeProject.runOutput` + `tests`.

`DemoData`: `me` (Rahim Uddin), `demoXp` 1240, `demoVolts` 320,
`demoStreakDays` 12, `demoLevel` 7, `demoEmail`/`demoPassword`,
`sampleVideos` (9 Google sample MP4s), `categories` (6),
`courses` (4: `react-js-zero`, `python-one-night`, `mern-project-camp`,
`dsa-java`), `courseById`, `lessonById`, `codeProjects` (3),
`questions` (6), `leaderboard` (8, Rahim rank 3), `notifications` (8),
`badges` (12, first 5 unlocked), `orders` (2), `coupons`
(`WELCOME10` −৳150, `STUDENT20` −20%), `couponByCode`, `reviews` (3).

`HiveBoxes`: boxes `settings`, `auth`, `enrollments`, `wallet`,
`downloads`, `forum`, `notifications`, `orders`; static getters
(`HiveBoxes.settings`, …) + `init()` + `clearAll()`.

`DemoRepository` (abstract) + `LocalDemoRepository` +
`demoRepositoryProvider`: `getCourses`, `getCourse`, `getLessons`,
`getQuestions`, `getBadges`, `getLeaderboard`, `getNotifications`,
`getOrders`, `getCodeProjects`, `searchCourses`.

## Providers (`lib/providers/app_providers.dart`, all NotifierProvider)

- `settingsProvider` — `SettingsState{themeMode, locale, dataSaver,
  pushEnabled, studyReminders}`; `setThemeMode`, `setLocale`,
  `toggleDataSaver`, `togglePush`, `toggleReminders`.
- `authProvider` — `AuthState{user, isLoggedIn}`;
  `login(email, password)->Future<bool>`,
  `signup(name, email, password)->Future<bool>`, `demoLogin()`,
  `logout()`, `deleteAccount()`.
- `enrollmentProvider` — `EnrollmentState{enrolledCourseIds, wishlistIds,
  completedLessonIds, quizBest}`; `enroll`, `unenroll`,
  `toggleWishlist`, `completeLesson`, `isEnrolled`, `isWishlisted`,
  `isLessonCompleted`, `progressFor`, `recordQuizBest`.
- `walletProvider` — `WalletState{xp, volts, streakDays, level,
  unlockedBadgeIds, isPro}`; `addXp`, `spendVolts()->bool`, `addVolts`,
  `unlockBadge`, `setPro`. Level = 1 + xp~/200.
- `downloadsProvider` — `DownloadsState{downloadedPaths,
  downloadingIds}`; `downloadLesson(Lesson)->Future<void>`,
  `removeDownload`, `isDownloaded`, `isDownloading`.
- `forumProvider` — `List<ForumQuestion>`; `addQuestion(title, body, tags)`,
  `toggleUpvote`, `addAnswer`, `hasUpvoted`.
- `notificationsProvider` — `List<AppNotification>`; `markAllRead`,
  `markRead`, `unreadCount` (getter). Reactive count:
  `unreadCountProvider`.
- `ordersProvider` — `List<Order>`; `addOrder`.
- `playerProvider` — `PlayerState{lessonId, courseId, title, videoUrl,
  positionSec, isPlaying, hasCurrent}`; `setCurrent(...)`,
  `updatePosition`, `setPlaying`, `togglePlaying`, `clear()`.

## Routes (`lib/navigation/app_router.dart`, `appRouter`)

Tabs (shell): `/home`, `/my-courses`, `/code`, `/community`, `/profile`.
Nested (tab bar visible): `/home/search`, `/home/category/:id`,
`/home/path`, `/home/streak`, `/home/notifications`.
Top-level (no tab bar): `/course/:id`, `/player/:lessonId`,
`/editor/:projectId`, `/settings`, `/payments/plans`.
All are placeholders until feature route files land — see the
`TODO(coordinator)` section in `app_router.dart`. Feature routes live in
`<feature>/<feature>_routes.dart` exporting `List<RouteBase> <feature>Routes`.

Platform nav rule (`app_shell.dart`): Android/Web = docked Material 3
`NavigationBar`; iOS = floating glass pill (64h, r32, 20 side, 12 bottom
+ safe area, blur 24, surface 0.85). Mini player bar shows above the nav
when `playerProvider.hasCurrent`; tap → `/player/:lessonId`.

## Widgets (`lib/widgets/`)

- `CsButton({label, onPressed, variant, size, fullWidth=true, loading,
  icon})` — variants `primary/secondary/ghost/destructive/pro`,
  sizes `l(56)/m(48)/s(36)`, radius 14.
- `CsTextField({label, hint, controller, obscure, prefixIcon, suffix,
  errorText, keyboardType, onChanged, maxLines, enabled})`.
- `CsFilterChip({label, selected, onTap})`.
- `CsTopBar({title, onBack, actions, showBack})` (PreferredSizeWidget).
- `CsAvatar({photoAsset, name, size=48})`.
- `CsSectionHeader({title, actionLabel, onAction})`.
- `CsCourseListCard({course, onTap, trailing})`.
- `showCsSheet(context, child)` — radius 28 top, grabber.
- `CsEmptyState({icon, title, body, actionLabel, onAction})`.
- `showCsToast(context, message, {isError})`.
- `CsStatItem({value, label})`.
- `PlaceholderScreen({title})` — temporary.
- `CsBadgeImage({badge, size=72, locked})` — Flaticon PNG, grayscale+lock
  when locked.

## App entry

`main.dart`: Hive init → `HiveBoxes.init()` → immersive mode (Android
only: `SystemUiMode.manual`, overlays `[top]` — hides system nav bar,
KEEPS status bar; re-applied on resume) → `ProviderScope` →
`CodeShikhiApp` (`app.dart`, `MaterialApp.router`, theme+locale from
`settingsProvider`, en+bn).

## Notes

- Demo login: `demo@codeshikhi.app` / `demo1234`.
- No Firebase/Supabase, no build_runner/hive_generator, no chewie.
- Android Lint disabled for release builds (lint crashes on
  video_player_android — a lint bug, not our code).
- `material_ui: ^1.11.0` is a REQUIRED dependency (Flutter 3.50 moved
  Material widgets there). Do not remove it.
