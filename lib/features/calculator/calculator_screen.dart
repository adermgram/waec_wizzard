import 'package:flutter/material.dart';

import 'calculator_engine.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _buffer = '';
  String _lastExpression = '';
  bool _justEvaluated = false;
  bool _error = false;
  AngleMode _angleMode = AngleMode.degrees;

  String get _display => _buffer.isEmpty ? '0' : _buffer;

  void _inputDigitOrConstant(String token) {
    setState(() {
      if (_justEvaluated) {
        _buffer = '';
        _lastExpression = '';
        _justEvaluated = false;
      }
      _error = false;
      _buffer += token;
    });
  }

  void _inputOperator(String token) {
    setState(() {
      _justEvaluated = false;
      _error = false;
      _buffer += token;
    });
  }

  void _clear() {
    setState(() {
      _buffer = '';
      _lastExpression = '';
      _justEvaluated = false;
      _error = false;
    });
  }

  void _backspace() {
    if (_buffer.isEmpty) return;
    setState(() {
      _buffer = _buffer.substring(0, _buffer.length - 1);
      _error = false;
    });
  }

  void _evaluate() {
    if (_buffer.isEmpty) return;
    try {
      final value = CalculatorEngine.evaluate(_buffer, angleMode: _angleMode);
      setState(() {
        _lastExpression = _buffer;
        _buffer = CalculatorEngine.format(value);
        _justEvaluated = true;
        _error = false;
      });
    } on FormatException {
      setState(() => _error = true);
    }
  }

  void _toggleAngleMode() {
    setState(() {
      _angleMode = _angleMode == AngleMode.degrees ? AngleMode.radians : AngleMode.degrees;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: TextButton(
                onPressed: _toggleAngleMode,
                child: Text(_angleMode == AngleMode.degrees ? 'DEG' : 'RAD'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_lastExpression.isNotEmpty)
                      Text(
                        _lastExpression,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _error ? 'Error' : _display,
                        key: const Key('calculator_display'),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _error ? scheme.error : scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    // Function rows.
                    _row([
                      _FuncButton('sin(', onTap: _inputDigitOrConstant),
                      _FuncButton('cos(', onTap: _inputDigitOrConstant),
                      _FuncButton('tan(', onTap: _inputDigitOrConstant),
                      _FuncButton('^', label: 'xʸ', onTap: _inputOperator),
                      _FuncButton('√(', label: '√', onTap: _inputDigitOrConstant),
                    ]),
                    _row([
                      _FuncButton('arcsin(', label: 'sin⁻¹', onTap: _inputDigitOrConstant),
                      _FuncButton('arccos(', label: 'cos⁻¹', onTap: _inputDigitOrConstant),
                      _FuncButton('arctan(', label: 'tan⁻¹', onTap: _inputDigitOrConstant),
                      _FuncButton('ln(', onTap: _inputDigitOrConstant),
                      _FuncButton('log(10,', label: 'log', onTap: _inputDigitOrConstant),
                    ]),
                    _row([
                      _FuncButton('(', label: '(', onTap: _inputDigitOrConstant),
                      _FuncButton(')', onTap: _inputDigitOrConstant),
                      _FuncButton('π', onTap: _inputDigitOrConstant),
                      _FuncButton('e', onTap: _inputDigitOrConstant),
                      _OpButton('^2', label: 'x²', onTap: _inputOperator),
                    ]),
                    // Digit rows, in the standard 7-8-9 / 4-5-6 / 1-2-3 / 0
                    // order, with operators consistently in the 4th column
                    // and clear/delete/percent as a convenience 5th column.
                    _row([
                      _DigitButton('7', onTap: _inputDigitOrConstant),
                      _DigitButton('8', onTap: _inputDigitOrConstant),
                      _DigitButton('9', onTap: _inputDigitOrConstant),
                      _OpButton('÷', onTap: _inputOperator),
                      _ActionButton('AC', onTap: _clear, kind: _ButtonKind.action),
                    ]),
                    _row([
                      _DigitButton('4', onTap: _inputDigitOrConstant),
                      _DigitButton('5', onTap: _inputDigitOrConstant),
                      _DigitButton('6', onTap: _inputDigitOrConstant),
                      _OpButton('×', onTap: _inputOperator),
                      _ActionButton('⌫', onTap: _backspace, kind: _ButtonKind.action),
                    ]),
                    _row([
                      _DigitButton('1', onTap: _inputDigitOrConstant),
                      _DigitButton('2', onTap: _inputDigitOrConstant),
                      _DigitButton('3', onTap: _inputDigitOrConstant),
                      _OpButton('-', label: '−', onTap: _inputOperator),
                      _OpButton('/100', label: '%', onTap: _inputOperator),
                    ]),
                    _row([
                      _DigitButton('0', onTap: _inputDigitOrConstant),
                      _DigitButton('.', onTap: _inputDigitOrConstant),
                      _OpButton('+', onTap: _inputOperator),
                      _ActionButton('=', onTap: _evaluate, kind: _ButtonKind.equals),
                    ], flexes: const [2, 1, 1, 1]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<Widget> children, {List<int>? flexes}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++)
              Expanded(flex: flexes != null ? flexes[i] : 1, child: children[i]),
          ],
        ),
      ),
    );
  }
}

typedef _TokenCallback = void Function(String token);

enum _ButtonKind { digit, operatorKey, function, action, equals }

class _CalcButton extends StatelessWidget {
  final String display;
  final String token;
  final _ButtonKind kind;
  final _TokenCallback onTap;

  const _CalcButton({
    required this.display,
    required this.token,
    required this.kind,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color background;
    Color foreground;

    switch (kind) {
      case _ButtonKind.digit:
        background = scheme.surfaceContainerHigh;
        foreground = scheme.onSurface;
        break;
      case _ButtonKind.operatorKey:
        background = scheme.secondaryContainer;
        foreground = scheme.onSecondaryContainer;
        break;
      case _ButtonKind.function:
        background = scheme.surfaceContainer;
        foreground = scheme.onSurfaceVariant;
        break;
      case _ButtonKind.action:
        background = scheme.tertiaryContainer;
        foreground = scheme.onTertiaryContainer;
        break;
      case _ButtonKind.equals:
        background = scheme.primary;
        foreground = scheme.onPrimary;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox.expand(
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTap(token),
            child: Center(
              child: Text(
                display,
                style: TextStyle(
                  color: foreground,
                  fontSize: 17,
                  fontWeight: kind == _ButtonKind.equals ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DigitButton extends _CalcButton {
  const _DigitButton(String token, {required super.onTap})
    : super(display: token, token: token, kind: _ButtonKind.digit);
}

class _OpButton extends _CalcButton {
  const _OpButton(String token, {String? label, required super.onTap})
    : super(display: label ?? token, token: token, kind: _ButtonKind.operatorKey);
}

class _FuncButton extends _CalcButton {
  _FuncButton(String token, {String? label, required super.onTap})
    : super(
        display: label ?? token.replaceAll('(', ''),
        token: token,
        kind: _ButtonKind.function,
      );
}

class _ActionButton extends _CalcButton {
  _ActionButton(String label, {required VoidCallback onTap, required super.kind})
    : super(display: label, token: '', onTap: (_) => onTap());
}
