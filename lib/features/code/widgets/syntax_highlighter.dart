import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';

/// Simple regex-free tokenizer that turns source code into colored
/// [TextSpan] runs. One tokenizer covers JS / Python / Java adequately:
/// comments, strings, keywords, numbers, function calls, plain text.
///
/// Scan order at each position: block comment, line comment, string,
/// number, identifier (keyword or function call), otherwise plain text.
/// Default runs carry no style so they inherit the parent RichText style.
class SyntaxHighlighter {
  SyntaxHighlighter._();

  static const Set<String> _keywords = {
    // JS / Java / Python (shared core from the brief)
    'const', 'let', 'var', 'function', 'return', 'if', 'else', 'for',
    'while', 'class', 'import', 'from', 'export', 'def', 'print',
    'public', 'static', 'void', 'int', 'new',
    // Extra common keywords
    'elif', 'in', 'is', 'not', 'and', 'or', 'True', 'False', 'None',
    'this', 'null', 'boolean', 'String', 'extends', 'try', 'catch',
    'final', 'async', 'await', 'do', 'switch', 'case', 'break',
    'continue', 'double', 'float', 'long', 'char', 'throws', 'package',
    'self', 'lambda', 'typeof', 'of',
  };

  static bool _isIdentStart(int code) =>
      (code >= 65 && code <= 90) || // A-Z
      (code >= 97 && code <= 122) || // a-z
      code == 95; // _

  static bool _isIdentPart(int code) =>
      _isIdentStart(code) || (code >= 48 && code <= 57); // 0-9

  static bool _isDigit(int code) => code >= 48 && code <= 57;

  static bool _isHexDigit(int code) =>
      _isDigit(code) ||
      (code >= 65 && code <= 70) || // A-F
      (code >= 97 && code <= 102); // a-f

  static List<TextSpan> highlight(String code, CsScheme cs) {
    final spans = <TextSpan>[];
    final plain = StringBuffer();

    void emit(String text, Color? color) {
      if (text.isEmpty) return;
      spans.add(
        TextSpan(
          text: text,
          style: color == null ? null : TextStyle(color: color),
        ),
      );
    }

    void flushPlain() {
      if (plain.isNotEmpty) {
        emit(plain.toString(), null);
        plain.clear();
      }
    }

    var i = 0;
    final n = code.length;
    while (i < n) {
      final ch = code[i];
      final next = i + 1 < n ? code[i + 1] : '';

      // Block comment: /* ... */
      if (ch == '/' && next == '*') {
        flushPlain();
        var j = i + 2;
        while (j + 1 < n && !(code[j] == '*' && code[j + 1] == '/')) {
          j++;
        }
        if (j + 1 < n) j += 2;
        emit(code.substring(i, j), cs.synComment);
        i = j;
        continue;
      }

      // Line comment: // ... (JS/Java) or # ... (Python).
      // A '#' followed by hex digits is a CSS hex color, not a comment.
      if (ch == '/' && next == '/') {
        flushPlain();
        var j = i;
        while (j < n && code[j] != '\n') {
          j++;
        }
        emit(code.substring(i, j), cs.synComment);
        i = j;
        continue;
      }
      if (ch == '#') {
        final after = i + 1 < n ? code.codeUnitAt(i + 1) : -1;
        if (_isHexDigit(after)) {
          // Hex color literal, e.g. #fff7f0 — color it like a number.
          flushPlain();
          var j = i + 1;
          while (j < n && _isHexDigit(code.codeUnitAt(j))) {
            j++;
          }
          emit(code.substring(i, j), cs.synNumber);
          i = j;
          continue;
        }
        flushPlain();
        var j = i;
        while (j < n && code[j] != '\n') {
          j++;
        }
        emit(code.substring(i, j), cs.synComment);
        i = j;
        continue;
      }

      // String: "..." '...' `...` (with backslash escapes).
      if (ch == '"' || ch == "'" || ch == '`') {
        flushPlain();
        var j = i + 1;
        while (j < n && code[j] != ch) {
          if (code[j] == '\\' && j + 1 < n) j++;
          j++;
        }
        if (j < n) j++; // closing quote
        emit(code.substring(i, j), cs.synString);
        i = j;
        continue;
      }

      // Number: digits with an optional decimal point.
      if (_isDigit(code.codeUnitAt(i))) {
        flushPlain();
        var j = i;
        while (j < n &&
            (_isDigit(code.codeUnitAt(j)) || code[j] == '.')) {
          j++;
        }
        emit(code.substring(i, j), cs.synNumber);
        i = j;
        continue;
      }

      // Identifier: keyword, function call (name followed by `(`),
      // or plain identifier.
      if (_isIdentStart(code.codeUnitAt(i))) {
        flushPlain();
        var j = i;
        while (j < n && _isIdentPart(code.codeUnitAt(j))) {
          j++;
        }
        final word = code.substring(i, j);
        if (_keywords.contains(word)) {
          emit(word, cs.synKeyword);
        } else {
          var k = j;
          while (k < n && (code[k] == ' ' || code[k] == '\t')) {
            k++;
          }
          if (k < n && code[k] == '(') {
            emit(word, cs.synFunction);
          } else {
            emit(word, null);
          }
        }
        i = j;
        continue;
      }

      plain.write(ch);
      i++;
    }
    flushPlain();
    if (spans.isEmpty) return const [TextSpan(text: '')];
    return spans;
  }
}
