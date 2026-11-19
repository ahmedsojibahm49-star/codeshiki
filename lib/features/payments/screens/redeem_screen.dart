import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// Redeem Volts [I17]: spend Volts on perks, with a confirm dialog.
class RedeemScreen extends ConsumerWidget {
  const RedeemScreen({super.key});

  static const _items = [
    _RedeemItem(
      id: 'ai-hints',
      title: 'AI hint pack',
      description: '5 AI hints for the code editor.',
      cost: 100,
      icon: AppIcons.lamp,
      grantsPro: false,
    ),
    _RedeemItem(
      id: 'pro-7d',
      title: '7 days of Pro',
      description: 'All courses unlocked for a week.',
      cost: 500,
      icon: AppIcons.crown,
      grantsPro: true,
    ),
    _RedeemItem(
      id: 'cert-frame',
      title: 'Certificate frame',
      description: 'A premium frame for your certificates.',
      cost: 200,
      icon: AppIcons.award,
      grantsPro: false,
    ),
  ];

  Future<void> _confirmRedeem(
    BuildContext context,
    WidgetRef ref,
    _RedeemItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final cs = dialogContext.cs;
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Redeem ${item.title}?',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          content: Text(
            'This costs ${item.cost} Volts. ${item.description}',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          actions: [
            CsButton(
              label: 'Cancel',
              variant: CsButtonVariant.secondary,
              size: CsButtonSize.m,
              fullWidth: false,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            CsButton(
              label: 'Redeem',
              size: CsButtonSize.m,
              fullWidth: false,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    final spent = ref.read(walletProvider.notifier).spendVolts(item.cost);
    if (!context.mounted) return;
    if (!spent) {
      showCsToast(context, 'Not enough Volts', isError: true);
      return;
    }
    if (item.grantsPro) {
      ref.read(walletProvider.notifier).setPro(true);
      showCsToast(context, '7 days of Pro activated');
    } else {
      showCsToast(context, 'Redeemed!');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final volts = ref.watch(walletProvider).volts;
    return Scaffold(
      appBar: const CsTopBar(title: 'Redeem Volts'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(AppIcons.flashBold, size: 24, color: cs.accent),
                  const SizedBox(width: 10),
                  Text(
                    'Your balance',
                    style: AppText.bodySmall.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$volts Volts',
                    style: AppText.h3.copyWith(color: cs.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (final item in _items) ...[
              _RedeemTile(
                item: item,
                affordable: volts >= item.cost,
                onTap: () => _confirmRedeem(context, ref, item),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _RedeemItem {
  const _RedeemItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    required this.grantsPro,
  });

  final String id;
  final String title;
  final String description;
  final int cost;
  final IconData icon;
  final bool grantsPro;
}

class _RedeemTile extends StatelessWidget {
  const _RedeemTile({
    required this.item,
    required this.affordable,
    required this.onTap,
  });

  final _RedeemItem item;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, size: 24, color: cs.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppText.label.copyWith(color: cs.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: AppText.caption.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.cost} Volts',
                    style: AppText.label.copyWith(
                      color: affordable ? cs.accent : cs.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    affordable ? 'Tap to redeem' : 'Not enough Volts',
                    style: AppText.caption.copyWith(
                      color:
                          affordable ? cs.textSecondary : cs.textTertiary,
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
