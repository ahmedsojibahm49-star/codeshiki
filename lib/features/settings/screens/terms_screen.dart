import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_top_bar.dart';

/// Terms and privacy [K20]: short, genuine terms in 5 sections.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const List<(String, String)> _sections = [
    (
      '1. Acceptance',
      'By creating a CodeShikhi account and using the app, you agree to these terms. If you do not agree, please do not use the app. We may update these terms from time to time; the latest version is always available here in Settings.',
    ),
    (
      '2. Accounts',
      'You are responsible for keeping your account and password safe. Do not share your login with others. One account belongs to one person. We may suspend accounts that break these terms or misuse the app, for example by cheating on quizzes or harassing other learners.',
    ),
    (
      '3. Payments & refunds',
      'Paid courses and Pro are charged in Bangladeshi taka (BDT) through bKash, Nagad, Rocket or card. Prices are shown before you pay and include any applicable taxes. If you have watched less than 20% of a paid course and it has been less than 7 days since purchase, you can request a refund from Profile > Orders or by contacting support.',
    ),
    (
      '4. Content',
      'All lessons, videos, quizzes and code exercises in CodeShikhi belong to CodeShikhi and its instructors. You may watch and use them for your own learning, but you may not copy, resell or publicly share them. Content you post in the Community — questions and answers — remains yours, and you give us permission to show it inside the app.',
    ),
    (
      '5. Privacy',
      'We collect only what the app needs to work: your name, email, learning progress and payment records. We never sell your personal data. You can control profile visibility in Settings > Privacy, and you can delete your account — and all your data — at any time from Settings > Delete account.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'Terms and privacy'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Last updated: November 2026',
            style: AppText.caption.copyWith(color: cs.textTertiary),
          ),
          const SizedBox(height: 20),
          for (final (title, body) in _sections) ...[
            Text(
              title,
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: AppText.body.copyWith(
                color: cs.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            'Questions about these terms? Contact us at hello@codeshikhi.app.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
        ],
      ),
    );
  }
}
