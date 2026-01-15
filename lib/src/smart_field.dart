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
  final SmartValidator? validator;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

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
  }) {
    return SmartField(
      key: key,
      controller: controller,
      label: label,
      hint: hint ?? 'Enter your email',
      validator: SmartValidators.compose([
        if (required) SmartValidators.required(requiredMessage),
        SmartValidators.email(invalidMessage),
      ]),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.email_outlined,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
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
  }) {
    return SmartField(
      key: key,
      controller: controller,
      label: label,
      hint: hint ?? 'Enter your password',
      validator: SmartValidators.compose([
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
  }) {
    return SmartField(
      key: key,
      controller: controller,
      label: label,
      hint: hint ?? 'Enter your phone number',
      validator: SmartValidators.compose([
        if (required) SmartValidators.required(requiredMessage),
        SmartValidators.phone(invalidMessage),
      ]),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.phone_outlined,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
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

  @override
  void initState() {
    super.initState();
    _fieldKey = GlobalKey();
    _focusNode = FocusNode();
    _errorNotifier = ValueNotifier(null);
    _shakeNotifier = ValueNotifier(false);
    _obscureText = widget.obscureText;

    _focusNode.addListener(_onFocusChanged);

    _registration = SmartFieldRegistration(
      key: _fieldKey,
      focusNode: _focusNode,
      controller: widget.controller,
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
    // Note: Errors are cleared in onChanged when user starts typing,
    // NOT here on focus gain - otherwise validation errors disappear immediately
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
                color: _isFocused
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
                    // Clear error on change
                    if (_errorNotifier.value != null) {
                      _errorNotifier.value = null;
                    }
                    widget.onChanged?.call(value);
                  },
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  decoration: widget.decoration ??
                      InputDecoration(
                        hintText: widget.hint,
                        errorText: error,
                        prefixIcon: widget.prefixIcon != null
                            ? Icon(widget.prefixIcon)
                            : null,
                        suffixIcon: widget.showPasswordToggle
                            ? IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: _togglePasswordVisibility,
                              )
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
                            color: theme.colorScheme.primary,
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
