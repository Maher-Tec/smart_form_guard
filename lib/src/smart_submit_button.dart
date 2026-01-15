import 'package:flutter/material.dart';
import 'smart_form.dart';

/// A submit button that triggers form validation.
/// 
/// Must be used inside a [SmartForm] widget.
class SmartSubmitButton extends StatefulWidget {
  /// The button text.
  final String text;

  /// Optional loading text shown during submission.
  final String? loadingText;

  /// Custom callback when button is pressed.
  /// If provided, this is called after successful validation.
  final VoidCallback? onPressed;

  /// Button background color.
  final Color? backgroundColor;

  /// Button text color.
  final Color? textColor;

  /// Button border radius.
  final double borderRadius;

  /// Button padding.
  final EdgeInsetsGeometry padding;

  /// Whether the button is enabled.
  final bool enabled;

  /// Custom button style.
  final ButtonStyle? style;

  /// Optional icon to display before text.
  final IconData? icon;

  /// Whether to show loading indicator during validation.
  final bool showLoading;

  const SmartSubmitButton({
    super.key,
    required this.text,
    this.loadingText,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.enabled = true,
    this.style,
    this.icon,
    this.showLoading = true,
  });

  @override
  State<SmartSubmitButton> createState() => _SmartSubmitButtonState();
}

class _SmartSubmitButtonState extends State<SmartSubmitButton> {
  bool _isLoading = false;

  Future<void> _onPressed() async {
    final formState = context.findAncestorStateOfType<SmartFormState>();
    if (formState == null) {
      debugPrint('SmartSubmitButton: No SmartForm ancestor found!');
      return;
    }

    if (_isLoading) return;

    if (widget.showLoading) {
      setState(() => _isLoading = true);
    }

    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 50));

    final isValid = formState.validate();

    if (widget.showLoading) {
      setState(() => _isLoading = false);
    }

    if (isValid) {
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final effectiveBackgroundColor = widget.backgroundColor ?? 
        theme.colorScheme.primary;
    final effectiveTextColor = widget.textColor ?? 
        theme.colorScheme.onPrimary;

    final buttonStyle = widget.style ??
        ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          padding: widget.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          elevation: 0,
        );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.enabled && !_isLoading ? _onPressed : null,
        style: buttonStyle,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveTextColor,
                        ),
                      ),
                    ),
                    if (widget.loadingText != null) ...[
                      const SizedBox(width: 12),
                      Text(widget.loadingText!),
                    ],
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
