import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../widgets/cs_logo.dart';

/// Shown INSTEAD of the app when local storage cannot be started
/// (see `bootstrap()` in the startup provider). A visible, branded error
/// screen with a Retry button — never a stuck splash.
///
/// The FULL error is shown (scrollable) with a Copy button, so the user
/// can send us the complete diagnosis instead of a truncated snippet.
///
/// Strings are hardcoded English on purpose: this is a last-resort screen
/// and must not depend on the i18n maps.
class StartupErrorScreen extends StatefulWidget {
  const StartupErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  /// The storage error that blocked startup (shown in full).
  final Object error;

  /// Re-runs the bootstrap (see `StartupNotifier.retry`).
  final VoidCallback onRetry;

  @override
  State<StartupErrorScreen> createState() => _StartupErrorScreenState();
}

class _StartupErrorScreenState extends State<StartupErrorScreen> {
  bool _copied = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _copyError() async {
    // Clipboard is a platform-channel call — guard it (this screen
    // exists precisely for devices whose platform layer is broken).
    try {
      await Clipboard.setData(
        ClipboardData(text: widget.error.toString()),
      );
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() => _copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: CsLogo(size: 88)),
                    const SizedBox(height: 24),
                    Text(
                      'CodeShikhi',
                      textAlign: TextAlign.center,
                      style: AppText.display.copyWith(color: cs.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Couldn't start CodeShikhi",
                      textAlign: TextAlign.center,
                      style: AppText.h2.copyWith(color: cs.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Local storage could not be opened on this device. '
                      'Your courses and progress live in local storage, so '
                      'the app cannot continue without it.',
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(color: cs.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.border),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          widget.error.toString(),
                          style: AppText.bodySmall.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _copyError,
                        child: Text(
                          _copied ? 'Copied!' : 'Copy error',
                          style: AppText.bodySmall.copyWith(color: cs.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: widget.onRetry,
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Try again',
                          style: AppText.button.copyWith(color: cs.onPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'If this keeps happening, clear the app data in '
                      'Android Settings → Apps → CodeShikhi → Storage → '
                      'Clear data, then open the app again.',
                      textAlign: TextAlign.center,
                      style: AppText.bodySmall.copyWith(
                        color: cs.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dependency-free fallback for `ErrorWidget.builder` (main.dart): when a
/// widget build fails anywhere, Flutter shows this instead of a blank
/// screen. Uses no Theme, no icons, no i18n — only explicit styles — so
/// it renders even if the failure was in the theme or fonts themselves.
class StartupErrorFallback extends StatelessWidget {
  const StartupErrorFallback({super.key, required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFFFFF7F0),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A2A), Color(0xFFE85D04)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1C1917),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'CodeShikhi hit an unexpected error. Please close the app '
              'completely and open it again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6E6862),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
