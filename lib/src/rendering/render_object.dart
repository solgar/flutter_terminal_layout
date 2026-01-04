import 'constraints.dart';
import 'geometry.dart';
import 'canvas.dart';

class ParentData {
  // Base class for data that parent render objects attach to children.
}

abstract class RenderObject {
  BoxConstraints? _constraints;
  Size? _size;
  RenderObject? parent;
  ParentData? parentData;

  Size get size => _size ?? Size.zero;
  set size(Size value) {
    _size = value;
  }

  BoxConstraints get constraints => _constraints ?? BoxConstraints();

  bool _needsLayout = true;
  bool get needsLayout => _needsLayout;

  void markNeedsLayout() {
    if (_needsLayout) {
      return;
    }
    _needsLayout = true;
    if (parent != null) {
      parent!.markNeedsLayout();
    }
  }

  /// Lays out the render object.
  void layout(BoxConstraints constraints, {bool parentUsesSize = false}) {
    _constraints = constraints;
    _needsLayout = false;
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

  /// Hit testing
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Default implementation assumes no interaction unless overridden
    return false;
  }
}

class BoxHitTestEntry {
  final RenderObject target;
  BoxHitTestEntry(this.target);
}

class BoxHitTestResult {
  final List<BoxHitTestEntry> path = [];

  void add(BoxHitTestEntry entry) {
    path.add(entry);
  }
}
