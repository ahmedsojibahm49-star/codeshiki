import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';

/// Plan comparison [I02]: feature table, Free vs Pro.
class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  static const _rows = [
    ('Free courses', true, true),
    ('All paid courses', false, true),
    ('Offline downloads', false, true),
    ('AI hints in the code editor', false, true),
    ('Certificates on completion', false, true),
    ('Community access', true, true),
    ('Daily practice', true, true),
    ('Ad-free learning', false, true),
    ('Priority support', false, true),
    ('Early access to new courses', false, true),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final isPro = ref.watch(walletProvider).isPro;
    return Scaffold(
      appBar: const CsTopBar(title: 'Compare plans'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Free vs Pro',
              style: AppText.h1.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Everything in Free, plus the full library and Pro perks.',
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _CompareRow(
                    label: 'Feature',
                    freeLabel: 'Free',
                    proLabel: 'Pro',
                    isHeader: true,
                  ),
                  const Divider(height: 1),
                  for (var i = 0; i < _rows.length; i++) ...[
                    _CompareRow(
                      label: _rows[i].$1,
                      freeIncluded: _rows[i].$2,
                      proIncluded: _rows[i].$3,
                    ),
                    if (i < _rows.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            CsButton(
              label: isPro ? "You're on Pro" : 'Go Pro — ৳499/month',
              variant: CsButtonVariant.pro,
              onPressed: isPro
                  ? null
                  : () => context.push('/payments/checkout?plan=pro'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    this.freeLabel,
    this.proLabel,
    this.freeIncluded,
    this.proIncluded,
    this.isHeader = false,
  });

  final String label;
  final String? freeLabel;
  final String? proLabel;
  final bool? freeIncluded;
  final bool? proIncluded;
  final bool isHeader;

  Widget _cell(BuildContext context, bool? included, String? text) {
    final cs = context.cs;
    if (text != null) {
      return Text(
        text,
        style: AppText.label.copyWith(color: cs.textPrimary),
        textAlign: TextAlign.center,
      );
    }
    final hasIt = included ?? false;
    return Icon(
      hasIt ? AppIcons.check : AppIcons.close,
      size: 22,
      color: hasIt ? cs.success : cs.textTertiary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: (isHeader ? AppText.label : AppText.bodySmall).copyWith(
                color: cs.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(child: _cell(context, freeIncluded, freeLabel)),
          ),
          Expanded(
            child: Center(child: _cell(context, proIncluded, proLabel)),
          ),
        ],
      ),
    );
  }
}
