import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';
import '../core/ansi.dart';

class RenderText extends RenderObject {
  String _text;
  Color? _color;
  Color? _backgroundColor;

  final List<String> _lines = [];

  RenderText(this._text, {Color? color, Color? backgroundColor})
    : _color = color,
      _backgroundColor = backgroundColor;

  set text(String value) {
    if (_text == value) return;
    _text = value;
    // Mark needing layout? In this simple system, maybe just changing size is enough next frame.
    // In real flutter, markNeedsLayout().
  }

  set color(Color? value) {
    if (_color == value) return;
    _color = value;
  }

  set backgroundColor(Color? value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
  }

  @override
  void performLayout() {
    // Basic wrapping
    final maxWidth = constraints.maxWidth;
    _lines.clear();

    if (maxWidth <= 0) {
      size = constraints.constrain(Size(0, 0));
      return;
    }

    if (_text.isEmpty) {
      size = constraints.constrain(Size(0, 0));
      return;
    }

    // Simple character-based wrapping for now
    // Future improvement: Word-based wrapping
    for (int i = 0; i < _text.length; i += maxWidth) {
      int end = i + maxWidth;
      if (end > _text.length) end = _text.length;
      _lines.add(_text.substring(i, end));
    }

    int width = _lines.isEmpty
        ? 0
        : _lines[0].length; // Simplify: take first line width or max
    // Actually, width should be the max width of all lines
    for (var line in _lines) {
      if (line.length > width) width = line.length;
    }

    int height = _lines.length;

    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    for (int i = 0; i < _lines.length; i++) {
      canvas.drawText(
        offset.dx,
        offset.dy + i,
        _lines[i],
        fg: _color,
        bg: _backgroundColor,
      );
    }
  }
}
