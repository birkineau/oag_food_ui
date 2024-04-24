import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:oag_food_ui/utility/utility.dart';

import 'cpaint.dart';
import 'cpaint_parent_data.dart';

class CPaintChild extends ParentDataWidget<CPaintParentData> {
  const CPaintChild({
    super.key,
    required this.circle,
    required super.child,
  });

  final Circle circle;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is CPaintParentData);

    final parentData = renderObject.parentData as CPaintParentData;
    bool needsLayout = false;

    if (parentData.circle != circle) {
      parentData.circle = circle;
      needsLayout = true;
    }

    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => CPaint;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty("circle", circle));
  }
}
