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

/// Delete account, step 2 [K23]: type DELETE to confirm, then
/// [AuthNotifier.deleteAccount] wipes all demo data and goes to `/welcome`.
class DeleteConfirmScreen extends ConsumerStatefulWidget {
  const DeleteConfirmScreen({super.key});

  @override
  ConsumerState<DeleteConfirmScreen> createState() =>
      _DeleteConfirmScreenState();
}

class _DeleteConfirmScreenState extends ConsumerState<DeleteConfirmScreen> {
  final _controller = TextEditingController();
  bool _deleting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    await ref.read(authProvider.notifier).deleteAccount();
    if (!mounted) return;
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final confirmed = _controller.text.trim() == 'DELETE';
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'Confirm deletion'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Icon(AppIcons.trashBold, size: 48, color: cs.danger),
          const SizedBox(height: 16),
          Text(
            'Type DELETE to confirm',
            style: AppText.h2.copyWith(color: cs.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'To be sure this is really what you want, type the word DELETE in the field below.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CsTextField(
            hint: 'DELETE',
            controller: _controller,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          CsButton(
            label: 'Delete my account forever',
            variant: CsButtonVariant.destructive,
            loading: _deleting,
            onPressed: confirmed && !_deleting ? _delete : null,
          ),
          const SizedBox(height: 12),
          CsButton(
            label: 'Cancel',
            variant: CsButtonVariant.secondary,
            onPressed: _deleting ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
