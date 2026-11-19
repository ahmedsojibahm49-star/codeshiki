import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// Change password [K03]. Delegates to [AuthNotifier.changePassword], which
/// persists the new password for both local accounts and the demo account
/// (demo override stored in Hive, default `demo1234`).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _visibilityToggle(bool visible, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        visible ? AppIcons.eyeSlash : AppIcons.eye,
        size: 20,
        color: context.cs.textTertiary,
      ),
    );
  }

  Future<void> _updatePassword() async {
    final current = _currentController.text;
    final newPassword = _newController.text;
    final confirm = _confirmController.text;

    var hasError = false;
    setState(() {
      _newError = newPassword.length < 8
          ? 'New password must be at least 8 characters'
          : null;
      _confirmError =
          confirm != newPassword ? 'Passwords do not match' : null;
      hasError = _newError != null || _confirmError != null;
    });
    if (hasError) return;

    final ok = await ref
        .read(authProvider.notifier)
        .changePassword(current, newPassword);
    if (!mounted) return;
    if (!ok) {
      showCsToast(context, 'Current password is incorrect', isError: true);
      return;
    }

    showCsToast(context, 'Password updated');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'Change password'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Choose a strong password with at least 8 characters.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 24),
          CsTextField(
            label: 'Current password',
            controller: _currentController,
            obscure: !_showCurrent,
            prefixIcon: AppIcons.lock,
            suffix: _visibilityToggle(
              _showCurrent,
              () => setState(() => _showCurrent = !_showCurrent),
            ),
          ),
          const SizedBox(height: 16),
          CsTextField(
            label: 'New password',
            controller: _newController,
            obscure: !_showNew,
            prefixIcon: AppIcons.key,
            errorText: _newError,
            suffix: _visibilityToggle(
              _showNew,
              () => setState(() => _showNew = !_showNew),
            ),
          ),
          const SizedBox(height: 16),
          CsTextField(
            label: context.tr('confirmPassword'),
            controller: _confirmController,
            obscure: !_showConfirm,
            prefixIcon: AppIcons.key,
            errorText: _confirmError,
            suffix: _visibilityToggle(
              _showConfirm,
              () => setState(() => _showConfirm = !_showConfirm),
            ),
          ),
          const SizedBox(height: 24),
          CsButton(
            label: 'Update password',
            onPressed: _updatePassword,
          ),
        ],
      ),
    );
  }
}
