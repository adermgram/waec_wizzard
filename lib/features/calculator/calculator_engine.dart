import 'package:math_expressions/math_expressions.dart';

enum AngleMode { degrees, radians }

/// Evaluates calculator display-buffer strings (as built up by [CalculatorScreen]
/// button presses) into a numeric result.
///
/// The buffer uses human-friendly tokens ('×', '÷', '√(', 'π', a bare 'e',
/// 'sin(', 'arcsin(', 'log(10,' etc.) which are translated into
/// `math_expressions`-parseable syntax here, with trig functions additionally
/// converted between degrees and radians since the underlying library always
/// works in radians.
class CalculatorEngine {
  static const double _degToRad = 0.017453292519943295;
  static const double _radToDeg = 57.29577951308232;

  static const _trigFunctions = {'sin', 'cos', 'tan'};
  static const _inverseTrigFunctions = {'arcsin', 'arccos', 'arctan'};

  static double evaluate(String buffer, {required AngleMode angleMode}) {
    if (buffer.trim().isEmpty) {
      throw const FormatException('Empty expression');
    }

    var expr = buffer
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('√(', 'sqrt(')
        .replaceAll('π', '(3.141592653589793)')
        .replaceAll('e', '(2.718281828459045)');

    expr = _autoCloseParens(expr);

    if (angleMode == AngleMode.degrees) {
      expr = _adjustForDegrees(expr);
    }

    final num result;
    try {
      result = Parser().parse(expr).evaluate(EvaluationType.REAL, ContextModel()) as num;
    } on FormatException {
      rethrow;
    } catch (e) {
      // math_expressions throws raw RangeError/etc. for some malformed
      // input instead of its own FormatException - normalize it.
      throw FormatException('Invalid expression: $e');
    }

    final value = result.toDouble();
    if (!value.isFinite) {
      throw const FormatException('Result is not a finite number');
    }
    return value;
  }

  /// Formats a result for display: trims floating-point noise and drops a
  /// trailing ".0" for whole numbers.
  static String format(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toStringAsFixed(0);
    }
    var s = value.toStringAsPrecision(12);
    if (s.contains('.') && !s.contains('e')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  static String _autoCloseParens(String expr) {
    final open = '('.allMatches(expr).length;
    final close = ')'.allMatches(expr).length;
    if (open > close) {
      return expr + ')' * (open - close);
    }
    return expr;
  }

  /// Rewrites trig/inverse-trig function calls so they operate in degrees:
  /// `sin(x)` -> `sin((x)*degToRad)`, `arcsin(x)` -> `(arcsin(x)*radToDeg)`.
  /// Processes longer names (arcsin/arccos/arctan) before their shorter
  /// substrings (sin/cos/tan) so "arcsin(" is never mistaken for "sin(".
  static String _adjustForDegrees(String expr) {
    const order = [..._inverseTrigFunctions, ..._trigFunctions];
    final buffer = StringBuffer();
    var i = 0;
    while (i < expr.length) {
      String? matchedName;
      for (final name in order) {
        if (expr.startsWith('$name(', i)) {
          matchedName = name;
          break;
        }
      }

      if (matchedName == null) {
        buffer.write(expr[i]);
        i++;
        continue;
      }

      final openParen = i + matchedName.length;
      final closeParen = _matchingParen(expr, openParen);
      final inner = expr.substring(openParen + 1, closeParen);
      final processedInner = _adjustForDegrees(inner);

      if (_trigFunctions.contains(matchedName)) {
        buffer.write('$matchedName(($processedInner)*$_degToRad)');
      } else {
        buffer.write('($matchedName($processedInner)*$_radToDeg)');
      }
      i = closeParen + 1;
    }
    return buffer.toString();
  }

  static int _matchingParen(String s, int openIndex) {
    var depth = 0;
    for (var i = openIndex; i < s.length; i++) {
      if (s[i] == '(') {
        depth++;
      } else if (s[i] == ')') {
        depth--;
        if (depth == 0) return i;
      }
    }
    throw const FormatException('Mismatched parentheses');
  }
}
