import 'package:flutter/material.dart';
import 'smart_controller.dart';
import 'smart_validators.dart';
import 'animations/shake_animation.dart';

/// A smart form field that integrates with [SmartForm].
/// 
/// Use the factory constructors for common field types:
/// - [SmartField.email] - Email input with validation
/// - [SmartField.password] - Password input with visibility toggle
/// - [SmartField.required] - Required text field
/// - [SmartField.phone] - Phone number input
class SmartField extends StatefulWidget {
  /// The text controller for this field.
  final TextEditingController controller;

  /// The label displayed above the field.
  final String? label;

  /// The hint text displayed when the field is empty.
  final String? hint;

  /// The validator function for this field.
  final SmartValidator<String>? validator;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// The autovalidate mode for this field.
  final AutovalidateMode? autovalidateMode;

  /// The keyboard type for this field.
  final TextInputType? keyboardType;

  /// The text input action for this field.
  final TextInputAction? textInputAction;

  /// Prefix icon for the field.
  final IconData? prefixIcon;

  /// Whether to show a visibility toggle for password fields.
  final bool showPasswordToggle;

  /// Callback when the field value changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the user submits the field.
  final VoidCallback? onSubmitted;

  /// Enable or disable the field.
  final bool enabled;

  /// Optional decoration override.
  final InputDecoration? decoration;

  const SmartField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.showPasswordToggle = false,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.decoration,
    this.autovalidateMode,
  });

  /// Creates an email field with email validation.
  factory SmartField.email({
    Key? key,
    required TextEditingController controller,
    String label = 'Email',
    String? hint,
    bool required = true,
    String? requiredMessage,
    String? invalidMessage,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmitted,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
  }) {
    return SmartField(
      key: key,
      controller: controller,
      label: label,
      hint: hint ?? 'Enter your email',
      validator: SmartValidators.compose<String>([
        if (required) SmartValidators.required(requiredMessage),
        SmartValidators.email(invalidMessage),
      ]),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.email_outlined,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
    );
  }

  /// Creates a password field with validation and visibility toggle.
  factory SmartField.password({
    Key? key,
    required TextEditingController controller,
    String label = 'Password',
    String? hint,
    bool required = true,
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecialChar = false,
    String? requiredMessage,
    String? invalidMessage,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmitted,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
  }) {
    return SmartField(
      key: key,
      controller: controller,
      label: label,
      hint: hint ?? 'Enter your password',
      validator: SmartValidators.compose<String>([
        if (required) SmartValidators.required(requiredMessage),
        SmartValidators.password(
          minLength: minLength,
          requireUppercase: requireUppercase,
          requireLowercase: requireLowercase,
          requireDigit: requireDigit,
          requireSpecialChar: requireSpecialChar,
          message: invalidMessage,
        ),
      ]),
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      prefixIcon: Icons.lock_outlined,
      showPasswordToggle: true,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
    );
  }

  /// Creates a required text field.
  factory SmartField.required({
    Key? key,
    required TextEditingController controller,
    required String label,
    String? hint,
    String? message,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    IconData? prefixIcon,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmitted,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
  }) {
    return SmartField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      validator: SmartValidators.required(message),
      keyboardType: keyboardType,
      textInputAction: textInputAction ?? TextInputAction.next,
      prefixIcon: prefixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
    );
  }

  /// Creates a phone number field with validation.
  factory SmartField.phone({
    Key? key,
    required TextEditingController controller,
    String label = 'Phone',
    String? hint,
    bool required = true,
    String? requiredMessage,
    String? invalidMessage,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmitted,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
  }) {
    return SmartField(
      key: key,
      controller: controller,
      label: label,
      hint: hint ?? 'Enter your phone number',
      validator: SmartValidators.compose<String>([
        if (required) SmartValidators.required(requiredMessage),
        SmartValidators.phone(invalidMessage),
      ]),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.phone_outlined,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
    );
  }

  @override
  State<SmartField> createState() => _SmartFieldState();
}

class _SmartFieldState extends State<SmartField> {
  late GlobalKey _fieldKey;
  late FocusNode _focusNode;
  late ValueNotifier<String?> _errorNotifier;
  late ValueNotifier<bool> _shakeNotifier;
  late SmartFieldRegistration _registration;
  SmartFormController? _formController;
  bool _obscureText = false;
  bool _isFocused = false;
  bool _isValid = false;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _fieldKey = GlobalKey();
    _focusNode = FocusNode();
    _errorNotifier = ValueNotifier(null);
    _shakeNotifier = ValueNotifier(false);
    _obscureText = widget.obscureText;

    _focusNode.addListener(_onFocusChanged);

    _registration = SmartFieldRegistration<String>(
      key: _fieldKey,
      focusNode: _focusNode,
      getValue: () => widget.controller.text,
      validator: widget.validator,
      errorNotifier: _errorNotifier,
      shakeNotifier: _shakeNotifier,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Unregister from old controller if switching
    _formController?.unregisterField(_registration);
    
    // Register with new controller
    _formController = SmartFormScope.maybeOf(context);
    _formController?.registerField(_registration);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    // Validate on focus loss to show valid state
    if (!_focusNode.hasFocus && _hasInteracted) {
      _updateValidState();
    }
  }

  void _updateValidState() {
    final error = widget.validator?.call(widget.controller.text);
    setState(() {
      _isValid = error == null && widget.controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _formController?.unregisterField(_registration);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _errorNotifier.dispose();
    _shakeNotifier.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      key: _fieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: _errorNotifier.value != null
                    ? theme.colorScheme.error
                    : _isValid
                        ? Colors.green
                        : _isFocused
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ShakeAnimation(
          trigger: _shakeNotifier,
          child: ValueListenableBuilder<String?>(
            valueListenable: _errorNotifier,
            builder: (context, error, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: error != null
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.error.withValues(alpha: 0.15),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : _isValid && _isFocused
                          ? [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.15),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: _obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  enabled: widget.enabled,
                  onChanged: (value) {
                    _hasInteracted = true;
                    // Clear error on change if not in autovalidate mode
                    if (widget.autovalidateMode != AutovalidateMode.always && 
                        widget.autovalidateMode != AutovalidateMode.onUserInteraction) {
                      if (_errorNotifier.value != null) {
                        _errorNotifier.value = null;
                      }
                    } else {
                      _errorNotifier.value = widget.validator?.call(value);
                    }
                    _updateValidState();
                    widget.onChanged?.call(value);
                  },
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  decoration: widget.decoration ??
                      InputDecoration(
                        hintText: widget.hint,
                        errorText: error,
                        prefixIcon: widget.prefixIcon != null
                            ? Icon(
                                widget.prefixIcon,
                                color: error != null
                                    ? theme.colorScheme.error
                                    : _isValid
                                        ? Colors.green
                                        : _isFocused
                                            ? theme.colorScheme.primary
                                            : null,
                              )
                            : null,
                        suffixIcon: widget.showPasswordToggle
                            ? IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: _isValid ? Colors.green : null,
                                ),
                                onPressed: _togglePasswordVisibility,
                              )
                            : _isValid
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _isValid ? Colors.green : theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 2,
                          ),
                        ),
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
