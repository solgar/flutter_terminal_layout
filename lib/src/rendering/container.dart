import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';
import 'constraints.dart';

class RenderContainer extends RenderObject {
  String? color;
  int? width;
  int? height;
  RenderObject? _child;

  RenderObject? get child => _child;
  set child(RenderObject? value) {
    if (_child != null) _child!.parent = null;
    _child = value;
    if (_child != null) {
      _child!.parent = this;
      _child!.attach(this);
    }
  }

  RenderContainer({this.color, this.width, this.height, RenderObject? child}) {
    if (child != null) {
      this.child = child;
    }
  }

  @override
  void performLayout() {
    int minW = constraints.minWidth;
    int maxW = constraints.maxWidth;
    int minH = constraints.minHeight;
    int maxH = constraints.maxHeight;

    if (width != null) {
      minW = width!;
      maxW = width!;
    }

    if (height != null) {
      minH = height!;
      maxH = height!;
    }

    minW = minW.clamp(constraints.minWidth, constraints.maxWidth);
    maxW = maxW.clamp(constraints.minWidth, constraints.maxWidth);
    minH = minH.clamp(constraints.minHeight, constraints.maxHeight);
    maxH = maxH.clamp(constraints.minHeight, constraints.maxHeight);

    final effConstraints = BoxConstraints(
      minWidth: minW,
      maxWidth: maxW,
      minHeight: minH,
      maxHeight: maxH,
    );

    if (child != null) {
      child!.layout(effConstraints, parentUsesSize: true);
      size = child!.size;
    } else {
      int w = (width != null)
          ? width!
          : (effConstraints.maxWidth == 100000 ? 0 : effConstraints.maxWidth);
      int h = (height != null)
          ? height!
          : (effConstraints.maxHeight == 100000 ? 0 : effConstraints.maxHeight);

      size = effConstraints.constrain(Size(w, h));
    }

    // Final clamp
    size = constraints.constrain(size);
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    if (color != null) {
      canvas.fillRect(offset.dx, offset.dy, size.width, size.height, bg: color);
    }

    if (child != null) {
      child!.paint(canvas, offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // 1. Check bounds
    if (position.dx < 0 ||
        position.dx >= size.width ||
        position.dy < 0 ||
        position.dy >= size.height) {
      return false;
    }

    // 2. Test children (children first)
    // Container has single child, coordinates are typically (0,0) relative to self unless padded?
    // Container paint calls child at offset (which is self offset).
    // wait, layout determines child position inside container.
    // In this simplified model, paint(canvas, offset) passes 'offset' to child.
    // This implies child is at (0,0) relative to container.
    if (child != null) {
      if (child!.hitTest(result, position: position)) {
        result.add(BoxHitTestEntry(this));
        return true;
      }
    }

    // 3. We hit ourselves
    result.add(BoxHitTestEntry(this));
    return true;
  }
}
