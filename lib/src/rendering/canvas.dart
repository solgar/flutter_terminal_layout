import '../core/ansi.dart';
import 'geometry.dart';

class Cell {
  String char;
  Color? fgColor;
  Color? bgColor;
  bool isBorder;

  Cell(this.char, {this.fgColor, this.bgColor, this.isBorder = false});

  Cell.empty() : char = ' ', isBorder = false;

  void reset() {
    char = ' ';
    fgColor = null;
    bgColor = null;
    isBorder = false;
  }
}

class Canvas {
  final int width;
  final int height;
  final List<List<Cell>> _buffer;

  // Clipping state
  List<Rect> _clipStack = [];

  Canvas(Size size)
    : width = size.width,
      height = size.height,
      _buffer = List.generate(
        size.height,
        (_) => List.generate(size.width, (_) => Cell.empty()),
      );

  void save() {
    if (_clipStack.isEmpty) {
      // Assume default clip is full screen
      _clipStack.add(Rect.fromLTWH(0, 0, width, height));
    }
    _clipStack.add(_clipStack.last);
  }

  void restore() {
    if (_clipStack.isNotEmpty) {
      _clipStack.removeLast();
    }
  }

  void clipRect(Rect rect) {
    if (_clipStack.isEmpty) {
      _clipStack.add(Rect.fromLTWH(0, 0, width, height));
    }
    final current = _clipStack.last;
    _clipStack[_clipStack.length - 1] = current.intersect(rect);
  }

  // N=1, E=2, S=4, W=8
  static const Map<String, int> _charToMask = {
    '│': 5,
    '║': 5,
    '╎': 5,
    '─': 10,
    '═': 10,
    '╌': 10,
    '┌': 6,
    '╔': 6,
    '┐': 12,
    '╗': 12,
    '└': 3,
    '╚': 3,
    '┘': 9,
    '╝': 9,
    '├': 7,
    '╠': 7,
    '┤': 13,
    '╣': 13,
    '┬': 14,
    '╦': 14,
    '┴': 11,
    '╩': 11,
    '┼': 15,
    '╬': 15,
  };

  static Map<int, String> get maskToChar => _maskToChar;

  static const Map<int, String> _maskToChar = {
    5: '│', 10: '─',
    6: '┌', 12: '┐', 3: '└', 9: '┘',
    7: '├', 13: '┤', 14: '┬', 11: '┴', 15: '┼',
    // Single lines (fallback)
    1: '│', 4: '│', 2: '─', 8: '─', 0: ' ',
  };

  void setCell(
    int x,
    int y,
    String char, {
    Color? fg,
    Color? bg,
    bool isBorder = false,
  }) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;

    // Check clip
    if (_clipStack.isNotEmpty) {
      if (!_clipStack.last.contains(Offset(x, y))) return;
    }

    final cell = _buffer[y][x];

    if (isBorder && cell.isBorder) {
      // Merge logic
      final oldMask = _charToMask[cell.char] ?? 0;
      final newMask = _charToMask[char] ?? 0;
      if (oldMask != 0 && newMask != 0) {
        final combined = oldMask | newMask;
        cell.char = _maskToChar[combined] ?? char;
      } else {
        cell.char = char; // Non-mergeable border
      }
      cell.isBorder = true;
    } else if (cell.isBorder && !isBorder && char == ' ') {
      // If we are painting space (e.g. background fill) over a border,
      // preserve the border character and only update background.
      // This allows 'transparent' overlaps for border merging.
      if (bg != null) cell.bgColor = bg;
      return;
    } else {
      cell.char = char;
      cell.isBorder = isBorder; // Update flag
    }

    // Determine colors: New color overrides old unless we want to do something smart?
    // User probably wants the newest color.
    if (fg != null) cell.fgColor = fg;
    if (bg != null) cell.bgColor = bg;
  }

  void drawText(int x, int y, String text, {Color? fg, Color? bg}) {
    // Optimization to skip if y is totally out (requires Rect checks of range)
    // For now simple per-char check in setCell works.
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
    Color? fg,
    Color? bg,
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
