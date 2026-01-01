import 'constraints.dart';
import 'geometry.dart';
import 'canvas.dart';

class ParentData {
  // Base class for data that parent render objects attach to children.
}

abstract class RenderObject {
  BoxConstraints? _constraints;
  Size? _size;
  RenderObject? _parent;
  ParentData? parentData;

  RenderObject? get parent => _parent;
  set parent(RenderObject? value) {
    _parent = value;
  }

  Size get size => _size ?? Size.zero;
  set size(Size value) {
    _size = value;
  }

  BoxConstraints get constraints => _constraints ?? BoxConstraints();

  /// Lays out the render object.
  void layout(BoxConstraints constraints, {bool parentUsesSize = false}) {
    _constraints = constraints;
    performLayout();
  }

  /// Subclasses should implement this to set their [size].
  void performLayout();

  /// Paint this object onto the canvas at the given offset.
  void paint(Canvas canvas, Offset offset);

  /// Override to setup parent data for a child.
  void setupParentData(RenderObject child) {
    if (child.parentData is! ParentData) {
      child.parentData = ParentData();
    }
  }

  /// Called when this object is attached to a parent.
  void attach(RenderObject owner) {}
}
