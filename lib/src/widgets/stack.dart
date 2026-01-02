import 'framework.dart';
import 'widget.dart';
import '../rendering/render_object.dart';
import '../rendering/canvas.dart';
import '../rendering/geometry.dart';
import '../rendering/constraints.dart';

class Stack extends MultiChildRenderObjectWidget {
  const Stack({super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderStack();
  }

  @override
  void updateRenderObject(BuildContext context, RenderStack renderObject) {
    // No specific updates for now
  }
}

class Positioned extends SingleChildRenderObjectWidget {
  final int? left;
  final int? top;
  final int? right;
  final int? bottom;
  final int? width;
  final int? height;

  const Positioned({
    super.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPositioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPositioned renderObject) {
    renderObject
      ..left = left
      ..top = top
      ..right = right
      ..bottom = bottom
      ..width = width
      ..height = height;
  }
}

class RenderStack extends RenderObject {
  final List<RenderObject> _children = [];

  void add(RenderObject child) {
    _children.add(child);
    child.parent = this;
    markNeedsLayout();
  }

  void removeAll() {
    // Detach
    for (var c in _children) c.parent = null;
    _children.clear();
    markNeedsLayout();
  }

  @override
  void performLayout() {
    // Stack layout: Pass tight constraints of self to children unless they are Positioned?
    // For now, let's assume we pass incoming constraints to non-positioned children (like expand)
    // And Positioned children use their offset.
    // Simplifying: Stack fills constraints.
    size = Size(constraints.maxWidth, constraints.maxHeight);

    for (final child in _children) {
      if (child is RenderPositioned) {
        // Calculate constraints for positioned child based on self size
        int w =
            child.width ??
            (size.width - (child.left ?? 0) - (child.right ?? 0));
        int h =
            child.height ??
            (size.height - (child.top ?? 0) - (child.bottom ?? 0));

        // Ensure not negative
        if (w < 0) w = 0;
        if (h < 0) h = 0;

        child.layout(BoxConstraints.tight(Size(w, h)));
      } else {
        // Non-positioned: stretch to Stack size? Or loose?
        // Let's assume standard behavior: Loose check, but here we can just pass tight.
        child.layout(BoxConstraints.tight(size));
      }
    }
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    for (final child in _children) {
      if (child is RenderPositioned) {
        child.paint(canvas, offset + Offset(child.left ?? 0, child.top ?? 0));
      } else {
        child.paint(canvas, offset);
      }
    }
  }
}

class RenderPositioned extends RenderObject {
  int? left;
  int? top;
  int? right;
  int? bottom;
  int? width;
  int? height;

  RenderObject? child;

  RenderPositioned({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
  });

  void add(RenderObject child) {
    this.child = child;
    child.parent = this;
    markNeedsLayout();
  }

  // Single child logic
  set childRenderObject(RenderObject? c) {
    if (child != null) child!.parent = null;
    child = c;
    if (child != null) child!.parent = this;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = Size(constraints.maxWidth, constraints.maxHeight);
    if (child != null) {
      // Pass the size down to the child
      child!.layout(BoxConstraints.tight(size));
    }
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    if (child != null) {
      // No extra offset, parent stack handled my offset.
      // Wait, parent stack calls paint(child, offset + (left,top)).
      // So I just paint my child at my own internal offset?
      // Typically RenderObjects paint children at offset + childOffset.
      // Since I am just a wrapper, my child is at 0,0 relative to me.
      child!.paint(canvas, offset);
    }
  }
}
