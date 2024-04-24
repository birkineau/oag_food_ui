import 'package:flutter/material.dart';

class ScaleButton extends StatefulWidget {
  const ScaleButton({
    super.key,
    this.onPressed,
    this.duration = const Duration(milliseconds: 300),
    this.beginScale = 1.0,
    this.endScale = .9,
    this.curve = Curves.ease,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;
  final Widget child;

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final CurvedAnimation _curvedAnimation;
  late final Tween<double> _scaleTween;

  TickerFuture? _animationInProgress;
  double _progress = .0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 225),
    )..addListener(
        () {
          _progress = _animationController.value;
        },
      );

    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    );

    _scaleTween = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScaleButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration;
    }

    if (oldWidget.curve != widget.curve) {
      _curvedAnimation.curve = widget.curve;
    }

    if (oldWidget.beginScale != widget.beginScale) {
      _scaleTween.begin = widget.beginScale;
    }

    if (oldWidget.endScale != widget.endScale) {
      _scaleTween.end = widget.endScale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleTween.evaluate(_curvedAnimation),
          child: child,
        );
      },
      child: widget.onPressed != null
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) {
                if (_progress > .675) {
                  return;
                }

                _animationInProgress = _animationController.forward();
              },
              onTapUp: (details) async {
                widget.onPressed?.call();

                await _animationInProgress;

                _animationInProgress = null;
                _animationController.reverse();
              },
              onTapCancel: () {
                _animationController.reverse();
              },
              child: widget.child,
            )
          : widget.child,
    );
  }
}
