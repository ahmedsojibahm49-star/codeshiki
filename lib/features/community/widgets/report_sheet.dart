import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';

/// Report a question [G11]. Demo only — shows a confirmation toast.
Future<void> showReportSheet(BuildContext context, String questionId) {
  return showCsSheet<void>(
    context,
    ReportSheet(questionId: questionId),
  );
}

class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key, required this.questionId});

  /// Id of the question being reported (kept for the future real API).
  final String questionId;

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  static const _reasons = [
    'Spam',
    'Harassment',
    'Wrong category',
    'Other',
  ];

  String? _reason;
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_reason == null) {
      showCsToast(context, 'Please choose a reason first', isError: true);
      return;
    }
    Navigator.of(context).pop();
    showCsToast(
      context,
      'Report submitted. Our team will review it.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report question',
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us what is wrong with this question.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasons
                .map(
                  (reason) => CsFilterChip(
                    label: reason,
                    selected: _reason == reason,
                    onTap: () => setState(() => _reason = reason),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          CsTextField(
            label: 'Details (optional)',
            hint: 'Add anything that helps us review…',
            controller: _detailsController,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          CsButton(label: 'Submit report', onPressed: _submit),
        ],
      ),
    );
  }
}
