import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A function that validates a value of type T.
typedef SmartValidator<T> = String? Function(T? value);

/// A function that validates a value of type T asynchronously.
typedef SmartAsyncValidator<T> = Future<String?> Function(T? value);

/// Represents a registered field in the form.
class SmartFieldRegistration<T> {
  final GlobalKey key;
  final FocusNode focusNode;
  final T? Function() getValue;
  final SmartValidator<T>? validator;
  final SmartAsyncValidator<T>? asyncValidator;
  final ValueNotifier<String?> errorNotifier;
  final ValueNotifier<bool> shakeNotifier;
  final ValueNotifier<bool> loadingNotifier;

  SmartFieldRegistration({
    required this.key,
    required this.focusNode,
    required this.getValue,
    this.validator,
    this.asyncValidator,
    required this.errorNotifier,
    required this.shakeNotifier,
    required this.loadingNotifier,
  });

  bool get hasAsyncValidator => asyncValidator != null;

  /// Validates the field synchronously and returns the error message if invalid.
  String? validate() {
    if (validator == null) return null;
    return validator!(getValue());
  }

  /// Validates the field asynchronously.
  Future<String?> validateAsync() async {
    // First run sync validator
    final syncError = validate();
    if (syncError != null) return syncError;

    // Then run async validator if exists
    if (asyncValidator != null) {
      loadingNotifier.value = true;
      try {
        final error = await asyncValidator!(getValue());
        return error;
      } finally {
        loadingNotifier.value = false;
      }
    }
    return null;
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

  /// Validates all fields synchronously and returns true if all are valid.
  /// 
  /// If invalid, focuses and scrolls to the first invalid field,
  /// triggers shake animation, and shows error message.
  bool validate() {
    _isValidating = true;
    notifyListeners();

    // Clear all previous errors logic removed to prevent flashing/lag
    // Existing error states will be updated in the loop below.

    // Find first invalid field
    SmartFieldRegistration? firstInvalid;

    for (final field in _fields) {
      final error = field.validate();
      if (error != null) {
        // Show error immediately for all invalid fields
        field.errorNotifier.value = error;
        // Shake all invalid fields
        field.shakeNotifier.value = false;
        field.shakeNotifier.value = true;
        
        if (firstInvalid == null) {
          firstInvalid = field;
        }
      }
    }

    _isValidating = false;
    notifyListeners();

    if (firstInvalid != null) {
      _handleInvalidField(firstInvalid);
      return false;
    }

    return true;
  }

  /// Validates all fields asynchronously and returns true if all are valid.
  Future<bool> validateAsync() async {
    _isValidating = true;
    notifyListeners();

    SmartFieldRegistration? firstInvalid;
    
    for (final field in _fields) {
      // 1. Sync check
      String? error = field.validate();
      
      // 2. Async check if sync passed
      if (error == null && field.hasAsyncValidator) {
        error = await field.validateAsync();
      }

      if (error != null) {
        field.errorNotifier.value = error; // Show error immediately
        // Shake all invalid fields
        field.shakeNotifier.value = false;
        field.shakeNotifier.value = true;
        
        if (firstInvalid == null) {
          firstInvalid = field;
        }
      }
    }

    _isValidating = false;
    notifyListeners();

    if (firstInvalid != null) {
      _handleInvalidField(firstInvalid);
      return false;
    }

    return true;
  }

  void _handleInvalidField(SmartFieldRegistration field) {
      if (enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }

      // Focus the field immediately to trigger keyboard
      field.focusNode.requestFocus();

      // Scroll to the field after layout updates (e.g. error messages appearing)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Small delay to allow keyboard to start finding its place and layout to settle
        await Future.delayed(const Duration(milliseconds: 100));
        _scrollToField(field);
      });
  }

  /// Scrolls to make the field visible.
  void _scrollToField(SmartFieldRegistration field) {
    final context = field.key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: 0.0, // Scroll to top
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
