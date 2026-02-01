import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'smart_controller.dart';
import 'animations/shake_animation.dart';

/// One option within a [SmartRadioGroup].
class SmartRadioOption<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;

  const SmartRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });
}

/// A generic radio group widget that integrates with [SmartForm].
///
/// Supports validation, generic types, and custom layouts.
class SmartRadioGroup<T> extends StatefulWidget {
  final SmartFormController? controller;
  final T? initialValue;
  final List<SmartRadioOption<T>> options;
  final SmartValidator<T>? validator;
  final SmartAsyncValidator<T>? asyncValidator;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final bool mandatory;
  final EdgeInsetsGeometry padding;
  final Axis direction;
  final double spacing;
  final Color? activeColor;

  const SmartRadioGroup({
    super.key,
    this.controller,
    this.initialValue,
    required this.options,
    this.validator,
    this.asyncValidator,
    this.onChanged,
    this.label,
    this.mandatory = false,
    this.padding = EdgeInsets.zero,
    this.direction = Axis.vertical,
    this.spacing = 8.0,
    this.activeColor,
  });

  @override
  State<SmartRadioGroup<T>> createState() => _SmartRadioGroupState<T>();
}

class _SmartRadioGroupState<T> extends State<SmartRadioGroup<T>> {
  late final SmartFormController? _formController;
  final GlobalKey _fieldKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<String?> _errorNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _shakeNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  late SmartFieldRegistration<T> _registration;
  bool _isValid = false;

  T? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _formController = widget.controller;
    _updateValidState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Register with controller if available (either passed or inherited)
    final controller = _formController ?? SmartFormScope.maybeOf(context);
    if (controller != null) {
      _registration = SmartFieldRegistration<T>(
        key: _fieldKey,
        focusNode: _focusNode,
        getValue: () => _currentValue,
        validator: widget.validator,
        asyncValidator: widget.asyncValidator,
        errorNotifier: _errorNotifier,
        shakeNotifier: _shakeNotifier,
        loadingNotifier: _loadingNotifier,
      );
      controller.registerField(_registration);
    }
  }

  @override
  void dispose() {
    final controller = _formController ?? SmartFormScope.maybeOf(context);
    if (controller != null) {
      controller.unregisterField(_registration);
    }
    _focusNode.dispose();
    _errorNotifier.dispose();
    _shakeNotifier.dispose();
    _loadingNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SmartRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _formController = widget.controller;
    }
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _currentValue) {
       _currentValue = widget.initialValue;
    }
  }

  void _handleChanged(T? value) {
    setState(() {
      _currentValue = value;
    });
    // Clear error immediately on change
    if (_errorNotifier.value != null) {
       _errorNotifier.value = null;
    }
    _updateValidState();
    widget.onChanged?.call(value);
  }

  void _updateValidState() {
    final error = widget.validator?.call(_currentValue);
    setState(() {
      _isValid = error == null && _currentValue != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShakeAnimation(
      trigger: _shakeNotifier,
      child: ValueListenableBuilder<String?>(
        valueListenable: _errorNotifier,
        builder: (context, error, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.label != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                  child: Row(
                    children: [
                      Text(
                        widget.label!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: error != null 
                              ? Theme.of(context).colorScheme.error 
                              : null,
                        ),
                      ),
                      if (widget.mandatory)
                        Text(
                          ' *',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      // Loading Indicator
                      ValueListenableBuilder<bool>(
                        valueListenable: _loadingNotifier,
                        builder: (context, isLoading, _) {
                          if (!isLoading) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
              InputDecorator(
                key: _fieldKey,
                decoration: InputDecoration(
                  contentPadding: widget.padding,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                ),
                child: widget.direction == Axis.vertical
                    ? Column(
                        children: widget.options.map(_buildOption).toList(),
                      )
                    : Row(
                        children: widget.options
                            .map((e) => Expanded(child: _buildOption(e)))
                            .toList(),
                      ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOption(SmartRadioOption<T> option) {
    final isSelected = _currentValue == option.value;
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    // Determine colors based on state
    Color borderColor;
    Color glowColor;
    
    if (_errorNotifier.value != null) {
      // Error State
      if (isSelected) {
        borderColor = theme.colorScheme.error;
        glowColor = theme.colorScheme.error;
      } else {
        // Unselected items in error state show softer red border
        borderColor = theme.colorScheme.error.withValues(alpha: 0.8);
        glowColor = Colors.transparent;
      }
    } else {
      // No Error
      if (isSelected) {
        if (_isValid) {
          borderColor = Colors.green;
          glowColor = Colors.green;
        } else {
          borderColor = activeColor;
          glowColor = activeColor;
        }
      } else {
        // Unselected, No Error
        borderColor = theme.dividerColor.withOpacity(0.5);
        glowColor = Colors.transparent;
      }
    }

    return GestureDetector(
      onTap: () => _handleChanged(option.value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: widget.direction == Axis.vertical
            ? EdgeInsets.only(bottom: widget.spacing)
            : EdgeInsets.only(right: widget.spacing),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? borderColor.withOpacity(0.05) : theme.cardColor,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             if (isSelected)
              BoxShadow(
                color: glowColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Always show Radio Button Visual
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  // Use borderColor so it matches error red if valid
                   color: borderColor == theme.dividerColor.withOpacity(0.5) 
                      ? theme.disabledColor 
                      : borderColor,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Show icon if present
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 24,
                color: isSelected ? activeColor : theme.iconTheme.color?.withOpacity(0.6),
              ),
              const SizedBox(width: 12),
            ],
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    option.label,
                    style: TextStyle(
                      color: onSurface, // Always use onSurface for visibility
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  if (option.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      option.description!,
                       style: TextStyle(
                        color: onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
