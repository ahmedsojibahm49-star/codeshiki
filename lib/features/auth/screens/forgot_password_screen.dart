import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_top_bar.dart';

/// Forgot password [A14]. Email -> send reset link -> /forgot-sent.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _send() {
    final email = _emailController.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }
    context.push('/forgot-sent');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Forgot password'),
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
                  child: Icon(AppIcons.key, size: 40, color: cs.accent),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Reset your password',
                textAlign: TextAlign.center,
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we will send you a link to reset your password.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 32),
              CsTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _emailController,
                prefixIcon: AppIcons.message,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
              ),
              const SizedBox(height: 24),
              CsButton(label: 'Send reset link', onPressed: _send),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Remember your password? ',
                    style: AppText.bodySmall.copyWith(color: cs.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Back to log in',
                      style: AppText.label.copyWith(color: cs.accent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
