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
  late SmartFieldRegistration<bool> _registration;
  SmartFormController? _formController;

  @override
  void initState() {
    super.initState();
    _fieldKey = GlobalKey();
    _focusNode = FocusNode(canRequestFocus: true);
    _errorNotifier = ValueNotifier(null);
    _shakeNotifier = ValueNotifier(false);

    _registration = SmartFieldRegistration<bool>(
      key: _fieldKey,
      focusNode: _focusNode,
      getValue: () => widget.value,
      validator: widget.validator,
      errorNotifier: _errorNotifier,
      shakeNotifier: _shakeNotifier,
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
        ShakeAnimation(
          trigger: _shakeNotifier,
          child: ValueListenableBuilder<String?>(
            valueListenable: _errorNotifier,
            builder: (context, error, child) {
              return Theme(
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
                  contentPadding: EdgeInsets.zero,
                  activeColor: theme.colorScheme.primary,
                  enabled: widget.enabled,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
