import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../list_child_model/child_list_render_object_widget.dart';
import '../list_child_model/list_parent_data_mixin.dart';
import '../list_child_model/list_render_object_mixin.dart';
import '../ui_design/cpaint_parent_data.dart';

class CPaint extends ChildListRenderObjectWidget {
  const CPaint({
    super.key,
    required this.vsync,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.linear,
    this.clipBehavior = Clip.antiAlias,
    required super.children,
  });

  final TickerProvider vsync;

  /// The animation duration.
  final Duration duration;

  /// The animation curve.
  final Curve curve;

  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderCPaint(
        vsync: vsync,
        duration: duration,
        curve: curve,
        clipBehavior: clipBehavior,
      );

  @override
  void updateRenderObject(BuildContext context, RenderCPaint renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..duration = duration
      ..curve = curve
      ..clipBehavior = clipBehavior;
  }
}

class RenderCPaint extends RenderBox
    with
        ListRenderObjectMixin<RenderBox, ListBoxParentData<RenderBox>>,
        RenderBoxListDefaultsMixin<RenderBox, ListBoxParentData<RenderBox>> {
  RenderCPaint({
    required TickerProvider vsync,
    required Duration duration,
    required Curve curve,
    required Clip clipBehavior,
  })  : _curve = curve,
        _clipBehavior = clipBehavior,
        durationMs = duration.inMilliseconds {
    _animationController = AnimationController(vsync: vsync)
      ..addListener(_updateAnimationValue);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _animationValue = -1.0;
  late final AnimationController _animationController;

  set vsync(TickerProvider value) {
    _animationController.resync(value);
  }

  int durationMs;
  set duration(Duration value) {
    if (value.inMilliseconds == durationMs) return;
    durationMs = value.inMilliseconds;
  }

  Curve _curve;
  set curve(Curve value) {
    if (_curve == value) return;
    _curve = value;
  }

  Clip _clipBehavior;
  set clipBehavior(Clip value) {
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
  }

  Future<void> animate() {
    return _animationController.forward(from: .0);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is CPaintParentData) return;
    child.parentData = CPaintParentData();
  }

  void createChildrenAnimationIntervals() {
    const staggerDelayMs = 24;

    /// Calculate the new total duration considering the stagger delay.
    final totalDurationMs =
        durationMs + ((children.length - 1) * staggerDelayMs);

    _animationController.duration = Duration(milliseconds: totalDurationMs);

    for (var i = 0; i < children.length; ++i) {
      final child = children[i];
      final childParentData = child.parentData as CPaintParentData;

      /// Calculate each child's animation start and end points with reduced
      /// delay.
      final begin = (staggerDelayMs * i) / totalDurationMs.toDouble();
      final end =
          (durationMs + (staggerDelayMs * i)) / totalDurationMs.toDouble();

      childParentData.tween = MaterialPointArcTween(
        begin: Offset(
          childParentData.offset.dx,
          childParentData.offset.dy + 56.0,
        ),
        end: childParentData.offset,
      );

      childParentData.curve = CurvedAnimation(
        parent: _animationController,
        curve: Interval(begin, end, curve: _curve),
      );
    }
  }

  @override
  void performLayout() {
    for (var i = 0; i < children.length; ++i) {
      final child = children[i];
      final childParentData = child.parentData as CPaintParentData;
      final diameter = childParentData.circle.radius * 2.0;

      /// The child's offset is the center of the circle minus its radius; this
      /// corresponds to the top left corner of the child's bounding box.
      childParentData.offset = Offset(
        childParentData.circle.center.dx - childParentData.circle.radius,
        childParentData.circle.center.dy - childParentData.circle.radius,
      );

      /// The child's size is the diameter of the circle; this corrsponds to the
      /// child's bounding box.
      child.layout(BoxConstraints.tightFor(width: diameter, height: diameter));
    }

    createChildrenAnimationIntervals();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (var i = 0; i < children.length; ++i) {
      final child = children[i];
      final childParentData = child.parentData as CPaintParentData;
      final animationOffset = childParentData.tween!.evaluate(
        childParentData.curve!,
      );

      context.pushOpacity(
        offset,
        (childParentData.curve!.value * 255).toInt(),
        (context, offset) {
          context.paintChild(
            child,
            animationOffset + offset,
          );
        },
      );
    }
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animationController.addListener(_updateAnimationValue);
  }

  @override
  void detach() {
    _animationController.removeListener(_updateAnimationValue);
    super.detach();
  }

  /// Updates [_animationValue] and calls [markNeedsLayout] if [_animationValue]
  /// has changed since the method was last called.
  void _updateAnimationValue() {
    if (_animationValue == _animationController.value) return;
    _animationValue = _animationController.value;
    markNeedsPaint();
  }
}
