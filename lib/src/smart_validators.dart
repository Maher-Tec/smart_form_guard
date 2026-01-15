/// Signature for a function that validates a form field.
typedef SmartValidator = String? Function(String? value);

/// A collection of commonly used validators for form fields.
class SmartValidators {
  SmartValidators._();

  /// Creates a validator that checks if the value is not empty.
  static SmartValidator required([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message ?? 'This field is required';
      }
      return null;
    };
  }

  /// Creates a validator that checks if the value is a valid email address.
  static SmartValidator email([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required() handle empty check
      }
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(value.trim())) {
        return message ?? 'Please enter a valid email address';
      }
      return null;
    };
  }

  /// Creates a validator that checks password strength.
  /// 
  /// Default requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  static SmartValidator password({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecialChar = false,
    String? message,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return null; // Let required() handle empty check
      }

      if (value.length < minLength) {
        return message ?? 'Password must be at least $minLength characters';
      }

      if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
        return message ?? 'Password must contain at least one uppercase letter';
      }

      if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
        return message ?? 'Password must contain at least one lowercase letter';
      }

      if (requireDigit && !value.contains(RegExp(r'[0-9]'))) {
        return message ?? 'Password must contain at least one digit';
      }

      if (requireSpecialChar && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return message ?? 'Password must contain at least one special character';
      }

      return null;
    };
  }

  /// Creates a validator that checks if the value is a valid phone number.
  static SmartValidator phone([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required() handle empty check
      }
      // Flexible phone pattern: allows +, spaces, dashes, parentheses
      final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{7,20}$');
      if (!phoneRegex.hasMatch(value.trim())) {
        return message ?? 'Please enter a valid phone number';
      }
      return null;
    };
  }

  /// Creates a validator that checks minimum length.
  static SmartValidator minLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      if (value.length < length) {
        return message ?? 'Must be at least $length characters';
      }
      return null;
    };
  }

  /// Creates a validator that checks maximum length.
  static SmartValidator maxLength(int length, [String? message]) {
    return (value) {
      if (value == null) {
        return null;
      }
      if (value.length > length) {
        return message ?? 'Must be at most $length characters';
      }
      return null;
    };
  }

  /// Creates a validator that matches a custom regex pattern.
  static SmartValidator pattern(RegExp regex, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      if (!regex.hasMatch(value)) {
        return message ?? 'Invalid format';
      }
      return null;
    };
  }

  /// Composes multiple validators into one.
  /// 
  /// Returns the first error message found, or null if all pass.
  static SmartValidator compose(List<SmartValidator> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}
