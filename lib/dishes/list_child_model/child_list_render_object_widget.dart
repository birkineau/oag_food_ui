import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'list_parent_data_mixin.dart';
import 'list_render_object_mixin.dart';

/// * See [MultiChildRenderObjectWidget].
abstract class ChildListRenderObjectWidget extends RenderObjectWidget {
  /// Initializes fields for subclasses.
  const ChildListRenderObjectWidget({
    super.key,
    this.children = const <Widget>[],
  });

  /// The widgets below this widget in the tree.
  ///
  /// If this list is going to be mutated, it is usually wise to put a [Key] on
  /// each of the child widgets, so that the framework can match old
  /// configurations to new configurations and maintain the underlying render
  /// objects.
  ///
  /// Also, a [Widget] in Flutter is immutable, so directly modifying the
  /// [children] such as `someChildListRenderObjectWidget.children.add(...)` or
  /// as the example code below will result in incorrect behaviors. Whenever the
  /// children list is modified, a new list object should be provided.
  ///
  /// ```dart
  /// class SomeWidgetState extends State<SomeWidget> {
  ///   List<Widget> _children;
  ///
  ///   void initState() {
  ///     _children = [];
  ///   }
  ///
  ///   void someHandler() {
  ///     setState(() {
  ///         _children.add(...);
  ///     });
  ///   }
  ///
  ///   Widget build(...) {
  ///     // Reusing `List<Widget> _children` here is problematic.
  ///     return Row(children: _children);
  ///   }
  /// }
  /// ```
  ///
  /// The following code corrects the problem mentioned above.
  ///
  /// ```dart
  /// class SomeWidgetState extends State<SomeWidget> {
  ///   List<Widget> _children;
  ///
  ///   void initState() {
  ///     _children = [];
  ///   }
  ///
  ///   void someHandler() {
  ///     setState(() {
  ///       // The key here allows Flutter to reuse the underlying render
  ///       // objects even if the children list is recreated.
  ///       _children.add(ChildWidget(key: ...));
  ///     });
  ///   }
  ///
  ///   Widget build(...) {
  ///     // Always create a new list of children as a Widget is immutable.
  ///     return Row(children: List.of(_children));
  ///   }
  /// }
  /// ```
  final List<Widget> children;

  @override
  ChildListRenderObjectElement createElement() =>
      ChildListRenderObjectElement(this);
}

/// An [Element] that uses a [ChildListRenderObjectWidget] as its configuration.
///
/// This element subclass can be used for RenderObjectWidgets whose
/// RenderObjects use the [ListRenderObjectMixin] mixin with a parent data
/// type that implements [ListParentDataMixin]. Such widgets
/// are expected to inherit from [ChildListRenderObjectWidget].
///
/// See also:
///
/// * [IndexedSlot], which is used as [Element.slot]s for the children of a
///   [ChildListRenderObjectElement].
/// * [RenderObjectElement.updateChildren], which discusses why [IndexedSlot]
///   is used for the slots of the children.
class ChildListRenderObjectElement extends RenderObjectElement {
  /// Creates an element that uses the given widget as its configuration.
  ChildListRenderObjectElement(ChildListRenderObjectWidget super.widget)
      : assert(!debugChildrenHaveDuplicateKeys(widget, widget.children));

  @override
  ListRenderObjectMixin<RenderObject, ListBoxParentData<RenderObject>>
      get renderObject {
    return super.renderObject
        as ListRenderObjectMixin<RenderObject, ListBoxParentData<RenderObject>>;
  }

  /// The current list of children of this element.
  ///
  /// This list is filtered to hide elements that have been forgotten (using
  /// [forgetChild]).
  Iterable<Element> get children =>
      _children.where((Element child) => !_forgottenChildren.contains(child));

  late List<Element> _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  void insertRenderObjectChild(RenderObject child, IndexedSlot<Element?> slot) {
    final ListRenderObjectMixin<RenderObject, ListBoxParentData<RenderObject>>
        renderObject = this.renderObject;
    assert(renderObject.debugValidateChild(child));
    renderObject.add(child);
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(RenderObject child, IndexedSlot<Element?> oldSlot,
      IndexedSlot<Element?> newSlot) {
    final ListRenderObjectMixin<RenderObject, ListBoxParentData<RenderObject>>
        renderObject = this.renderObject;
    assert(child.parent == renderObject);
    renderObject.move(child, after: newSlot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final ListRenderObjectMixin<RenderObject, ListBoxParentData<RenderObject>>
        renderObject = this.renderObject;
    assert(child.parent == renderObject);
    renderObject.remove(child);
    assert(renderObject == this.renderObject);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Element child in _children) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }

  bool _debugCheckHasAssociatedRenderObject(Element newChild) {
    assert(() {
      if (newChild.renderObject == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary(
                  'The children of `ChildListRenderObjectWidget` must each has an associated render object.'),
              ErrorHint(
                'This typically means that the `${newChild.widget}` or its children\n'
                'are not a subtype of `RenderObjectWidget`.',
              ),
              newChild.describeElement(
                  'The following element does not have an associated render object'),
              DiagnosticsDebugCreator(DebugCreator(newChild)),
            ]),
          ),
        );
      }
      return true;
    }());
    return true;
  }

  @override
  Element inflateWidget(Widget newWidget, Object? newSlot) {
    final Element newChild = super.inflateWidget(newWidget, newSlot);
    assert(_debugCheckHasAssociatedRenderObject(newChild));
    return newChild;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    final childListRenderObjectWidget = widget as ChildListRenderObjectWidget;
    final List<Element> children = List<Element>.filled(
        childListRenderObjectWidget.children.length, _NullElement.instance);
    Element? previousChild;
    for (int i = 0; i < children.length; ++i) {
      final Element newChild = inflateWidget(
        childListRenderObjectWidget.children[i],
        IndexedSlot<Element?>(i, previousChild),
      );
      children[i] = newChild;
      previousChild = newChild;
    }
    _children = children;
  }

  @override
  void update(ChildListRenderObjectWidget newWidget) {
    super.update(newWidget);
    final childListRenderObjectWidget = widget as ChildListRenderObjectWidget;
    assert(widget == newWidget);
    assert(!debugChildrenHaveDuplicateKeys(
        widget, childListRenderObjectWidget.children));
    _children = updateChildren(_children, childListRenderObjectWidget.children,
        forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
  }
}

/// Used as a placeholder in [List<Element>] objects when the actual
/// elements are not yet determined.
class _NullElement extends Element {
  _NullElement() : super(const _NullWidget());

  static _NullElement instance = _NullElement();

  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  void performRebuild() => throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}
