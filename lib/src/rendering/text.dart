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

    // Split by newlines first
    final paragraphs = _text.split('\n');

    for (var paragraph in paragraphs) {
      // Remove \r if present
      paragraph = paragraph.replaceAll('\r', '');
      
      if (paragraph.isEmpty) {
        _lines.add('');
        continue;
      }

      // Word wrapping logic
      // Split into words, preserving spaces?
      // Simple approach: split by space, reconstruct.
      // Better: iterate.
      
      final words = paragraph.split(' ');
      StringBuffer currentLine = StringBuffer();
      int currentLength = 0;

      for (int i = 0; i < words.length; i++) {
        final word = words[i];
        // If word fits in remaining space
        // Space needed? If not first word.
        int spaceNeeded = currentLength > 0 ? 1 : 0;
        
        if (currentLength + spaceNeeded + word.length <= maxWidth) {
          if (spaceNeeded > 0) {
            currentLine.write(' ');
            currentLength++;
          }
          currentLine.write(word);
          currentLength += word.length;
        } else {
          // Word doesn't fit.
          // If current line is not empty, flush it.
          if (currentLength > 0) {
            _lines.add(currentLine.toString());
            currentLine.clear();
            currentLength = 0;
          }
          
          // Now check if word fits on new line
          if (word.length <= maxWidth) {
            currentLine.write(word);
            currentLength += word.length;
          } else {
            // Word is too long even for a full line. Force break it.
            String remaining = word;
            while (remaining.length > maxWidth) {
              _lines.add(remaining.substring(0, maxWidth));
              remaining = remaining.substring(maxWidth);
            }
            currentLine.write(remaining);
            currentLength += remaining.length;
          }
        }
      }
      // Flush last line of paragraph
      if (currentLength > 0) {
        _lines.add(currentLine.toString());
      }
    }

    int width = _lines.isEmpty
        ? 0
        : _lines.fold(0, (max, line) => line.length > max ? line.length : max);

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
