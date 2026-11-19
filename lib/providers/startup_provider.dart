import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/hive_boxes.dart';
import '../data/startup_storage.dart';

/// Startup can never hang forever: every storage step gets 20s before it
/// counts as failed (a hanging platform-channel call then lands on the
/// error screen with Retry, instead of a stuck splash).
const Duration _startupTimeout = Duration(seconds: 20);

/// Android immersive mode: hide ONLY the system navigation bar, KEEP the
/// status bar visible (the user's rule). Uses `SystemUiMode.manual` with
/// just the top overlay — NOT immersiveSticky, which hides the status bar
/// too. Re-applied on resume because the OS restores the bars when the user
/// swipes them back.
void applyImmersiveMode() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }
}

class ImmersiveObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) applyImmersiveMode();
  }
}

/// Result of [bootstrap]. [storageError] is non-null when local storage
/// could not be started even after recovery — the app then shows the
/// startup error screen instead of the normal UI (never a stuck splash).
class BootstrapResult {
  const BootstrapResult({this.storageError});

  final Object? storageError;

  bool get storageReady => storageError == null;
}

/// Current bootstrap result. Seeded by main() via override; the Retry
/// button on the startup error screen re-runs [bootstrap] through
/// [StartupNotifier.retry].
///
/// The default (no override) is "storage ready": widget tests pump the app
/// without main() and init Hive themselves, so the gate must not block
/// them. Production always overrides with the real result.
final startupProvider =
    NotifierProvider<StartupNotifier, BootstrapResult>(StartupNotifier.new);

class StartupNotifier extends Notifier<BootstrapResult> {
  StartupNotifier([BootstrapResult? initial])
      : _initial = initial ?? const BootstrapResult();

  final BootstrapResult _initial;

  @override
  BootstrapResult build() => _initial;

  /// Re-run the bootstrap (storage recovery included) and update state.
  Future<void> retry() async {
    state = await bootstrap();
  }
}

/// App startup. NEVER throws: every step is guarded so a failure degrades
/// (error screen with Retry) instead of dying before runApp — an
/// unguarded `Hive.initFlutter()` here used to leave the Android launch
/// splash up forever (stuck on splash, Nov 19).
///
/// Storage init uses [initHiveWithFallback]: pure-Dart direct Android
/// app-data paths first (no platform channel), then the documents
/// directory, then support, temp and cache. A broken path_provider layer
/// must not kill startup.
Future<BootstrapResult> bootstrap() async {
  // Cosmetic only — never block startup on it.
  try {
    applyImmersiveMode();
  } catch (_) {}

  // Local storage: Hive boxes (all demo data is on-device, no server).
  try {
    await initHiveWithFallback().timeout(_startupTimeout);
  } on TimeoutException catch (e) {
    return BootstrapResult(storageError: e);
  } catch (e) {
    return BootstrapResult(storageError: e);
  }

  // Hive has a working directory now — open the boxes.
  try {
    await HiveBoxes.init().timeout(_startupTimeout);
  } on TimeoutException catch (e) {
    return BootstrapResult(storageError: e);
  } catch (_) {
    // Boxes failed (e.g. corrupt box file) after Hive had a working
    // directory: delete the box files and try once more before giving up.
    try {
      await recoverStorage().timeout(_startupTimeout);
    } on TimeoutException catch (e) {
      return BootstrapResult(storageError: e);
    } catch (e2) {
      return BootstrapResult(storageError: e2);
    }
  }

  return const BootstrapResult();
}
