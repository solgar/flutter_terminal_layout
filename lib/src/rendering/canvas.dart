import '../core/ansi.dart';
import 'geometry.dart';

class Cell {
  String char;
  String? fgColor;
  String? bgColor;

  Cell(this.char, {this.fgColor, this.bgColor});

  Cell.empty() : char = ' ';

  void reset() {
    char = ' ';
    fgColor = null;
    bgColor = null;
  }
}

class Canvas {
  final int width;
  final int height;
  final List<List<Cell>> _buffer;

  Canvas(Size size)
    : width = size.width,
      height = size.height,
      _buffer = List.generate(
        size.height,
        (_) => List.generate(size.width, (_) => Cell.empty()),
      );

  void setCell(int x, int y, String char, {String? fg, String? bg}) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    final cell = _buffer[y][x];
    cell.char = char;
    if (fg != null) cell.fgColor = fg;
    if (bg != null) cell.bgColor = bg;
  }

  void drawText(int x, int y, String text, {String? fg, String? bg}) {
    int a = 3;
    for (int i = 0; i < text.length; i++) {
      setCell(x + i, y, text[i], fg: fg, bg: bg);
    }
  }

  void fillRect(
    int x,
    int y,
    int w,
    int h, {
    String? char,
    String? fg,
    String? bg,
  }) {
    for (int r = y; r < y + h; r++) {
      for (int c = x; c < x + w; c++) {
        setCell(c, r, char ?? ' ', fg: fg, bg: bg);
      }
    }
  }

  /// Renders the canvas to a string for standard output.
  /// Optimized to minimize escape codes? Maybe later.
  /// For now just simple dump.
  String render() {
    final buffer = StringBuffer();
    // Move to top-left
    buffer.write(Ansi.home);

    // We can also just join lines.
    // Assuming we're in raw mode or alternate buffer, we probably want to assume 0,0 is start.

    for (int r = 0; r < height; r++) {
      for (int c = 0; c < width; c++) {
        final cell = _buffer[r][c];
        buffer.write(Ansi.color(cell.char, fg: cell.fgColor, bg: cell.bgColor));
      }
      if (r < height - 1) {
        buffer.write('\r\n');
      }
    }
    return buffer.toString();
  }
}
