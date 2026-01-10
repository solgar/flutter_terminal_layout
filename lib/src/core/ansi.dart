import 'colors.dart';

export 'colors.dart';

/// Helper class for ANSI escape codes.
class Ansi {
  static const String esc = '\x1b';

  // Cursor
  static String moveTo(int row, int col) => '$esc[$row;${col}H';
  static const String hideCursor = '$esc[?25l';
  static const String showCursor = '$esc[?25h';
  static const String home = '$esc[H';

  // Screen
  static const String clearScreen = '$esc[2J';
  static const String clearLine = '$esc[2K'; // Clear entire line

  // Alternate Buffer
  static const String enableAltBuffer = '$esc[?1049h';
  static const String disableAltBuffer = '$esc[?1049l';

  // Mouse
  static const String enableMouse = '$esc[?1000h$esc[?1006h';
  static const String disableMouse = '$esc[?1000l$esc[?1006l';

  // Line Wrapping
  static const String enableLineWrap = '$esc[?7h';
  static const String disableLineWrap = '$esc[?7l';

  // Reset
  static const String reset = '$esc[0m';

  // Colors - Backward compatibility helpers (Deprecated)
  // We encourage using Colors.red.ansiFg instead.
  // ... keeping these removed to force refactor is cleaner based on user request.

  /// Generates a colored string.
  static String color(String text, {Color? fg, Color? bg}) {
    final StringBuffer buffer = StringBuffer();
    if (fg != null) buffer.write(fg.ansiFg);
    if (bg != null) buffer.write(bg.ansiBg);
    buffer.write(text);
    if (fg != null || bg != null) buffer.write(reset);
    return buffer.toString();
  }
}
