import 'package:flutter/material.dart';
import 'smart_controller.dart';
import 'animations/shake_animation.dart';

/// A smart checkbox that integrates with [SmartForm].
class SmartCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget? title;
  final SmartValidator<bool>? validator;
  final bool enabled;

  const SmartCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.validator,
    this.enabled = true,
  });

  @override
  State<SmartCheckbox> createState() => _SmartCheckboxState();
}

class _SmartCheckboxState extends State<SmartCheckbox> {
  late GlobalKey _fieldKey;
  late FocusNode _focusNode;
  late ValueNotifier<String?> _errorNotifier;
  late ValueNotifier<bool> _shakeNotifier;
  late ValueNotifier<bool> _loadingNotifier;
  late SmartFieldRegistration<bool> _registration;
  SmartFormController? _formController;
  bool _isValid = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _fieldKey = GlobalKey();
    _focusNode = FocusNode(canRequestFocus: true);
    _errorNotifier = ValueNotifier(null);
    _shakeNotifier = ValueNotifier(false);
    _loadingNotifier = ValueNotifier(false);
    _updateValidState();

    _focusNode.addListener(_onFocusChanged);

    _registration = SmartFieldRegistration<bool>(
      key: _fieldKey,
      focusNode: _focusNode,
      getValue: () => widget.value,
      validator: widget.validator,
      errorNotifier: _errorNotifier,
      shakeNotifier: _shakeNotifier,
      loadingNotifier: _loadingNotifier,
    );
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
    _errorNotifier.dispose();
    _shakeNotifier.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _updateValidState() {
    final error = widget.validator?.call(widget.value);
    setState(() {
      _isValid = error == null && widget.value == true; // Only valid if checked? Or just no error? smart_checkbox implies typically true is required if validated
      // Actually standard validator might just check true.
      // If no validator, is it valid?
      // Let's assume if validator passes, it is valid. 
      // But usually checkbox is valid if checked for "Terms".
      // If widget.value is false, usually invalid for terms.
      // Let's rely on validator result.
      _isValid = error == null;
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
        ShakeAnimation(
          trigger: _shakeNotifier,
          child: ValueListenableBuilder<String?>(
            valueListenable: _errorNotifier,
            builder: (context, error, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface, // Match text field fill
                  border: Border.all(
                    color: error != null 
                        ? theme.colorScheme.error 
                        : _isValid 
                            ? Colors.green 
                            : _isFocused 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.outline.withValues(alpha: 0.5),
                     width: (_isValid || _isFocused || error != null) ? 2 : 1,
                  ),
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
                child: Theme(
                  data: theme.copyWith(
                    unselectedWidgetColor: error != null 
                        ? theme.colorScheme.error 
                        : theme.unselectedWidgetColor,
                  ),
                  child: CheckboxListTile(
                    value: widget.value,
                    onChanged: widget.enabled
                        ? (val) {
                            if (_errorNotifier.value != null) {
                              _errorNotifier.value = null;
                            }
                            widget.onChanged(val);
                            // Need to defer validation state update slightly or call it with new value
                            // Since widget.value isn't updated yet in this callbacks (parent updates it).
                            // But we can't await here easily.
                            // The parent setState will trigger build, which triggers... wait.
                            // _updateValidState uses widget.value.
                            // We need check validity against new value 'val'.
                             final error = widget.validator?.call(val);
                             setState(() => _isValid = error == null);
                          }
                        : null,
                    title: widget.title,
                    subtitle: error != null
                        ? Text(
                            error,
                            style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                          )
                        : null,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    activeColor: _isValid ? Colors.green : theme.colorScheme.primary,
                    side: error != null 
                        ? BorderSide(color: theme.colorScheme.error, width: 2)
                        : null,
                    enabled: widget.enabled,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
