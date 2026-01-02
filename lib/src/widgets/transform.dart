import 'framework.dart';
import 'widget.dart';
import '../rendering/render_object.dart';
import '../rendering/canvas.dart';
import '../rendering/geometry.dart';

class Transform extends SingleChildRenderObjectWidget {
  final Offset transform;

  const Transform({super.key, super.child, required this.transform});

  factory Transform.translate({
    Key? key,
    required Offset offset,
    Widget? child,
  }) {
    return Transform(key: key, transform: offset, child: child);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTransform(transform);
  }

  @override
  void updateRenderObject(BuildContext context, RenderTransform renderObject) {
    renderObject.transform = transform;
  }
}

class RenderTransform extends RenderObject {
  Offset transform;
  RenderObject? child;

  RenderTransform(this.transform);

  // Single child mixin logic manually
  set childRenderObject(RenderObject? c) {
    if (child != null) child!.parent = null;
    child = c;
    if (child != null) child!.parent = this;
    markNeedsLayout();
  }

  void add(RenderObject child) {
    this.childRenderObject = child;
  }

  @override
  void performLayout() {
    if (child != null) {
      // Pass constraints through
      child!.layout(constraints);
      size = child!.size;
    } else {
      size = Size(constraints.minWidth, constraints.minHeight);
    }
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    if (child != null) {
      // Apply transform to offset
      child!.paint(canvas, offset + transform);
    }
  }
}
