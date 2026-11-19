import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/cs_logo.dart';

/// Log in [A06]. Pre-filled demo credentials. Validation + demo login.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: DemoData.demoEmail);
  final _passwordController = TextEditingController(
    text: DemoData.demoPassword,
  );
  bool _obscurePassword = true;
  bool _loading = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _emailError = _emailPattern.hasMatch(email)
          ? null
          : 'Enter a valid email address';
      _passwordError = password.length >= 6
          ? null
          : 'Password must be at least 6 characters';
      _generalError = null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _login() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    final ok = await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.go('/home');
    } else {
      setState(() => _generalError = 'Wrong email or password');
    }
  }

  Future<void> _demoLogin() async {
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).demoLogin();
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Log in'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: CsLogo(size: 72)),
              const SizedBox(height: 24),
              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Log in to continue learning.',
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
              const SizedBox(height: 16),
              CsTextField(
                label: 'Password',
                hint: 'Your password',
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot'),
                  child: Text(
                    'Forgot password?',
                    style: AppText.label.copyWith(color: cs.accent),
                  ),
                ),
              ),
              if (_generalError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _generalError!,
                  textAlign: TextAlign.center,
                  style: AppText.bodySmall.copyWith(color: cs.danger),
                ),
              ],
              const SizedBox(height: 16),
              CsButton(
                label: 'Log in',
                loading: _loading,
                onPressed: _loading ? null : _login,
              ),
              const SizedBox(height: 12),
              CsButton(
                label: 'Demo login',
                variant: CsButtonVariant.secondary,
                icon: AppIcons.flash,
                loading: _loading,
                onPressed: _loading ? null : _demoLogin,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppText.bodySmall.copyWith(color: cs.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => context.push('/signup'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign up',
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
