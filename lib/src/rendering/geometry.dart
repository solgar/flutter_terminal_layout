/// A 2D floating-point size.
/// In terminal context, usually integers, but we stick to double for API consistency?
/// Actually integers make more sense for terminal cells.
class Size {
  final int width;
  final int height;

  const Size(this.width, this.height);

  static const Size zero = Size(0, 0);

  @override
  String toString() => 'Size($width, $height)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Size && other.width == width && other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}

/// A 2D offset.
class Offset {
  final int dx;
  final int dy;

  const Offset(this.dx, this.dy);

  static const Offset zero = Offset(0, 0);

  Offset operator +(Offset other) => Offset(dx + other.dx, dy + other.dy);
  Offset operator -(Offset other) => Offset(dx - other.dx, dy - other.dy);

  @override
  String toString() => 'Offset($dx, $dy)';
}

/// A point within a rectangle.
/// x and y range from -1.0 to 1.0.
class Alignment {
  final double x;
  final double y;

  const Alignment(this.x, this.y);

  static const Alignment topLeft = Alignment(-1.0, -1.0);
  static const Alignment topCenter = Alignment(0.0, -1.0);
  static const Alignment topRight = Alignment(1.0, -1.0);
  static const Alignment centerLeft = Alignment(-1.0, 0.0);
  static const Alignment center = Alignment(0.0, 0.0);
  static const Alignment centerRight = Alignment(1.0, 0.0);
  static const Alignment bottomLeft = Alignment(-1.0, 1.0);
  static const Alignment bottomCenter = Alignment(0.0, 1.0);
  static const Alignment bottomRight = Alignment(1.0, 1.0);

  /// Returns the offset at which a child of the given size should be placed
  /// within a parent of the given size.
  Offset alongSize(Size parentSize, Size childSize) {
    final double dx = (parentSize.width - childSize.width) / 2.0 * (1.0 + x);
    final double dy = (parentSize.height - childSize.height) / 2.0 * (1.0 + y);
    return Offset(dx.round(), dy.round());
  }

  @override
  String toString() => 'Alignment($x, $y)';
}

class Rect {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const Rect.fromLTRB(this.left, this.top, this.right, this.bottom);

  factory Rect.fromLTWH(int left, int top, int width, int height) {
    return Rect.fromLTRB(left, top, left + width, top + height);
  }

  int get width => right - left;
  int get height => bottom - top;

  bool contains(Offset point) {
    return point.dx >= left &&
        point.dx < right &&
        point.dy >= top &&
        point.dy < bottom;
  }

  Rect intersect(Rect other) {
    final int newLeft = left > other.left ? left : other.left;
    final int newTop = top > other.top ? top : other.top;
    final int newRight = right < other.right ? right : other.right;
    final int newBottom = bottom < other.bottom ? bottom : other.bottom;

    // Check if empty result?
    if (newLeft >= newRight || newTop >= newBottom) {
      return Rect.fromLTRB(0, 0, 0, 0); // Empty rect
    }

    return Rect.fromLTRB(newLeft, newTop, newRight, newBottom);
  }

  @override
  String toString() => 'Rect($left, $top, $right, $bottom)';
}

/// Immutable offsets for the 4 cardinal directions.
class EdgeInsets {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const EdgeInsets.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  const EdgeInsets.all(int value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  const EdgeInsets.symmetric({int vertical = 0, int horizontal = 0})
    : left = horizontal,
      top = vertical,
      right = horizontal,
      bottom = vertical;

  static const EdgeInsets zero = EdgeInsets.only();

  /// Returns a new EdgeInsets with values added to existing ones
  EdgeInsets add(EdgeInsets other) {
    return EdgeInsets.only(
      left: left + other.left,
      top: top + other.top,
      right: right + other.right,
      bottom: bottom + other.bottom,
    );
  }

  /// Inflates a rect by the amounts in this EdgeInsets.
  // Rect inflateRect(Rect rect) { ... }

  /// Deflates a rect...
  // Rect deflateRect(Rect rect) { ... }
}
