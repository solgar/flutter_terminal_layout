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

  void copyFrom(Cell other) {
    char = other.char;
    fgColor = other.fgColor;
    bgColor = other.bgColor;
    isBorder = other.isBorder;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cell &&
        other.char == char &&
        other.fgColor == fgColor &&
        other.bgColor == bgColor &&
        other.isBorder == isBorder;
  }

  @override
  int get hashCode => Object.hash(char, fgColor, bgColor, isBorder);
}

class Canvas {
  final int width;
  final int height;
  final List<List<Cell>> _backBuffer;
  final List<List<Cell>> _frontBuffer;

  // Clipping state
  final List<Rect> _clipStack = [];

  Canvas(Size size)
    : width = size.width,
      height = size.height,
      _backBuffer = List.generate(
        size.height,
        (_) => List.generate(size.width, (_) => Cell.empty()),
      ),
      _frontBuffer = List.generate(
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

  void clear() {
    for (var row in _backBuffer) {
      for (var cell in row) {
        cell.reset();
      }
    }
    _clipStack.clear();
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

    final cell = _backBuffer[y][x];

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

  /// Calculates the difference between the back buffer and the front buffer,
  /// generates optimized ANSI sequences for the updates, and swaps the buffers.
  ///
  /// This implements:
  /// 1. Double Buffering & Diffing: Only changed cells are drawn.
  /// 2. Style Optimization: ANSI codes are only emitted when style changes.
  /// 3. Cursor Optimization: Moves cursor only when necessary.
  String diff() {
    final buffer = StringBuffer();
    // buffer.write(Ansi.hideCursor); // Ensure cursor is hidden during update

    Color? currentFg;
    Color? currentBg;
    int? currentRow;
    int? currentCol;

    // Helper to emit style change if needed
    void updateStyle(Color? fg, Color? bg) {
      if (fg != currentFg) {
        if (fg == null) {
          // If we need to clear FG, we might need reset.
          // Simple approach: Reset all and re-apply BG if needed.
          // Or use default color code if available (39 for FG).
          // For now, let's use full reset if either is null, which is safer but verbose.
          // Optimized: Use specific codes if possible.
          buffer.write('\x1b[39m'); // Default FG
        } else {
          buffer.write(fg.ansiFg);
        }
        currentFg = fg;
      }
      if (bg != currentBg) {
        if (bg == null) {
          buffer.write('\x1b[49m'); // Default BG
        } else {
          buffer.write(bg.ansiBg);
        }
        currentBg = bg;
      }
    }

    // Force style reset at start of batch if we don't track persistent terminal state
    // buffer.write(Ansi.reset);
    // currentFg = null;
    // currentBg = null;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final back = _backBuffer[y][x];
        final front = _frontBuffer[y][x];

        if (back != front) {
          // Cell changed
          // Move cursor if not sequential
          if (currentRow != y || currentCol != x) {
            // Optimization: If it's just next char, no need to move (implicit)
            // But here we are iterating. If x == currentCol + 1, it's sequential.
            // But we only update if changed.
            // If we skipped some chars (because they were identical), we MUST move.
            buffer.write(Ansi.moveTo(y + 1, x + 1));
          }

          updateStyle(back.fgColor, back.bgColor);
          buffer.write(back.char);

          // Update state
          currentRow = y;
          currentCol = x + 1;

          // Sync front buffer
          front.copyFrom(back);
        }
      }
    }
    
    // Reset styles at the end to be safe?
    if (currentFg != null || currentBg != null) {
      buffer.write(Ansi.reset);
    }

    return buffer.toString();
  }
}
