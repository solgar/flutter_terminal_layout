import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';
import 'constraints.dart';

class RenderContainer extends RenderObject {
  String? color;
  int? width;
  int? height;
  Alignment? alignment;
  RenderObject? _child;

  // Track child offset for paint/hitTest
  Offset _childOffset = Offset.zero;

  RenderObject? get child => _child;
  set child(RenderObject? value) {
    if (_child != null) _child!.parent = null;
    _child = value;
    if (_child != null) {
      _child!.parent = this;
      _child!.attach(this);
    }
  }

  RenderContainer({
    this.color,
    this.width,
    this.height,
    this.alignment,
    RenderObject? child,
  }) {
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
      if (alignment != null) {
        // If alignment is present, loosen constraints for child
        child!.layout(effConstraints.loosen(), parentUsesSize: true);

        // Container expands to fill available space if allowed
        int w = (width != null) ? width! : maxW;
        int h = (height != null) ? height! : maxH;

        // Handle unbounded max (pseudo-unbounded 100000)
        if (w >= 100000) w = child!.size.width;
        if (h >= 100000) h = child!.size.height;

        size = constraints.constrain(Size(w, h));

        // Calculate offset
        _childOffset = alignment!.alongSize(size, child!.size);
      } else {
        child!.layout(effConstraints, parentUsesSize: true);
        size = child!.size;
        _childOffset = Offset.zero;
      }
    } else {
      int w = (width != null)
          ? width!
          : (effConstraints.maxWidth == 100000 ? 0 : effConstraints.maxWidth);
      int h = (height != null)
          ? height!
          : (effConstraints.maxHeight == 100000 ? 0 : effConstraints.maxHeight);

      size = effConstraints.constrain(Size(w, h));
      _childOffset = Offset.zero;
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
      child!.paint(canvas, offset + _childOffset);
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

    // 2. Test children
    if (child != null) {
      // Adjust position for child offset
      final childPos = position - _childOffset;
      if (child!.hitTest(result, position: childPos)) {
        result.add(BoxHitTestEntry(this));
        return true;
      }
    }

    // 3. We hit ourselves
    result.add(BoxHitTestEntry(this));
    return true;
  }
}
