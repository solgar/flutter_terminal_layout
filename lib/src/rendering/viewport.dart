import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';
import 'constraints.dart';

class RenderViewport extends RenderObject {
  double _offset = 0.0;
  RenderObject? _child;
  void Function(double)? onLayoutChanged;

  RenderViewport({
    double offset = 0.0,
    this.onLayoutChanged,
    RenderObject? child,
  }) : _offset = offset {
    if (child != null) {
      this.child = child;
    }
  }

  double get offset => _offset;
  set offset(double value) {
    if (_offset == value) return;
    _offset = value;
    // We strictly assume this doesn't affect layout, only paint
    // In real flutter it might affect layout (if infinite scrolling etc), but here simplified.
  }

  RenderObject? get child => _child;
  set child(RenderObject? value) {
    if (_child != null) _child!.parent = null;
    _child = value;
    if (_child != null) {
      _child!.parent = this;
      _child!.attach(this);
    }
  }

  @override
  void performLayout() {
    // 1. We take up all available space from parent
    size = constraints.constrain(
      Size(constraints.maxWidth, constraints.maxHeight),
    );

    if (child != null) {
      // 2. We give child infinite vertical space
      // And strict width (assuming vertical list)
      final innerConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: size.width,
        minHeight: 0,
        maxHeight: 100000,
      );
      child!.layout(innerConstraints, parentUsesSize: true);

      double maxScroll = (child!.size.height - size.height).toDouble();
      if (maxScroll < 0) maxScroll = 0;
      onLayoutChanged?.call(maxScroll);
    }
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    if (child != null) {
      canvas.save();
      // Clip to our bounds (offset + size)
      // Note: Rect.fromLTWH takes int, assuming size/offset are int compatible which they are in this terminal world
      canvas.clipRect(
        Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      );

      double maxScroll = (child!.size.height - size.height).toDouble();
      if (maxScroll < 0) maxScroll = 0;
      double effectiveOffset = _offset;
      if (effectiveOffset > maxScroll) effectiveOffset = maxScroll;

      int yOff = effectiveOffset.round();
      child!.paint(canvas, offset - Offset(0, yOff));

      canvas.restore();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // 1. Check our bounds
    if (position.dx < 0 ||
        position.dx >= size.width ||
        position.dy < 0 ||
        position.dy >= size.height) {
      return false;
    }

    // 2. Hit test child
    if (child != null) {
      // Transform position to child coordinates:
      // Local pos = (x, y)
      // Child is painted at (x, y - offset)
      // So relative to child, a point P in viewport is P + Offset(0, offset)

      double maxScroll = (child!.size.height - size.height).toDouble();
      if (maxScroll < 0) maxScroll = 0;
      double effectiveOffset = _offset;
      if (effectiveOffset > maxScroll) effectiveOffset = maxScroll;

      int yOff = effectiveOffset.round();
      final childPos = position + Offset(0, yOff);

      if (child!.hitTest(result, position: childPos)) {
        result.add(BoxHitTestEntry(this));
        return true;
      }
    }

    // 3. Self
    result.add(BoxHitTestEntry(this));
    return true;
  }
}
