import 'package:flutter/material.dart';
import 'smart_controller.dart';
import 'animations/shake_animation.dart';

/// A smart dropdown field that integrates with [SmartForm].
class SmartDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final SmartValidator<T>? validator;
  final bool enabled;
  final InputDecoration? decoration;
  final IconData? prefixIcon;
  final Widget? prefix;
  final double borderRadius;
  final double menuMaxHeight;
  final int elevation;

  const SmartDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.validator,
    this.enabled = true,
    this.decoration,
    this.prefixIcon,
    this.prefix,
    this.borderRadius = 12,
    this.menuMaxHeight = 300,
    this.elevation = 8,
  });

  @override
  State<SmartDropdown<T>> createState() => _SmartDropdownState<T>();
}

class _SmartDropdownState<T> extends State<SmartDropdown<T>> {
  late GlobalKey _fieldKey;
  late FocusNode _focusNode;
  late ValueNotifier<String?> _errorNotifier;
  late ValueNotifier<bool> _shakeNotifier;
  late SmartFieldRegistration<T> _registration;
  SmartFormController? _formController;
  T? _currentValue;
  bool _isFocused = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _fieldKey = GlobalKey();
    _focusNode = FocusNode();
    _errorNotifier = ValueNotifier(null);
    _shakeNotifier = ValueNotifier(false);
    _currentValue = widget.value;
    _updateValidState();

    _focusNode.addListener(_onFocusChanged);

    _registration = SmartFieldRegistration<T>(
      key: _fieldKey,
      focusNode: _focusNode,
      getValue: () => _currentValue,
      validator: widget.validator,
      errorNotifier: _errorNotifier,
      shakeNotifier: _shakeNotifier,
    );
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _updateValidState() {
    final error = widget.validator?.call(_currentValue);
    setState(() {
      _isValid = error == null && _currentValue != null;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formController?.unregisterField(_registration);
    _formController = SmartFormScope.maybeOf(context);
    _formController?.registerField(_registration);
  }

  @override
  void didUpdateWidget(SmartDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value;
    }
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
            child: ValueListenableBuilder<String?>(
              valueListenable: _errorNotifier,
              builder: (context, error, _) {
                return Text(
                  widget.label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: error != null
                        ? theme.colorScheme.error
                        : _isValid
                            ? Colors.green
                            : _isFocused
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                  ),
                );
              },
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
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: error != null
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.error.withValues(alpha: 0.15),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : _isValid
                          ? [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.15),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : _isFocused
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                ),
                child: DropdownButtonFormField<T>(
                  value: _currentValue,
                  items: widget.items,
                  focusNode: _focusNode,
                  isExpanded: true,
                  icon: AnimatedRotation(
                    turns: _isFocused ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: error != null
                          ? theme.colorScheme.error
                          : _isValid
                              ? Colors.green
                              : _isFocused
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  dropdownColor: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  elevation: widget.elevation,
                  menuMaxHeight: widget.menuMaxHeight,
                  padding: EdgeInsets.zero,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  selectedItemBuilder: (context) {
                    return widget.items.map((item) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: DefaultTextStyle(
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          child: item.child,
                        ),
                      );
                    }).toList();
                  },
                  onChanged: widget.enabled
                      ? (value) {
                          setState(() {
                            _currentValue = value;
                          });
                          if (_errorNotifier.value != null) {
                            _errorNotifier.value = null;
                          }
                          _updateValidState();
                          widget.onChanged?.call(value);
                        }
                      : null,
                  decoration: widget.decoration ??
                      InputDecoration(
                        hintText: widget.hint,
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        errorText: error,
                        prefixIcon: widget.prefix ??
                            (widget.prefixIcon != null
                                ? Icon(
                                    widget.prefixIcon,
                                    color: error != null
                                        ? theme.colorScheme.error
                                        : _isValid
                                            ? Colors.green
                                            : _isFocused
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurfaceVariant,
                                  )
                                : null),
                        suffixIcon: _isValid
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          borderSide: BorderSide(
                            color: _isValid ? Colors.green : theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
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
