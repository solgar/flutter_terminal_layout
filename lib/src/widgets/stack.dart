import 'framework.dart';
import 'widget.dart';
import '../rendering/render_object.dart';
import '../rendering/canvas.dart';
import '../rendering/constraints.dart';

class Stack extends MultiChildRenderObjectWidget {
  const Stack({super.key, super.children});

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
    super.key,
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
    for (var c in _children) {
      c.parent = null;
    }
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
        int? minW, maxW, minH, maxH;

        if (child.width != null) {
          minW = maxW = child.width;
        } else if (child.left != null && child.right != null) {
          minW = maxW = size.width - child.left! - child.right!;
        } else {
          minW = 0;
          maxW = size.width - (child.left ?? 0) - (child.right ?? 0);
        }

        if (child.height != null) {
          minH = maxH = child.height;
        } else if (child.top != null && child.bottom != null) {
          minH = maxH = size.height - child.top! - child.bottom!;
        } else {
          minH = 0;
          maxH = size.height - (child.top ?? 0) - (child.bottom ?? 0);
        }

        child.layout(BoxConstraints(
          minWidth: minW!,
          maxWidth: maxW!,
          minHeight: minH!,
          maxHeight: maxH!,
        ));
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
        int x = child.left ?? 0;
        if (child.left == null && child.right != null) {
          x = size.width - child.right! - child.size.width;
        }

        int y = child.top ?? 0;
        if (child.top == null && child.bottom != null) {
          y = size.height - child.bottom! - child.size.height;
        }

        child.paint(canvas, offset + Offset(x, y));
      } else {
        child.paint(canvas, offset);
      }
    }
  }
}

class RenderPositioned extends RenderObject {
  int? _left;
  int? get left => _left;
  set left(int? value) {
    if (_left == value) return;
    _left = value;
    markNeedsLayout();
  }

  int? _top;
  int? get top => _top;
  set top(int? value) {
    if (_top == value) return;
    _top = value;
    markNeedsLayout();
  }

  int? _right;
  int? get right => _right;
  set right(int? value) {
    if (_right == value) return;
    _right = value;
    markNeedsLayout();
  }

  int? _bottom;
  int? get bottom => _bottom;
  set bottom(int? value) {
    if (_bottom == value) return;
    _bottom = value;
    markNeedsLayout();
  }

  int? _width;
  int? get width => _width;
  set width(int? value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  int? _height;
  int? get height => _height;
  set height(int? value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  RenderObject? _child;
  RenderObject? get child => _child;
  set child(RenderObject? value) {
    if (_child != null) _child!.parent = null;
    _child = value;
    if (_child != null) _child!.parent = this;
    markNeedsLayout();
  }

  RenderPositioned({
    int? left,
    int? top,
    int? right,
    int? bottom,
    int? width,
    int? height,
  })  : _left = left,
        _top = top,
        _right = right,
        _bottom = bottom,
        _width = width,
        _height = height;

  void add(RenderObject child) {
    this.child = child;
  }

  @override
  void performLayout() {
    if (_child != null) {
      _child!.layout(constraints);
      size = _child!.size;
    } else {
      size = constraints.smallest;
    }
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    if (_child != null) {
      // No extra offset, parent stack handled my offset.
      // Wait, parent stack calls paint(child, offset + (left,top)).
      // So I just paint my child at my own internal offset?
      // Typically RenderObjects paint children at offset + childOffset.
      // Since I am just a wrapper, my child is at 0,0 relative to me.
      _child!.paint(canvas, offset);
    }
  }
}
