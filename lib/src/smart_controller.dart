import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A function that validates a value of type T.
typedef SmartValidator<T> = String? Function(T? value);

/// Represents a registered field in the form.
class SmartFieldRegistration<T> {
  final GlobalKey key;
  final FocusNode focusNode;
  final T? Function() getValue;
  final String? Function(T?)? validator;
  final ValueNotifier<String?> errorNotifier;
  final ValueNotifier<bool> shakeNotifier;

  SmartFieldRegistration({
    required this.key,
    required this.focusNode,
    required this.getValue,
    this.validator,
    required this.errorNotifier,
    required this.shakeNotifier,
  });

  /// Validates the field and returns the error message if invalid.
  String? validate() {
    if (validator == null) return null;
    return validator!(getValue());
  }
}

/// Controller that manages form state and validation.
class SmartFormController extends ChangeNotifier {
  final List<SmartFieldRegistration<dynamic>> _fields = [];
  bool _isValidating = false;
  bool enableHapticFeedback = true;

  /// Whether the form is currently validating.
  bool get isValidating => _isValidating;

  /// Registers a field with the form.
  void registerField(SmartFieldRegistration<dynamic> field) {
    _fields.add(field);
  }

  /// Unregisters a field from the form.
  void unregisterField(SmartFieldRegistration<dynamic> field) {
    _fields.remove(field);
  }

  /// Validates all fields and returns true if all are valid.
  /// 
  /// If invalid, focuses and scrolls to the first invalid field,
  /// triggers shake animation, and shows error message.
  bool validate() {
    _isValidating = true;
    notifyListeners();

    // Clear all previous errors
    for (final field in _fields) {
      field.errorNotifier.value = null;
    }

    // Find first invalid field
    SmartFieldRegistration? firstInvalid;
    String? firstError;

    for (final field in _fields) {
      final error = field.validate();
      if (error != null && firstInvalid == null) {
        firstInvalid = field;
        firstError = error;
        break; // Only show first error (progressive validation)
      }
    }

    _isValidating = false;
    notifyListeners();

    if (firstInvalid != null) {
      if (enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }

      // Show error on the first invalid field
      firstInvalid.errorNotifier.value = firstError;

      // Trigger shake animation
      firstInvalid.shakeNotifier.value = true;

      // Focus the field
      firstInvalid.focusNode.requestFocus();

      // Scroll to the field
      _scrollToField(firstInvalid);

      return false;
    }

    return true;
  }

  /// Scrolls to make the field visible.
  void _scrollToField(SmartFieldRegistration field) {
    final context = field.key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: 0.3, // Show field 30% from top
      );
    }
  }

  /// Clears all errors from fields.
  void clearErrors() {
    for (final field in _fields) {
      field.errorNotifier.value = null;
    }
  }

  @override
  void dispose() {
    _fields.clear();
    super.dispose();
  }
}

/// InheritedWidget that provides access to [SmartFormController].
class SmartFormScope extends InheritedWidget {
  final SmartFormController controller;

  const SmartFormScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Gets the nearest [SmartFormController] from context.
  static SmartFormController? of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SmartFormScope>();
    return scope?.controller;
  }

  /// Gets the nearest [SmartFormController] without listening to changes.
  static SmartFormController? maybeOf(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<SmartFormScope>();
    return scope?.controller;
  }

  @override
  bool updateShouldNotify(SmartFormScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
