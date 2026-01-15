import 'package:flutter_test/flutter_test.dart';
import 'package:smart_form_guard/smart_form_guard.dart';

void main() {
  group('SmartValidators', () {
    group('required', () {
      test('returns error for null value', () {
        final validator = SmartValidators.required();
        expect(validator(null), isNotNull);
      });

      test('returns error for empty string', () {
        final validator = SmartValidators.required();
        expect(validator(''), isNotNull);
        expect(validator('   '), isNotNull);
      });

      test('returns null for non-empty value', () {
        final validator = SmartValidators.required();
        expect(validator('hello'), isNull);
      });

      test('returns custom message', () {
        final validator = SmartValidators.required('Custom message');
        expect(validator(''), 'Custom message');
      });
    });

    group('email', () {
      test('returns null for valid email', () {
        final validator = SmartValidators.email();
        expect(validator('test@example.com'), isNull);
        expect(validator('user.name@domain.co'), isNull);
      });

      test('returns error for invalid email', () {
        final validator = SmartValidators.email();
        expect(validator('invalid'), isNotNull);
        expect(validator('missing@domain'), isNotNull);
        expect(validator('@nodomain.com'), isNotNull);
      });

      test('returns null for empty (let required handle it)', () {
        final validator = SmartValidators.email();
        expect(validator(''), isNull);
        expect(validator(null), isNull);
      });
    });

    group('password', () {
      test('returns null for valid password', () {
        final validator = SmartValidators.password();
        expect(validator('Password1'), isNull);
        expect(validator('MyStr0ngPass'), isNull);
      });

      test('returns error for short password', () {
        final validator = SmartValidators.password(minLength: 8);
        expect(validator('Short1'), isNotNull);
      });

      test('returns error for missing uppercase', () {
        final validator = SmartValidators.password(requireUppercase: true);
        expect(validator('password1'), isNotNull);
      });

      test('returns error for missing lowercase', () {
        final validator = SmartValidators.password(requireLowercase: true);
        expect(validator('PASSWORD1'), isNotNull);
      });

      test('returns error for missing digit', () {
        final validator = SmartValidators.password(requireDigit: true);
        expect(validator('Password'), isNotNull);
      });
    });

    group('phone', () {
      test('returns null for valid phone', () {
        final validator = SmartValidators.phone();
        expect(validator('+1234567890'), isNull);
        expect(validator('123-456-7890'), isNull);
        expect(validator('(123) 456-7890'), isNull);
      });

      test('returns error for invalid phone', () {
        final validator = SmartValidators.phone();
        expect(validator('123'), isNotNull);
        expect(validator('abcdefghij'), isNotNull);
      });
    });

    group('minLength', () {
      test('returns null for value meeting minimum', () {
        final validator = SmartValidators.minLength(5);
        expect(validator('hello'), isNull);
        expect(validator('hello world'), isNull);
      });

      test('returns error for short value', () {
        final validator = SmartValidators.minLength(5);
        expect(validator('hi'), isNotNull);
      });
    });

    group('maxLength', () {
      test('returns null for value under maximum', () {
        final validator = SmartValidators.maxLength(10);
        expect(validator('short'), isNull);
      });

      test('returns error for long value', () {
        final validator = SmartValidators.maxLength(5);
        expect(validator('too long text'), isNotNull);
      });
    });

    group('compose', () {
      test('returns first error found', () {
        final validator = SmartValidators.compose([
          SmartValidators.required('Required'),
          SmartValidators.email('Invalid email'),
        ]);
        expect(validator(''), 'Required');
        expect(validator('invalid'), 'Invalid email');
      });

      test('returns null when all pass', () {
        final validator = SmartValidators.compose([
          SmartValidators.required(),
          SmartValidators.email(),
        ]);
        expect(validator('test@example.com'), isNull);
      });
    });
  });
}
