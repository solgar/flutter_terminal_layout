import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';
import '../core/events.dart';

class RenderPointerListener extends RenderObject {
  PointerEventListener? onPointerDown;
  PointerEventListener? onPointerScroll;

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

  RenderPointerListener({
    this.onPointerDown,
    this.onPointerScroll,
    RenderObject? child,
  }) {
    this.child = child;
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = constraints.constrain(Size.zero);
    }
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    if (child != null) {
      child!.paint(canvas, offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool hit = false;
    if (child != null) {
      hit = child!.hitTest(result, position: position);
    }

    if (hit) {
      result.add(BoxHitTestEntry(this));
    }
    return hit;
  }

  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent && onPointerDown != null) {
      onPointerDown!(event);
    } else if (event is PointerScrollEvent && onPointerScroll != null) {
      onPointerScroll!(event);
    }
  }
}

typedef PointerEventListener = void Function(PointerEvent event);
