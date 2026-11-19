# CodeShikhi — Flutter Demo App

A **demo-only** Flutter build of CodeShikhi, a learn-to-code app for
Bangladesh: courses, a video player, a full-screen code editor, community
Q&A, wallet & Volts, badges, and a Pro plan — all running on local demo
data, with no backend.

This app exists to prove the design and the flows work end to end. It is
**not** the production app: there are no real lessons, no real payments,
and no server. See [Honest limits](#honest-limits).

## Tech stack

- **Flutter 3.50** / Dart 3.14
- **Riverpod** — state management (`lib/providers/`)
- **go_router** — navigation, deep links, auth redirects
- **Hive** — local-only persistence (settings, auth session, enrollments,
  wallet, downloads, forum, notifications, orders, notes, code)
- **video_player** — lesson playback (Google sample videos in this demo)
- **iconsax_flutter** — Iconsax icons, matching the Figma design system
- **flutter_localizations** — English + Bangla (`lib/i18n/`)

## Setup

```bash
flutter pub get
flutter run
```

Requirements: Flutter 3.50+ with an Android emulator/device, or run on the
web with `flutter run -d chrome`. No API keys, no backend, no `.env` file
— the demo works fully offline after `pub get` (sample videos need
internet to stream).

## Demo login

One-tap **Demo login** on the Login screen signs in instantly. Or type:

| Field    | Value                  |
|----------|------------------------|
| Email    | `demo@codeshikhi.app`  |
| Password | `demo1234`             |
| OTP      | `123456`               |

The demo account starts with 1,240 XP, 320 Volts, a 12-day streak, level 7,
5 unlocked badges, and enrollments in Python One Night and React JS Zero
(with 3 React lessons already complete).

## Build the APK (GitHub Actions)

No Android SDK is needed locally — the APK is built in CI:

1. Push to `main` (or open the **Actions** tab and run the workflow
   manually).
2. Wait for the **Build APK** workflow (`.github/workflows/build-apk.yml`):
   `pub get` → `analyze` → `test` → `build apk --release`.
3. Download the **`codeshikhi-apk`** artifact from the run.

For a tagged release, push a version tag and the workflow publishes a
GitHub Release with the APK attached:

```bash
git tag v1.0.0
git push origin v1.0.0
# → Release with codeshikhi-v1.0.0.apk
```

## Project structure

```
lib/
├── main.dart            # Entry point: Hive init, ProviderScope, CodeShikhiApp
├── app.dart             # MaterialApp.router, theme + locale wiring
├── navigation/          # app_router.dart (routes + redirect), app_shell.dart
├── theme/               # AppTheme (light/dark), colors, text styles
├── data/                # DemoData (all demo content), HiveBoxes, models
├── providers/           # Riverpod providers: auth, wallet, enrollment,
│                        #   settings, downloads, forum, notifications…
├── i18n/                # English + Bangla strings (tr extension)
├── widgets/             # Shared UI: CsButton, CsBadgeImage, cards, sheets…
└── features/            # One folder per feature, each with screens/
    ├── auth/            #   splash, welcome, login, signup, OTP, forgot
    ├── home/            #   home feed, search
    ├── course/          #   course detail, curriculum, checkout
    ├── my_courses/      #   enrolled courses, progress
    ├── player/          #   video player, lesson notes
    ├── code/            #   full-screen code editor (fullscreen, no nav)
    ├── community/       #   forum Q&A
    ├── payments/        #   Pro checkout, coupons, redeem, wallet
    ├── profile/         #   profile, badges, leaderboard, settings
    ├── settings/        #   theme, language, notifications, about
    └── notifications/   #   notification list

test/                    # 32 tests (16 foundation + 16 widget/unit)
assets/badges/           # 12 badge PNGs (Flaticon, free icons)
```

## Key demo behaviours

- **Sample videos** — every lesson plays a public Google sample video.
  The player UI (controls, speed, notes, progress) is real; the content
  is placeholder.
- **Simulated code run** — the editor's Run button shows a simulated
  result. No code is actually executed; the Piston API is the planned
  later step for real execution.
- **Local-only data** — everything lives in Hive on the device. Enroll,
  earn Volts, redeem rewards, post in the forum: it all persists locally
  and nothing syncs anywhere.
- **Manual TrxID flow** — Pro checkout with bKash/Nagad is manual: the
  demo shows the payment instructions and a Transaction ID field, and
  accepts any TrxID as "submitted". No payment gateway is connected.
- **Coupons** — `WELCOME10` takes ৳150 off (Pro ৳499 → ৳349);
  `STUDENT20` takes 20% off.
- **Platform nav** — Android gets a docked bottom nav bar plus immersive
  mode; iOS gets the floating glass pill tab island from the Figma design.
- **Code editor is full screen** — opening the editor hides the bottom
  nav entirely, on both platforms.

## Tests

```bash
flutter analyze   # 0 issues
flutter test      # 32 tests pass (16 foundation + 16 widget/unit)
```

Widget tests cover the demo-login flow, login validation, tab switching on
both nav styles, the fullscreen editor, the 12-image badges grid, the
player screen, coupon math, free-course enrollment, Volts redemption, and
theme/language toggles. Tests are hermetic (fresh Hive state per test) and
never hit the network.

> Note: on machines where `/tmp` is a small tmpfs, set
> `TMPDIR` to a larger directory before running tests, e.g.
> `TMPDIR=~/tmp-flutter flutter test` — the test compiler writes a
> ~104 MB kernel file per run.

## Honest limits

- **Demo data only.** Courses, lessons, forum posts, leaderboard, and
  notifications are hard-coded in `lib/data/demo_data.dart`.
- **Google sample videos, not real lessons.** No lesson content exists
  yet.
- **Code execution is simulated.** The editor does not run code. Real
  execution via the Piston API is a later step.
- **No backend / Supabase yet.** No accounts, no sync, no real auth —
  the demo login is a local session flag.
- **No payments.** TrxID is manual and unverified; no gateway.
- **No device test done in the VM.** The app is verified with
  `flutter analyze`, `flutter test`, and a web build only. It has not
  been run on a physical Android or iOS device from this environment.
- **iOS untested.** The iOS floating-pill nav is verified only in widget
  tests (via `debugDefaultTargetPlatformOverride`); it has never run on
  an iPhone or simulator.

## Credits

- Badge icons by **Flaticon** — [flaticon.com](https://www.flaticon.com)
  (free icons; attribution also shown on the in-app About page).
- Photos and course artwork are demo placeholders, not licensed content.
- Design: CodeShikhi Figma design system (Warm Ember theme, Iconsax).
