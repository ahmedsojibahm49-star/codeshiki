import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import 'syntax_highlighter.dart';

/// Full-height overlay code editor.
///
/// Standard overlay technique: a read-only highlighted [RichText] sits
/// underneath a transparent [TextField]; both share the same font, size,
/// line height and padding, and live inside ONE [SingleChildScrollView]
/// (driven by the parent's [scrollController]) so highlight, input and
/// the line-number gutter scroll together.
///
/// The gutter counts logical lines (a wrapped visual line shares its
/// logical line's number). Line height is `fontSize * 20 / 14` so numbers
/// stay aligned with text at any editor font size.
class CodeEditorWidget extends StatefulWidget {
  const CodeEditorWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    this.fontSize = 14,
    this.scheme,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final double fontSize;

  /// Resolved editor scheme (follows the editor theme setting:
  /// follow-app / light / dark). Falls back to `context.cs` when null.
  final CsScheme? scheme;

  final ValueChanged<String>? onChanged;

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(CodeEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // Rebuild so the highlight + gutter track the edited text.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.scheme ?? context.cs;
    final fontSize = widget.fontSize;
    final lineHeight = fontSize * 20 / 14;
    final textStyle = TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: fontSize,
      height: lineHeight / fontSize,
      color: cs.textPrimary,
    );
    const padding = EdgeInsets.fromLTRB(12, 12, 12, 32);
    final lineCount =
        '\n'.allMatches(widget.controller.text).length + 1;

    return Container(
      color: cs.synEditorBg,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          controller: widget.scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Line-number gutter (same top padding + line height
                  // as the code so numbers align with lines).
                  Container(
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 32,
                      left: 12,
                      right: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: cs.borderHairline),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 1; i <= lineCount; i++)
                          SizedBox(
                            height: lineHeight,
                            child: Text(
                              '$i',
                              style: TextStyle(
                                fontFamily: AppFonts.mono,
                                fontSize: fontSize,
                                height: lineHeight / fontSize,
                                color: cs.textTertiary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Highlight (below) + transparent input (above).
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: padding,
                          child: RichText(
                            text: TextSpan(
                              style: textStyle,
                              children: SyntaxHighlighter.highlight(
                                widget.controller.text,
                                cs,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: padding,
                            child: TextField(
                              controller: widget.controller,
                              focusNode: widget.focusNode,
                              onChanged: widget.onChanged,
                              maxLines: null,
                              minLines: null,
                              scrollPhysics:
                                  const NeverScrollableScrollPhysics(),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              autocorrect: false,
                              enableSuggestions: false,
                              smartQuotesType: SmartQuotesType.disabled,
                              smartDashesType: SmartDashesType.disabled,
                              textAlignVertical: TextAlignVertical.top,
                              style: textStyle.copyWith(
                                color: Colors.transparent,
                              ),
                              cursorColor: cs.accent,
                              cursorWidth: 2,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
