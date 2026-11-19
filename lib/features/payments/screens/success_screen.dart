import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/hive_boxes.dart';
import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';
import '../widgets/confetti_widget.dart';

/// Payment success [I09]: confetti, invoice, and the one-time side
/// effects (Pro / enrollment / order), guarded against double-apply.
class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({
    super.key,
    this.courseId,
    this.plan,
    this.total,
    this.coupon,
    this.method,
    this.invoice,
  });

  final String? courseId;
  final String? plan;
  final int? total;
  final String? coupon;
  final String? method;
  final String? invoice;

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  late final String _invoiceNo;
  late final int _total;

  @override
  void initState() {
    super.initState();
    // The processing screen mints the invoice and passes it in, so a
    // revisit of this URL reuses the same invoice — and the guard below
    // never double-applies. Fall back to a fresh invoice for direct links.
    _invoiceNo = widget.invoice ?? newInvoiceNo();
    _total = widget.total ??
        discountedTotal(
          price: itemPrice(courseId: widget.courseId, plan: widget.plan),
          couponCode: widget.coupon,
        );
    _applySideEffectsOnce();
  }

  /// Applies the purchase side effects exactly once per invoice.
  ///
  /// Guarded by a Hive flag `orderDone_<invoiceNo>` in the settings box,
  /// so rebuilds and revisits of this screen never re-enroll, re-add the
  /// order, or re-grant Pro.
  void _applySideEffectsOnce() {
    final flagKey = 'orderDone_$_invoiceNo';
    if (HiveBoxes.settings.get(flagKey) == true) return;
    HiveBoxes.settings.put(flagKey, true);
    if (widget.plan == 'pro') {
      ref.read(walletProvider.notifier).setPro(true);
    }
    final courseId = widget.courseId;
    if (courseId != null) {
      ref.read(enrollmentProvider.notifier).enroll(courseId);
    }
    ref.read(ordersProvider.notifier).addOrder(
          Order(
            id: _invoiceNo,
            courseTitle:
                itemTitle(courseId: widget.courseId, plan: widget.plan),
            amount: _total,
            dateLabel: todayLabel(),
            status: 'Paid',
            invoiceNo: _invoiceNo,
            paymentMethod: widget.method ?? 'Card',
          ),
        );
  }

  void _startLearning() {
    final courseId = widget.courseId;
    if (courseId != null) {
      final course = DemoData.courseById(courseId);
      final lessons = course?.allLessons ?? const [];
      if (lessons.isNotEmpty) {
        context.push(
          '/player/${lessons.first.id}?courseId=$courseId',
        );
        return;
      }
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isProPlan = widget.plan == 'pro';
    final courseTitle = widget.courseId == null
        ? null
        : DemoData.courseById(widget.courseId!)?.title;
    return Scaffold(
      appBar: const CsTopBar(title: 'Payment', showBack: false),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: cs.successSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.checkBold,
                      size: 48,
                      color: cs.success,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment successful!',
                  textAlign: TextAlign.center,
                  style: AppText.h1.copyWith(color: cs.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  isProPlan
                      ? 'Welcome to Shikhi Pro. All courses are unlocked.'
                      : courseTitle == null
                          ? 'Your purchase is complete. Start learning today.'
                          : '“$courseTitle” is yours now. Start learning today.',
                  textAlign: TextAlign.center,
                  style: AppText.bodySmall.copyWith(color: cs.textSecondary),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.border),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow(label: 'Invoice no', value: _invoiceNo),
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: 'Item',
                        value: itemTitle(
                          courseId: widget.courseId,
                          plan: widget.plan,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(label: 'Amount', value: formatTaka(_total)),
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: 'Method',
                        value: widget.method ?? 'Card',
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(label: 'Date', value: todayLabel()),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CsButton(
                  label: 'Start learning',
                  icon: AppIcons.play,
                  onPressed: _startLearning,
                ),
                const SizedBox(height: 12),
                CsButton(
                  label: 'View order',
                  variant: CsButtonVariant.secondary,
                  onPressed: () =>
                      context.push('/payments/orders/$_invoiceNo'),
                ),
              ],
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: ConfettiWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppText.bodySmall.copyWith(color: cs.textSecondary),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
        ),
      ],
    );
  }
}
