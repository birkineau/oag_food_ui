import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'list_parent_data_mixin.dart';

mixin ListRenderObjectMixin<ChildType extends RenderObject,
    ParentDataType extends ListBoxParentData<ChildType>> on RenderObject {
  /// The list of children.
  final List<ChildType> children = [];

  /// The number of children.
  int get childCount => children.length;

  /// Checks whether the given render object has the correct [runtimeType] to be
  /// a child of this render object.
  ///
  /// Does nothing if assertions are disabled.
  ///
  /// Always returns true.
  bool debugValidateChild(RenderObject child) {
    assert(() {
      if (child is! ChildType) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'A $runtimeType expected a child of type $ChildType but received a '
            'child of type ${child.runtimeType}.',
          ),
          ErrorDescription(
            'RenderObjects expect specific types of children because they '
            'coordinate with their children during layout and paint. For '
            'example, a RenderSliver cannot be the child of a RenderBox because '
            'a RenderSliver does not understand the RenderBox layout protocol.',
          ),
          ErrorSpacer(),
          DiagnosticsProperty<Object?>(
            'The $runtimeType that expected a $ChildType child was created by',
            debugCreator,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
          ErrorSpacer(),
          DiagnosticsProperty<Object?>(
            'The ${child.runtimeType} that did not match the expected child type '
            'was created by',
            child.debugCreator,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
        ]);
      }
      return true;
    }());
    return true;
  }

  /// Append child to the end of this render object's child list.
  void add(ChildType child) {
    assert(child != this, 'A RenderObject cannot be inserted into itself.');
    assert(!children.contains(child), "Inserting duplicate child.");
    adoptChild(child);
    children.add(child);
  }

  /// Add all the children to the end of this render object's child list.
  void addAll(List<ChildType>? children) => children?.forEach(add);

  /// Remove this child from the child list.
  ///
  /// Requires the child to be present in the child list.
  void remove(ChildType child) {
    final childIndex = children.indexOf(child);

    assert(
      childIndex != -1,
      "Attempted to remove a child that wasn't present.",
    );

    children.removeAt(childIndex);
    dropChild(child);
  }

  /// Remove all their children from this render object's child list.
  void removeAll() {
    children.forEach(dropChild);
    children.clear();
  }

  /// Move the given `child` in the child list to be after another child.
  ///
  /// More efficient than removing and re-adding the child. Requires the child
  /// to already be in the child list at some position. Pass null for `after` to
  /// move the child to the start of the child list.
  void move(ChildType child, {ChildType? after}) {
    assert(child != this);
    assert(after != this);
    assert(child != after);
    assert(child.parent == this);

    if (after == null) {
      children.remove(child);
      children.insert(0, child);
    } else {
      final afterIndex = children.indexOf(after);
      assert(afterIndex != -1);
      children.remove(child);
      children.insert(afterIndex + 1, child);
    }

    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    for (final child in children) {
      child.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();

    for (final child in children) {
      child.detach();
    }
  }

  @override
  void redepthChildren() => children.forEach(redepthChild);

  @override
  void visitChildren(RenderObjectVisitor visitor) => children.forEach(visitor);

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];

    for (var i = 0; i != childCount; ++i) {
      children.add(this.children[i].toDiagnosticsNode(name: "child ${i + 1}"));
    }

    return children;
  }
}

/// A mixin that provides useful default behaviors for boxes with children
/// managed by the [ContainerRenderObjectMixin] mixin.
///
/// By convention, this class doesn't override any members of the superclass.
/// Instead, it provides helpful functions that subclasses can call as
/// appropriate.
mixin RenderBoxListDefaultsMixin<ChildType extends RenderBox,
        ParentDataType extends ListBoxParentData<ChildType>>
    implements ListRenderObjectMixin<ChildType, ParentDataType> {
  /// Returns the baseline of the first child with a baseline.
  ///
  /// Useful when the children are displayed vertically in the same order they
  /// appear in the child list.
  double? defaultComputeDistanceToFirstActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);

    for (final child in children) {
      _debugAssertParentDataType(child);
      final childParentData = child.parentData as ParentDataType;
      // ignore: invalid_use_of_protected_member
      final double? result = child.getDistanceToActualBaseline(baseline);
      if (result != null) return result + childParentData.offset.dy;
    }

    return null;
  }

  /// Returns the minimum baseline value among every child.
  ///
  /// Useful when the vertical position of the children isn't determined by the
  /// order in the child list.
  double? defaultComputeDistanceToHighestActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    double? result;

    for (final child in children) {
      _debugAssertParentDataType(child);
      final childParentData = child.parentData as ParentDataType;
      // ignore: invalid_use_of_protected_member
      double? candidate = child.getDistanceToActualBaseline(baseline);
      if (candidate != null) {
        candidate += childParentData.offset.dy;
        if (result != null) {
          result = math.min(result, candidate);
        } else {
          result = candidate;
        }
      }
    }

    return result;
  }

  /// Performs a hit test on each child by walking the child list backwards.
  ///
  /// Stops walking once after the first child reports that it contains the
  /// given point. Returns whether any children contain the given point.
  ///
  /// See also:
  ///
  ///  * [defaultPaint], which paints the children appropriate for this
  ///    hit-testing strategy.
  bool defaultHitTestChildren(
    BoxHitTestResult result, {
    required Offset position,
  }) {
    for (var i = childCount - 1; i > -1; --i) {
      final child = children[i];
      _debugAssertParentDataType(child);
      final childParentData = child.parentData as ParentDataType;
      final isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );

      if (isHit) return true;
    }

    return false;
  }

  /// Paints each child by walking the child list forwards.
  ///
  /// See also:
  ///
  ///  * [defaultHitTestChildren], which implements hit-testing of the children
  ///    in a manner appropriate for this painting strategy.
  void defaultPaint(PaintingContext context, Offset offset) {
    for (var i = childCount - 1; i > -1; --i) {
      final child = children[i];
      _debugAssertParentDataType(child);
      final childParentData = child.parentData as ParentDataType;
      context.paintChild(child, childParentData.offset + offset);
    }
  }

  void _debugAssertParentDataType(ChildType child) {
    assert(
      child.parentData is ParentDataType,
      "Child parent data was expected to be of type $ParentDataType,"
      "but it is of type ${child.parentData.runtimeType}",
    );
  }
}
