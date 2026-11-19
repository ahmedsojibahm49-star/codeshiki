import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';

/// Extra-key row [F04] shown above the keyboard while editing.
///
/// The editor places this in the Scaffold's `bottomNavigationBar`, which
/// the Scaffold keeps above the on-screen keyboard (with the default
/// `resizeToAvoidBottomInset: true`). Tapping a chip inserts the symbol
/// at the cursor; Tab inserts spaces; Run runs the project.
class ExtraKeyRow extends StatelessWidget {
  const ExtraKeyRow({
    super.key,
    required this.onInsert,
    required this.onTab,
    required this.onRun,
    this.running = false,
  });

  final ValueChanged<String> onInsert;
  final VoidCallback onTab;
  final VoidCallback onRun;
  final bool running;

  static const List<String> symbols = [
    '{', '}', '[', ']', '(', ')', ';', '=', '"', "'",
    '<', '>', '/', '\\', '+', '-', '*', '.', ',', ':', '!', '?', '#',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.borderHairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: symbols.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _KeyChip(
                        label: 'Tab',
                        onTap: onTab,
                        wide: true,
                      );
                    }
                    final symbol = symbols[index - 1];
                    return _KeyChip(
                      label: symbol,
                      onTap: () => onInsert(symbol),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: running ? null : onRun,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (running)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.onPrimary,
                              ),
                            )
                          else
                            Icon(
                              AppIcons.playBold,
                              size: 16,
                              color: cs.onPrimary,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            running ? 'Running…' : 'Run',
                            style: AppText.label.copyWith(
                              color: cs.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyChip extends StatelessWidget {
  const _KeyChip({
    required this.label,
    required this.onTap,
    this.wide = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: cs.sunken,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 36,
          constraints: BoxConstraints(minWidth: wide ? 52 : 36),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppText.code.copyWith(color: cs.textPrimary),
          ),
        ),
      ),
    );
  }
}
