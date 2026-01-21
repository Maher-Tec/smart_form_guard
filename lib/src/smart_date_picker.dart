import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'smart_controller.dart';
import 'animations/shake_animation.dart';

/// A smart date picker field that integrates with [SmartForm].
class SmartDatePicker extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? label;
  final String? hint;
  final SmartValidator<DateTime>? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final InputDecoration? decoration;
  final DateFormat? dateFormat;

  const SmartDatePicker({
    super.key,
    this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.decoration,
    this.dateFormat,
  });

  @override
  State<SmartDatePicker> createState() => _SmartDatePickerState();
}

class _SmartDatePickerState extends State<SmartDatePicker> {
  late GlobalKey _fieldKey;
  late FocusNode _focusNode;
  late ValueNotifier<String?> _errorNotifier;
  late ValueNotifier<bool> _shakeNotifier;
  late SmartFieldRegistration<DateTime> _registration;
  SmartFormController? _formController;
  final _textController = TextEditingController();
  bool _isFocused = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _fieldKey = GlobalKey();
    _focusNode = FocusNode();
    _errorNotifier = ValueNotifier(null);
    _shakeNotifier = ValueNotifier(false);
    _updateText();
    _updateValidState();

    _focusNode.addListener(_onFocusChanged);

    _registration = SmartFieldRegistration<DateTime>(
      key: _fieldKey,
      focusNode: _focusNode,
      getValue: () => widget.value,
      validator: widget.validator,
      errorNotifier: _errorNotifier,
      shakeNotifier: _shakeNotifier,
    );
  }

  void _updateText() {
    if (widget.value != null) {
      final formatter = widget.dateFormat ?? DateFormat.yMMMd();
      _textController.text = formatter.format(widget.value!);
    } else {
      _textController.text = '';
    }
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _updateValidState() {
    final error = widget.validator?.call(widget.value);
    setState(() {
      _isValid = error == null && widget.value != null;
    });
  }

  @override
  void didUpdateWidget(SmartDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateText();
      _updateValidState();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formController?.unregisterField(_registration);
    _formController = SmartFormScope.maybeOf(context);
    _formController?.registerField(_registration);
  }

  @override
  void dispose() {
    _formController?.unregisterField(_registration);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _textController.dispose();
    _errorNotifier.dispose();
    _shakeNotifier.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    if (!widget.enabled) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (picked != null) {
      if (_errorNotifier.value != null) {
        _errorNotifier.value = null;
      }
      widget.onChanged(picked);
    }
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
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  readOnly: true,
                  enabled: widget.enabled,
                  onTap: _selectDate,
                  decoration: widget.decoration ??
                      InputDecoration(
                        hintText: widget.hint ?? 'Select date',
                        errorText: error,
                        prefixIcon: Icon(
                          Icons.calendar_today_outlined,
                          color: error != null
                              ? theme.colorScheme.error
                              : _isValid
                                  ? Colors.green
                                  : _isFocused
                                      ? theme.colorScheme.primary
                                      : null,
                        ),
                        suffixIcon: _isValid
                            ? const Icon(Icons.check_circle, color: Colors.green)
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
