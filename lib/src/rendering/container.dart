import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';
import 'constraints.dart';
import 'decoration.dart';

class RenderContainer extends RenderObject {
  BoxDecoration? decoration;
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

  EdgeInsets? padding;

  RenderContainer({
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.padding,
    RenderObject? child,
  }) {
    if (child != null) {
      this.child = child;
    }
  }

  // Helper getters for color compatibility
  String? get color => decoration?.color;
  set color(String? value) {
    if (value == null && decoration == null) return;
    if (decoration == null) {
      decoration = BoxDecoration(color: value);
    } else {
      decoration = BoxDecoration(color: value, border: decoration!.border);
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

    int horizontalPadding = 0;
    int verticalPadding = 0;
    if (padding != null) {
      horizontalPadding = padding!.left + padding!.right;
      verticalPadding = padding!.top + padding!.bottom;
    }

    if (child != null) {
      if (alignment != null) {
        // If alignment is present, loosen constraints for child
        // Deflate constraints by padding
        final childConstraints = effConstraints.loosen().deflate(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        );

        child!.layout(childConstraints, parentUsesSize: true);

        // Container expands to fill available space if allowed
        int w = (width != null) ? width! : maxW;
        int h = (height != null) ? height! : maxH;

        // Handle unbounded max (pseudo-unbounded 100000)
        if (w >= 100000) w = child!.size.width + horizontalPadding;
        if (h >= 100000) h = child!.size.height + verticalPadding;

        size = constraints.constrain(Size(w, h));

        // Calculate offset
        // Alignment applies to the child *within* the padded area.
        Size paddedSize = Size(
          size.width - horizontalPadding,
          size.height - verticalPadding,
        );
        Offset alignmentOffset = alignment!.alongSize(paddedSize, child!.size);

        _childOffset =
            alignmentOffset + Offset(padding?.left ?? 0, padding?.top ?? 0);
      } else {
        // No alignment: Child matches constraint, maybe filling if tight?
        // Actually typically straightforward layout: child gets tighter constraints?
        // Let's pass deflated constraints.
        final childConstraints = effConstraints.deflate(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        );
        child!.layout(childConstraints, parentUsesSize: true);

        size = Size(
          child!.size.width + horizontalPadding,
          child!.size.height + verticalPadding,
        );
        // Clamp to min/max
        size = effConstraints.constrain(size);

        _childOffset = Offset(padding?.left ?? 0, padding?.top ?? 0);
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
    if (decoration != null) {
      // 1. Paint background
      if (decoration!.color != null) {
        canvas.fillRect(
          offset.dx,
          offset.dy,
          size.width,
          size.height,
          bg: decoration!.color,
        );
      }

      // 2. Paint border
      if (decoration!.border != null) {
        _paintBorder(canvas, offset, decoration!.border!);
      }
    }

    if (child != null) {
      child!.paint(canvas, offset + _childOffset);
    }
  }

  void _paintBorder(Canvas canvas, Offset offset, BoxBorder border) {
    // Helper to check side existence (Scoped for entire function)
    final bool hasTop = border.top.style != BorderStyle.none;
    final bool hasBottom = border.bottom.style != BorderStyle.none;
    final bool hasLeft = border.left.style != BorderStyle.none;
    final bool hasRight = border.right.style != BorderStyle.none;

    if (size.width == 1 && size.height == 1) {
      // Special 1x1 handling to resolve corner conflicts
      int mask = 0;
      // N=1, E=2, S=4, W=8
      // Horizontal implies E+W (10)
      if (hasTop) mask |= 10;
      if (hasBottom) mask |= 10;
      // Vertical implies N+S (5)
      if (hasLeft) mask |= 5;
      if (hasRight) mask |= 5;

      // Subtract extensions based on corners
      // Top-Left intersection: Remove West (8) and North (1)
      if (hasTop && hasLeft) mask &= ~9;
      // Top-Right intersection: Remove East (2) and North (1)
      if (hasTop && hasRight) mask &= ~3;
      // Bottom-Left intersection: Remove West (8) and South (4)
      if (hasBottom && hasLeft) mask &= ~12;
      // Bottom-Right intersection: Remove East (2) and South (4)
      if (hasBottom && hasRight) mask &= ~6;

      if (mask != 0) {
        // Use generic '+' if maskToChar fails (shouldn't happen for valid masks)
        String char = Canvas.maskToChar[mask] ?? '+';
        // Pick color (priority: top, left, bottom, right)
        String? color =
            border.top.color ??
            border.left.color ??
            border.bottom.color ??
            border.right.color;
        canvas.setCell(offset.dx, offset.dy, char, fg: color, isBorder: true);
      }
      return;
    }

    final int left = offset.dx;
    final int top = offset.dy;
    final int right = left + size.width - 1;
    final int bottom = top + size.height - 1;

    // Top Edge (excluding corners)
    if (hasTop) {
      final char = _horizontalChar(border.top.style);
      for (int x = left + 1; x < right; x++) {
        canvas.setCell(x, top, char, fg: border.top.color, isBorder: true);
      }
    }

    // Bottom Edge (excluding corners)
    if (hasBottom) {
      final char = _horizontalChar(border.bottom.style);
      for (int x = left + 1; x < right; x++) {
        canvas.setCell(
          x,
          bottom,
          char,
          fg: border.bottom.color,
          isBorder: true,
        );
      }
    }

    // Left Edge (excluding corners)
    if (hasLeft) {
      final char = _verticalChar(border.left.style);
      for (int y = top + 1; y < bottom; y++) {
        canvas.setCell(left, y, char, fg: border.left.color, isBorder: true);
      }
    }

    // Right Edge (excluding corners)
    if (hasRight) {
      final char = _verticalChar(border.right.style);
      for (int y = top + 1; y < bottom; y++) {
        canvas.setCell(right, y, char, fg: border.right.color, isBorder: true);
      }
    }

    // CORNERS
    // Logic: If both sides meet, use corner char.
    // If only one side touches the corner, extend that side's char.

    // Top Left
    if (hasTop || hasLeft) {
      String char;
      String? color;
      if (hasTop && hasLeft) {
        char = _topLeftChar(border.top.style);
        color = border.top.color ?? border.left.color;
      } else if (hasTop) {
        char = _horizontalChar(border.top.style);
        color = border.top.color;
      } else {
        char = _verticalChar(border.left.style);
        color = border.left.color;
      }
      canvas.setCell(left, top, char, fg: color, isBorder: true);
    }

    // Top Right
    if (hasTop || hasRight) {
      String char;
      String? color;
      if (hasTop && hasRight) {
        char = _topRightChar(border.top.style);
        color = border.top.color ?? border.right.color;
      } else if (hasTop) {
        char = _horizontalChar(border.top.style);
        color = border.top.color;
      } else {
        char = _verticalChar(border.right.style);
        color = border.right.color;
      }
      canvas.setCell(right, top, char, fg: color, isBorder: true);
    }

    // Bottom Left
    if (hasBottom || hasLeft) {
      String char;
      String? color;
      if (hasBottom && hasLeft) {
        char = _bottomLeftChar(border.bottom.style);
        color = border.bottom.color ?? border.left.color;
      } else if (hasBottom) {
        char = _horizontalChar(border.bottom.style);
        color = border.bottom.color;
      } else {
        char = _verticalChar(border.left.style);
        color = border.left.color;
      }
      canvas.setCell(left, bottom, char, fg: color, isBorder: true);
    }

    // Bottom Right
    if (hasBottom || hasRight) {
      String char;
      String? color;
      if (hasBottom && hasRight) {
        char = _bottomRightChar(border.bottom.style);
        color = border.bottom.color ?? border.right.color;
      } else if (hasBottom) {
        char = _horizontalChar(border.bottom.style);
        color = border.bottom.color;
      } else {
        char = _verticalChar(border.right.style);
        color = border.right.color;
      }
      canvas.setCell(right, bottom, char, fg: color, isBorder: true);
    }
  }

  String _horizontalChar(BorderStyle style) {
    switch (style) {
      case BorderStyle.double:
        return '═';
      case BorderStyle.heavy:
        return '━';
      case BorderStyle.dashed:
        return '╌';
      default:
        return '─';
    }
  }

  String _verticalChar(BorderStyle style) {
    switch (style) {
      case BorderStyle.double:
        return '║';
      case BorderStyle.heavy:
        return '┃';
      case BorderStyle.dashed:
        return '╎';
      default:
        return '│';
    }
  }

  String _topLeftChar(BorderStyle style) {
    switch (style) {
      case BorderStyle.rounded:
        return '╭';
      case BorderStyle.double:
        return '╔';
      case BorderStyle.heavy:
        return '┏';
      case BorderStyle.dashed:
        return '┌';
      default:
        return '┌';
    }
  }

  String _topRightChar(BorderStyle style) {
    switch (style) {
      case BorderStyle.rounded:
        return '╮';
      case BorderStyle.double:
        return '╗';
      case BorderStyle.heavy:
        return '┓';
      case BorderStyle.dashed:
        return '┐';
      default:
        return '┐';
    }
  }

  String _bottomLeftChar(BorderStyle style) {
    switch (style) {
      case BorderStyle.rounded:
        return '╰';
      case BorderStyle.double:
        return '╚';
      case BorderStyle.heavy:
        return '┗';
      case BorderStyle.dashed:
        return '└';
      default:
        return '└';
    }
  }

  String _bottomRightChar(BorderStyle style) {
    switch (style) {
      case BorderStyle.rounded:
        return '╯';
      case BorderStyle.double:
        return '╝';
      case BorderStyle.heavy:
        return '┛';
      case BorderStyle.dashed:
        return '┘';
      default:
        return '┘';
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
