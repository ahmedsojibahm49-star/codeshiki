import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_sheet.dart';

/// Run console [F08] + test summary [F06]/[F10]: half-screen bottom sheet
/// with the canned run output and pass/fail test rows.
Future<void> showConsoleSheet(
  BuildContext context, {
  required List<String> outputLines,
  required List<CodeTestResult> tests,
}) {
  return showCsSheet<void>(
    context,
    _ConsoleSheet(outputLines: outputLines, tests: tests),
  );
}

class _ConsoleSheet extends StatefulWidget {
  const _ConsoleSheet({required this.outputLines, required this.tests});

  final List<String> outputLines;
  final List<CodeTestResult> tests;

  @override
  State<_ConsoleSheet> createState() => _ConsoleSheetState();
}

class _ConsoleSheetState extends State<_ConsoleSheet> {
  late List<String> _lines;

  @override
  void initState() {
    super.initState();
    _lines = List.of(widget.outputLines);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final passed = widget.tests.where((t) => t.passed).length;
    final total = widget.tests.length;
    final allPassed = total > 0 && passed == total;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allPassed ? AppIcons.checkBold : AppIcons.warningBold,
                  size: 22,
                  color: allPassed ? cs.success : cs.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    total == 0
                        ? 'Run finished'
                        : allPassed
                            ? 'All tests passed'
                            : '$passed of $total tests passed',
                    style: AppText.h3.copyWith(
                      color: allPassed ? cs.success : cs.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Demo run — output is simulated, code is not executed.',
              style: AppText.caption.copyWith(color: cs.textTertiary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: _lines.isEmpty
                      ? Text(
                          'Console cleared.',
                          style: AppText.code.copyWith(
                            color: cs.textTertiary,
                          ),
                        )
                      : Text(
                          _lines.join('\n'),
                          style: AppText.code.copyWith(
                            color: cs.textPrimary,
                          ),
                        ),
                ),
              ),
            ),
            if (widget.tests.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...widget.tests.map(
                (test) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        test.passed
                            ? AppIcons.checkBold
                            : AppIcons.closeBold,
                        size: 18,
                        color: test.passed ? cs.success : cs.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          test.name,
                          style: AppText.bodySmall.copyWith(
                            color: test.passed
                                ? cs.textPrimary
                                : cs.danger,
                          ),
                        ),
                      ),
                      Text(
                        test.passed ? 'PASS' : 'FAIL',
                        style: AppText.caption.copyWith(
                          color:
                              test.passed ? cs.success : cs.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CsButton(
                    label: 'Clear',
                    variant: CsButtonVariant.secondary,
                    size: CsButtonSize.m,
                    onPressed: () => setState(() => _lines = []),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CsButton(
                    label: 'Close',
                    size: CsButtonSize.m,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
