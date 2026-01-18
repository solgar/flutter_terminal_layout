import 'dart:typed_data';
import '../core/ansi.dart';
import 'geometry.dart';

class CanvasStats {
  final int changedCells;
  final int totalCells;
  final int bytes;
  CanvasStats({
    required this.changedCells,
    required this.totalCells,
    required this.bytes,
  });
}

class Canvas {
  final int width;
  final int height;
  
  // Stride = 3: [Char+Flags, FG, BG]
  // Char+Flags: 
  //   Bits 0-23: Char Code (Unicode)
  //   Bit 24: isBorder
  static const int _stride = 3;
  static const int _flagBorder = 1 << 24;
  static const int _maskChar = 0xFFFFFF;

  final Int32List _backBuffer;
  final Int32List _frontBuffer;

  CanvasStats? lastStats;

  // Clipping state
  final List<Rect> _clipStack = [];

  Canvas(Size size)
    : width = size.width,
      height = size.height,
      _backBuffer = Int32List(size.width * size.height * _stride),
      _frontBuffer = Int32List(size.width * size.height * _stride);

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
    // 0 represents null color and '\0' char. 
    // We want ' ' (space) as default char.
    // ' ' is 32.
    // Efficient clearing: fill with 0 then set chars? 
    // Or just loop. Int32List fill is fast.
    // We need 32, 0, 0, 32, 0, 0...
    // For now, simple loop is fine or we accept 0 as Space in diff logic.
    // Let's accept 0 as Space in logic to allow fast fillRange.
    _backBuffer.fillRange(0, _backBuffer.length, 0);
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

    final int index = (y * width + x) * _stride;
    
    // Read current state
    final int currentVal = _backBuffer[index];
    final int currentCharCode = currentVal & _maskChar;
    final bool currentIsBorder = (currentVal & _flagBorder) != 0;

    int newCharCode = char.codeUnitAt(0); // Assumes single code unit
    bool newIsBorder = isBorder;

    if (isBorder && currentIsBorder) {
      // Merge logic
      final String currentChar = String.fromCharCode(currentCharCode == 0 ? 32 : currentCharCode);
      final oldMask = _charToMask[currentChar] ?? 0;
      final newMask = _charToMask[char] ?? 0;
      
      if (oldMask != 0 && newMask != 0) {
        final combined = oldMask | newMask;
        final String combinedChar = _maskToChar[combined] ?? char;
        newCharCode = combinedChar.codeUnitAt(0);
      } else {
        newCharCode = char.codeUnitAt(0);
      }
      newIsBorder = true;
    } else if (currentIsBorder && !isBorder && char == ' ') {
      // Painting space over border -> preserve border, only update BG
      if (bg != null) _backBuffer[index + 2] = bg.value;
      return;
    }

    // Write new state
    _backBuffer[index] = newCharCode | (newIsBorder ? _flagBorder : 0);
    if (fg != null) _backBuffer[index + 1] = fg.value;
    if (bg != null) _backBuffer[index + 2] = bg.value;
  }

  void drawText(int x, int y, String text, {Color? fg, Color? bg}) {
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
  String diff() {
    final buffer = StringBuffer();
    // buffer.write(Ansi.hideCursor); // Ensure cursor is hidden during update

    int? currentFg;
    int? currentBg;
    int? currentRow;
    int? currentCol;

    // Helper to emit style change if needed
    void updateStyle(int fg, int bg) {
      if (fg != currentFg) {
        if (fg == 0) { // 0 is null/default
          buffer.write('\x1b[39m'); // Default FG
        } else {
          buffer.write(Color(fg).ansiFg);
        }
        currentFg = fg;
      }
      if (bg != currentBg) {
        if (bg == 0) { // 0 is null/default
          buffer.write('\x1b[49m'); // Default BG
        } else {
          buffer.write(Color(bg).ansiBg);
        }
        currentBg = bg;
      }
    }

    int changedCells = 0;
    final int len = _backBuffer.length;
    
    // Direct buffer iteration
    int x = 0;
    int y = 0;
    
    for (int i = 0; i < len; i += _stride) {
      // Check for changes (unrolled comparison)
      if (_backBuffer[i] != _frontBuffer[i] || 
          _backBuffer[i+1] != _frontBuffer[i+1] || 
          _backBuffer[i+2] != _frontBuffer[i+2]) {
        
        changedCells++;
        
        // Move cursor if not sequential
        if (currentRow != y || currentCol != x) {
          buffer.write(Ansi.moveTo(y + 1, x + 1));
        }

        final int charVal = _backBuffer[i] & _maskChar;
        final int fgVal = _backBuffer[i+1];
        final int bgVal = _backBuffer[i+2];

        updateStyle(fgVal, bgVal);
        
        // 0 (NUL) is treated as Space
        buffer.write(charVal == 0 ? ' ' : String.fromCharCode(charVal));

        // Update state
        currentRow = y;
        currentCol = x + 1;

        // Sync front buffer
        _frontBuffer[i] = _backBuffer[i];
        _frontBuffer[i+1] = _backBuffer[i+1];
        _frontBuffer[i+2] = _backBuffer[i+2];
      }

      x++;
      if (x >= width) {
        x = 0;
        y++;
      }
    }
    
    // Reset styles at the end to be safe?
    if (currentFg != null || currentBg != null) {
      buffer.write(Ansi.reset);
    }

    final output = buffer.toString();
    lastStats = CanvasStats(
      changedCells: changedCells,
      totalCells: width * height,
      bytes: output.length,
    );

    return output;
  }
}
