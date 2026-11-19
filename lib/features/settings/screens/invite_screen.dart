import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../i18n/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// Invite friends [K24]: referral code + copy/share + how it works.
class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  static const String referralCode = 'CS-RAHIM-2026';

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: referralCode));
    if (context.mounted) {
      showCsToast(context, 'Referral code copied');
    }
  }

  Future<void> _share() async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Learn coding in Bangla with me on CodeShikhi! '
            'Use my code $referralCode',
      ),
    );
  }

  Widget _step(BuildContext context, String number, String text) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppText.label.copyWith(color: cs.onPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: AppText.body.copyWith(color: cs.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: context.tr('invite')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: CsScheme.proGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(AppIcons.giftBold, size: 40, color: cs.onPrimary),
                const SizedBox(height: 12),
                Text(
                  'Invite friends, earn Volts',
                  style: AppText.h2.copyWith(color: cs.onPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'You get 100 Volts for every friend who signs up with your code.',
                  style: AppText.bodySmall.copyWith(color: cs.onPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.borderHairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your referral code',
                        style: AppText.caption.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        referralCode,
                        style: AppText.code.copyWith(
                          color: cs.textPrimary,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                CsButton(
                  label: 'Copy',
                  icon: AppIcons.copy,
                  size: CsButtonSize.s,
                  fullWidth: false,
                  onPressed: () => _copyCode(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CsButton(
            label: 'Share invite',
            icon: AppIcons.share,
            variant: CsButtonVariant.secondary,
            onPressed: _share,
          ),
          const SizedBox(height: 28),
          Text(
            'How it works',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 16),
          _step(context, '1', 'Share your code with a friend.'),
          _step(
            context,
            '2',
            'They sign up on CodeShikhi and enter your code.',
          ),
          _step(
            context,
            '3',
            'You both get 100 Volts once they complete their first lesson.',
          ),
        ],
      ),
    );
  }
}
