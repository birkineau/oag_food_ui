import 'package:flutter/material.dart';

part 'animated_offset_switcher_settings.dart';

class AnimatedOffsetSwitcher extends StatefulWidget {
  const AnimatedOffsetSwitcher({
    super.key,
    this.settings = const AnimatedOffsetSwitcherSettings.topToBottom(),
    required this.itemCount,
    required this.itemBuilder,
  });

  final AnimatedOffsetSwitcherSettings settings;

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  State<AnimatedOffsetSwitcher> createState() => AnimatedOffsetSwitcherState();
}

class AnimatedOffsetSwitcherState extends State<AnimatedOffsetSwitcher>
    with SingleTickerProviderStateMixin {
  static const _midpointEpsilon = .01;

  late final AnimationController _animationController;
  late TweenSequence<Offset> _offsetTween;
  late TweenSequence<double> _opacityTween;

  bool get showing => !_animationController.isAnimating && _stoppedAtMidpoint;

  Future<void> show() async {
    assert(
      widget.settings.manual,
      "The show method should only be called in manual mode.",
    );

    if (_animationController.isAnimating || _stoppedAtMidpoint) {
      return;
    }

    await _animationController.forward(from: .0);

    if (widget.settings.middleDuration != Duration.zero) {
      return Future.delayed(
        widget.settings.middleDuration,
        () {
          if (mounted) {
            hide();
          }
        },
      );
    }
  }

  Future<void> hide({bool advance = true}) async {
    assert(
      widget.settings.manual,
      "The hide method should only be called in manual mode.",
    );

    if (_animationController.isAnimating || !_stoppedAtMidpoint) {
      return;
    }

    /// The stop condition is true when the animation controller's value is at
    /// a point close to .5 (the midpoint) to avoid floating point precision
    /// issues.
    ///
    /// Since the condition is exclusive, we can use the midpoint epsilon to
    /// continue the animation from the midpoint.
    return _animationController.forward(from: .5 + _midpointEpsilon).then(
      (_) {
        if (mounted && advance) {
          setState(_nextIndex);
        }
      },
    );
  }

  int _index = 0;
  bool _stoppedAtMidpoint = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: _calculateTotalDuration(),
    );

    _createAnimation();
    _createAnimationListener();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedOffsetSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings.manual != widget.settings.manual) {
      _createAnimationListener();
    }

    if (oldWidget.settings.beginDuration != widget.settings.beginDuration ||
        oldWidget.settings.middleDuration != widget.settings.middleDuration ||
        oldWidget.settings.endDuration != widget.settings.endDuration ||
        oldWidget.settings.beginCurve != widget.settings.beginCurve ||
        oldWidget.settings.endCurve != widget.settings.endCurve ||
        oldWidget.settings.beginOffset != widget.settings.beginOffset ||
        oldWidget.settings.middleOffset != widget.settings.middleOffset ||
        oldWidget.settings.endOffset != widget.settings.endOffset) {
      _animationController.duration = _calculateTotalDuration();
      _createAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: _offsetTween.evaluate(_animationController),
          child: Opacity(
            opacity: _opacityTween.evaluate(_animationController),
            child: child,
          ),
        );
      },
      child: widget.itemBuilder(context, _index),
    );
  }

  void _stopAtMidpointIfBelowMidpoint() {
    _stoppedAtMidpoint =
        (_animationController.value - .5).abs() < _midpointEpsilon;

    if (_stoppedAtMidpoint) {
      _animationController.stop(canceled: false);
    }
  }

  Future<void> _advanceIndexAndRestartAnimation(AnimationStatus status) async {
    if (status != AnimationStatus.completed) {
      return;
    }

    setState(_nextIndex);

    return _animationController.forward(from: .0);
  }

  void _nextIndex() {
    _index = (_index + 1) % widget.itemCount;
  }

  Duration _calculateTotalDuration() {
    assert(
      widget.settings.beginDuration.inMilliseconds > 0,
      "The duration of the begin phase must be greater than 0 in milliseconds.",
    );

    assert(
      widget.settings.endDuration.inMilliseconds > 0,
      "The duration of the end phase must be greater than 0 in milliseconds.",
    );

    /// The middle duration only takes effect when the manual mode is disabled.
    final middleDurationMs = widget.settings.manual
        ? 0
        : widget.settings.middleDuration.inMilliseconds;

    return Duration(
      milliseconds: widget.settings.beginDuration.inMilliseconds +
          middleDurationMs +
          widget.settings.endDuration.inMilliseconds,
    );
  }

  /// Must be called after setting the duration of the animation controller.
  void _createAnimation() {
    final totalDurationMs = _animationController.duration!.inMilliseconds;

    final beginWeight =
        widget.settings.beginDuration.inMilliseconds / totalDurationMs;

    final middleWeight =
        widget.settings.middleDuration.inMilliseconds / totalDurationMs;

    final endWeight =
        widget.settings.endDuration.inMilliseconds / totalDurationMs;

    final beginCurve = CurveTween(curve: widget.settings.beginCurve);
    final endCurve = CurveTween(
      curve: widget.settings.endCurve ?? widget.settings.beginCurve,
    );

    final hasMiddleWeight = !widget.settings.manual && middleWeight > .0;

    _offsetTween = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween(
            begin: widget.settings.beginOffset,
            end: widget.settings.middleOffset,
          ).chain(beginCurve),
          weight: beginWeight,
        ),
        if (hasMiddleWeight)
          TweenSequenceItem(
            tween: ConstantTween(widget.settings.middleOffset),
            weight: middleWeight,
          ),
        TweenSequenceItem(
          tween: Tween(
            begin: widget.settings.middleOffset,
            end: widget.settings.endOffset,
          ).chain(endCurve),
          weight: endWeight,
        ),
      ],
    );

    _opacityTween = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween(begin: .0, end: 1.0).chain(beginCurve),
          weight: beginWeight,
        ),
        if (hasMiddleWeight)
          TweenSequenceItem(
            tween: ConstantTween(1.0),
            weight: middleWeight,
          ),
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: .0).chain(endCurve),
          weight: endWeight,
        ),
      ],
    );
  }

  void _createAnimationListener() {
    if (widget.settings.manual) {
      _animationController
        ..removeStatusListener(_advanceIndexAndRestartAnimation)
        ..addListener(_stopAtMidpointIfBelowMidpoint);
    } else {
      _animationController
        ..removeListener(_stopAtMidpointIfBelowMidpoint)
        ..addStatusListener(_advanceIndexAndRestartAnimation)
        ..forward();
    }
  }
}
