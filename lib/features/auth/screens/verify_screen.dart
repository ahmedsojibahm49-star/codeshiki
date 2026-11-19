import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// OTP verification [A09]. 6 digit boxes with auto-advance.
/// Demo only: the code is 123456.
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  static const _demoCode = '123456';

  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _complete => _code.length == 6;

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_error != null) setState(() => _error = null);
    if (_complete) _verify();
  }

  void _verify() {
    if (!_complete) return;
    if (_code == _demoCode) {
      context.go('/onboarding/goal');
    } else {
      setState(() => _error = 'Wrong code. Please try again.');
    }
  }

  void _resend() {
    showCsToast(context, 'Code resent (demo: 123456)');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Verify your email'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(AppIcons.shield, size: 40, color: cs.accent),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Enter the 6-digit code',
                textAlign: TextAlign.center,
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a verification code to your email.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: AppText.h2.copyWith(color: cs.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cs.surface,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) => _onChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'Demo code: 123456',
                textAlign: TextAlign.center,
                style: AppText.caption.copyWith(color: cs.textTertiary),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppText.bodySmall.copyWith(color: cs.danger),
                ),
              ],
              const SizedBox(height: 24),
              CsButton(label: 'Verify', onPressed: _complete ? _verify : null),
              const SizedBox(height: 8),
              CsButton(
                label: 'Resend code',
                variant: CsButtonVariant.ghost,
                onPressed: _resend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
