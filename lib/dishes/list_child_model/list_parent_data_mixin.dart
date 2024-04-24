import 'package:flutter/rendering.dart';

/// Parent data to support a [List] of children.
mixin ListParentDataMixin<ChildType extends RenderObject> on ParentData {
  /// Additional base list parent data members.
  @override
  void detach() {
    /// Additional base list parent data behavior.
    super.detach();
  }
}

/// See [ContainerBoxParentData].
/// See [RenderBoxContainerDefaultsMixin].
abstract class ListBoxParentData<ChildType extends RenderObject>
    extends BoxParentData with ListParentDataMixin<ChildType> {}
