/// A smart Flutter form wrapper that validates fields, auto-focuses & scrolls
/// to the first invalid field, and provides pleasant visual feedback.
///
/// ## Usage
///
/// ```dart
/// SmartForm(
///   onValid: () => print("Form is valid 🎉"),
///   child: Column(
///     children: [
///       SmartField.email(controller: emailCtrl, label: "Email"),
///       SmartField.password(controller: passCtrl, label: "Password"),
///       SmartSubmitButton(text: "Create account"),
///     ],
///   ),
/// );
/// ```
library;

export 'src/smart_form.dart';
export 'src/smart_field.dart';
export 'src/smart_submit_button.dart';
export 'src/smart_validators.dart';
export 'src/smart_controller.dart' 
    show SmartFormController, SmartFormScope;
export 'src/animations/shake_animation.dart';
