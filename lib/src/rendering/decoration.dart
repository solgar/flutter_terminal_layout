/// Styles for the border.
enum BorderStyle { none, solid, heavy, double, rounded, dashed }

/// A side of a border of a box.
class BorderSide {
  final String? color;
  final BorderStyle style;

  const BorderSide({this.color, this.style = BorderStyle.solid});

  static const BorderSide none = BorderSide(style: BorderStyle.none);

  BorderSide copyWith({String? color, BorderStyle? style}) {
    return BorderSide(color: color ?? this.color, style: style ?? this.style);
  }
}

/// A border of a box, comprised of four sides.
class BoxBorder {
  final BorderSide top;
  final BorderSide right;
  final BorderSide bottom;
  final BorderSide left;

  const BoxBorder({
    this.top = BorderSide.none,
    this.right = BorderSide.none,
    this.bottom = BorderSide.none,
    this.left = BorderSide.none,
  });

  BoxBorder.all({String? color, BorderStyle style = BorderStyle.solid})
    : top = BorderSide(color: color, style: style),
      right = BorderSide(color: color, style: style),
      bottom = BorderSide(color: color, style: style),
      left = BorderSide(color: color, style: style);

  const BoxBorder.symmetric({
    BorderSide vertical = BorderSide.none,
    BorderSide horizontal = BorderSide.none,
  }) : top = horizontal,
       bottom = horizontal,
       left = vertical,
       right = vertical;
}

/// An immutable description of how to paint a box.
class BoxDecoration {
  final String? color;
  final BoxBorder? border;

  const BoxDecoration({this.color, this.border});
}
