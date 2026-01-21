import 'package:flutter/widgets.dart';
import 'smart_controller.dart';

/// A smart form wrapper that validates fields and provides pleasant UX.
/// 
/// Wrap your form fields in [SmartForm] and use [SmartField] widgets
/// as children. Use [SmartSubmitButton] to trigger validation.
/// 
/// ```dart
/// SmartForm(
///   onValid: () => print("Form is valid!"),
///   child: Column(
///     children: [
///       SmartField.email(controller: emailCtrl, label: "Email"),
///       SmartField.password(controller: passCtrl, label: "Password"),
///       SmartSubmitButton(text: "Submit"),
///     ],
///   ),
/// );
/// ```
class SmartForm extends StatefulWidget {
  /// The form content, typically containing [SmartField] widgets.
  final Widget child;

  /// Called when all fields are valid after submission.
  final VoidCallback? onValid;

  /// Called when validation fails.
  final VoidCallback? onInvalid;

  /// Optional external controller for advanced control.
  final SmartFormController? controller;

  /// Whether to trigger haptic feedback on validation failure.
  final bool enableHapticFeedback;

  const SmartForm({
    super.key,
    required this.child,
    this.onValid,
    this.onInvalid,
    this.controller,
    this.enableHapticFeedback = true,
  });

  @override
  State<SmartForm> createState() => SmartFormState();
}

class SmartFormState extends State<SmartForm> {
  late SmartFormController _controller;
  bool _ownsController = false;

  /// The form controller.
  SmartFormController get controller => _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = SmartFormController();
      _ownsController = true;
    }
    _controller.enableHapticFeedback = widget.enableHapticFeedback;
  }

  @override
  void didUpdateWidget(SmartForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = SmartFormController();
        _ownsController = true;
      }
    }
    _controller.enableHapticFeedback = widget.enableHapticFeedback;
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// Validates all fields in the form.
  /// 
  /// Returns true if all fields are valid.
  /// If invalid, focuses and scrolls to the first invalid field.
  bool validate() {
    final isValid = _controller.validate();
    if (isValid) {
      widget.onValid?.call();
    } else {
      widget.onInvalid?.call();
    }
    return isValid;
  }

  /// Clears all validation errors.
  void clearErrors() {
    _controller.clearErrors();
  }

  @override
  Widget build(BuildContext context) {
    return SmartFormScope(
      controller: _controller,
      child: widget.child,
    );
  }
}
