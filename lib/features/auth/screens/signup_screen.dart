import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/cs_logo.dart';

/// Sign up [A08]. Name + email + password + confirm, strength bar,
/// terms checkbox. Creates a local demo account -> /verify.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _termsAccepted = false;
  bool _loading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Strength score 0-4: length >= 8, uppercase, digit, symbol.
  int get _strength {
    final password = _passwordController.text;
    var score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return score;
  }

  String get _strengthLabel {
    switch (_strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      default:
        return 'Strong';
    }
  }

  Color _strengthColor(BuildContext context) {
    final cs = context.cs;
    switch (_strength) {
      case 0:
      case 1:
        return cs.danger;
      case 2:
        return cs.warning;
      case 3:
        return cs.teal;
      default:
        return cs.success;
    }
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    setState(() {
      _nameError = name.isEmpty ? 'Enter your name' : null;
      _emailError = _emailPattern.hasMatch(email)
          ? null
          : 'Enter a valid email address';
      _passwordError = password.length >= 8
          ? null
          : 'Password must be at least 8 characters';
      _confirmError = confirm == password ? null : 'Passwords do not match';
      _generalError = null;
    });
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null;
  }

  Future<void> _signup() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    final ok = await ref
        .read(authProvider.notifier)
        .signup(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.push('/verify');
    } else {
      setState(
        () => _generalError = 'An account with this email already exists',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final strength = _strength;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Create account'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: CsLogo(size: 72)),
              const SizedBox(height: 24),
              Text(
                'Join CodeShikhi',
                textAlign: TextAlign.center,
                style: AppText.h1.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Start learning to code in Bangla today.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
              const SizedBox(height: 32),
              CsTextField(
                label: 'Full name',
                hint: 'Rahim Uddin',
                controller: _nameController,
                prefixIcon: AppIcons.user,
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 16),
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
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: i < strength
                              ? _strengthColor(context)
                              : cs.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _passwordController.text.isEmpty
                    ? 'Use 8+ characters with a mix of letters, numbers and symbols.'
                    : 'Password strength: $_strengthLabel',
                style: AppText.caption.copyWith(
                  color: _passwordController.text.isEmpty
                      ? cs.textTertiary
                      : _strengthColor(context),
                ),
              ),
              const SizedBox(height: 16),
              CsTextField(
                label: 'Confirm password',
                hint: 'Repeat your password',
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
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) =>
                          setState(() => _termsAccepted = value ?? false),
                      fillColor: WidgetStatePropertyAll(
                        _termsAccepted ? cs.primary : Colors.transparent,
                      ),
                      checkColor: cs.onPrimary,
                      side: BorderSide(color: cs.border, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (_generalError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _generalError!,
                  textAlign: TextAlign.center,
                  style: AppText.bodySmall.copyWith(color: cs.danger),
                ),
              ],
              const SizedBox(height: 20),
              CsButton(
                label: 'Create account',
                loading: _loading,
                onPressed: (_loading || !_termsAccepted) ? null : _signup,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppText.bodySmall.copyWith(color: cs.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Log in',
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
