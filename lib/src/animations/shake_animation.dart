import 'package:flutter/widgets.dart';

/// A widget that applies a horizontal shake animation.
/// 
/// Triggered when [ShakeController.shake] is called or when
/// the [trigger] ValueNotifier becomes true.
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final ValueNotifier<bool>? trigger;
  final Duration duration;
  final double intensity;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.trigger,
    this.duration = const Duration(milliseconds: 150),
    this.intensity = 8.0,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Shake pattern: right -> left -> right -> center
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: -1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
    ]).animate(_controller);

    widget.trigger?.addListener(_onTriggerChanged);
  }

  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      oldWidget.trigger?.removeListener(_onTriggerChanged);
      widget.trigger?.addListener(_onTriggerChanged);
    }
  }

  void _onTriggerChanged() {
    if (widget.trigger?.value == true) {
      shake();
      // Reset the trigger
      Future.microtask(() => widget.trigger?.value = false);
    }
  }

  /// Triggers the shake animation.
  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    widget.trigger?.removeListener(_onTriggerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * widget.intensity, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
