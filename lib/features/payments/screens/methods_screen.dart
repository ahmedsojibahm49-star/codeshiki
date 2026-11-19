import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Payment methods [I05]: bKash, Nagad, Rocket, Card.
class MethodsScreen extends StatefulWidget {
  const MethodsScreen({
    super.key,
    this.courseId,
    this.plan,
    this.total,
    this.coupon,
  });

  final String? courseId;
  final String? plan;
  final int? total;
  final String? coupon;

  @override
  State<MethodsScreen> createState() => _MethodsScreenState();
}

class _MethodsScreenState extends State<MethodsScreen> {
  String _selected = 'bKash';

  static const _methods = [
    ('bKash', 'Send Money', AppIcons.wallet),
    ('Nagad', 'Send Money', AppIcons.wallet),
    ('Rocket', 'Send Money', AppIcons.wallet),
    ('Card', 'Visa · Mastercard', AppIcons.card),
  ];

  int get _total =>
      widget.total ??
      discountedTotal(
        price: itemPrice(courseId: widget.courseId, plan: widget.plan),
        couponCode: widget.coupon,
      );

  void _continue() {
    final isCard = _selected == 'Card';
    final path = isCard ? '/payments/card' : '/payments/wallet';
    context.push(
      withQuery(
        path,
        checkoutParams(
          courseId: widget.courseId,
          plan: widget.plan,
          total: _total,
          coupon: widget.coupon,
          method: _selected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      appBar: const CsTopBar(title: 'Payment method'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How do you want to pay?',
              style: AppText.h1.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Total to pay: ${formatTaka(_total)}',
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 24),
            for (final method in _methods) ...[
              _MethodTile(
                name: method.$1,
                subtitle: method.$2,
                icon: method.$3,
                selected: _selected == method.$1,
                onTap: () => setState(() => _selected = method.$1),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            CsButton(
              label: 'Continue with $_selected',
              icon: AppIcons.arrowRight,
              onPressed: _continue,
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final bool selected;
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
            color: selected ? cs.sunken : cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? cs.primary : cs.border,
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: methodDotColor(context, name),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Icon(icon, size: 24, color: cs.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppText.label.copyWith(color: cs.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          AppText.caption.copyWith(color: cs.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? AppIcons.checkBold : AppIcons.check,
                size: 24,
                color: selected ? cs.primary : cs.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
