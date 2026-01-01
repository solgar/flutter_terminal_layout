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

  @override
  String toString() => 'Offset($dx, $dy)';
}
