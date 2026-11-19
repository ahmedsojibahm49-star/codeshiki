import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// New password [A16]. Set a new password -> toast -> /login.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _update() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    setState(() {
      _passwordError = password.length >= 8
          ? null
          : 'Password must be at least 8 characters';
      _confirmError = confirm == password ? null : 'Passwords do not match';
    });
    if (_passwordError != null || _confirmError != null) return;
    showCsToast(context, 'Password updated');
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'New password'),
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
                  child: Icon(AppIcons.lock, size: 40, color: cs.accent),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Create a new password',
                textAlign: TextAlign.center,
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a strong password you have not used before.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 32),
              CsTextField(
                label: 'New password',
                hint: 'At least 8 characters',
                controller: _passwordController,
                obscure: _obscurePassword,
                prefixIcon: AppIcons.lock,
                errorText: _passwordError,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? AppIcons.eyeSlash : AppIcons.eye,
                    size: 20,
                    color: cs.textTertiary,
                  ),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                ),
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              CsTextField(
                label: 'Confirm new password',
                hint: 'Repeat your new password',
                controller: _confirmController,
                obscure: _obscureConfirm,
                prefixIcon: AppIcons.lock,
                errorText: _confirmError,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm ? AppIcons.eyeSlash : AppIcons.eye,
                    size: 20,
                    color: cs.textTertiary,
                  ),
                  tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
                ),
                onChanged: (_) {
                  if (_confirmError != null) {
                    setState(() => _confirmError = null);
                  }
                },
              ),
              const SizedBox(height: 24),
              CsButton(label: 'Update password', onPressed: _update),
            ],
          ),
        ),
      ),
    );
  }
}
