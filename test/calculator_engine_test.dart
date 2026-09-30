import 'package:flutter_test/flutter_test.dart';
import 'package:waec_wizzard/features/calculator/calculator_engine.dart';

void main() {
  group('basic arithmetic', () {
    test('handles pretty operator symbols', () {
      expect(CalculatorEngine.evaluate('12×3÷4', angleMode: AngleMode.radians), 9);
      expect(CalculatorEngine.evaluate('2+3×4', angleMode: AngleMode.radians), 14);
    });

    test('auto-closes missing parentheses', () {
      expect(CalculatorEngine.evaluate('(2+3', angleMode: AngleMode.radians), 5);
    });

    test('supports power and sqrt', () {
      expect(CalculatorEngine.evaluate('2^10', angleMode: AngleMode.radians), 1024);
      expect(CalculatorEngine.evaluate('√(16)', angleMode: AngleMode.radians), 4);
    });
  });

  group('constants', () {
    test('pi and e evaluate to their real values', () {
      expect(CalculatorEngine.evaluate('π', angleMode: AngleMode.radians), closeTo(3.14159265, 1e-6));
      expect(CalculatorEngine.evaluate('e', angleMode: AngleMode.radians), closeTo(2.71828182, 1e-6));
    });
  });

  group('logarithms', () {
    test('log(10, x) is base-10 log', () {
      expect(CalculatorEngine.evaluate('log(10,100)', angleMode: AngleMode.radians), closeTo(2, 1e-9));
    });

    test('ln is natural log', () {
      expect(CalculatorEngine.evaluate('ln(e)', angleMode: AngleMode.radians), closeTo(1, 1e-9));
    });
  });

  group('trigonometry in degree mode', () {
    test('sin/cos/tan take degree arguments', () {
      expect(CalculatorEngine.evaluate('sin(30)', angleMode: AngleMode.degrees), closeTo(0.5, 1e-9));
      expect(CalculatorEngine.evaluate('cos(60)', angleMode: AngleMode.degrees), closeTo(0.5, 1e-9));
      expect(CalculatorEngine.evaluate('tan(45)', angleMode: AngleMode.degrees), closeTo(1, 1e-9));
    });

    test('inverse trig results come back in degrees', () {
      expect(CalculatorEngine.evaluate('arcsin(0.5)', angleMode: AngleMode.degrees), closeTo(30, 1e-6));
    });

    test('nested trig calls inside arithmetic still convert correctly', () {
      // sin(30deg) + cos(60deg) = 0.5 + 0.5 = 1
      expect(CalculatorEngine.evaluate('sin(30)+cos(60)', angleMode: AngleMode.degrees), closeTo(1, 1e-9));
    });
  });

  group('trigonometry in radian mode', () {
    test('sin/cos/tan take radian arguments unmodified', () {
      expect(CalculatorEngine.evaluate('sin(0)', angleMode: AngleMode.radians), closeTo(0, 1e-9));
      expect(CalculatorEngine.evaluate('cos(0)', angleMode: AngleMode.radians), closeTo(1, 1e-9));
    });
  });

  group('formatting', () {
    test('whole numbers drop the decimal point', () {
      expect(CalculatorEngine.format(4.0), '4');
      expect(CalculatorEngine.format(-12.0), '-12');
    });

    test('fractional results trim floating point noise', () {
      expect(CalculatorEngine.format(0.1 + 0.2), '0.3');
    });
  });

  group('error handling', () {
    test('throws on empty input', () {
      expect(() => CalculatorEngine.evaluate('', angleMode: AngleMode.radians), throwsFormatException);
    });

    test('throws on division by zero producing a non-finite result', () {
      expect(() => CalculatorEngine.evaluate('1/0', angleMode: AngleMode.radians), throwsFormatException);
    });

    test('throws on malformed expressions', () {
      expect(() => CalculatorEngine.evaluate('×÷', angleMode: AngleMode.radians), throwsFormatException);
    });
  });
}
