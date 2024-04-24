import 'package:flutter/material.dart';
import 'package:oag_food_ui/utility/geometry.dart';

import '../list_child_model/list_parent_data_mixin.dart';

// Every child of a [MultiChildRenderObject] has [ParentData]. Since this is a
// container-type of widget, we can used the predefined [ContainerBoxParentData]
// which allows children to have access to their previous and next sibling.
//
// Additional properties added to enable flexible height children.
//
// * See [ContainerBoxParentData].
// * See [ContainerParentDataMixin].
class CPaintParentData extends ListBoxParentData<RenderBox> {
  Circle circle = Circle.zero;
  CurvedAnimation? curve;
  MaterialPointArcTween? tween;
}
