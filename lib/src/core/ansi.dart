/// Helper class for ANSI escape codes.
class Ansi {
  static const String esc = '\x1b';

  // Cursor
  static String moveTo(int row, int col) => '$esc[${row};${col}H';
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
  // 1000h: Click tracking
  // 1006h: SGR extended coordinates
  static const String enableMouse = '$esc[?1000h$esc[?1006h';
  static const String disableMouse = '$esc[?1000l$esc[?1006l';

  // Colors - Foreground
  static const String reset = '$esc[0m';
  static const String white = '$esc[37m';
  static const String black = '$esc[30m';
  static const String red = '$esc[31m';
  static const String green = '$esc[32m';
  static const String yellow = '$esc[33m';
  static const String blue = '$esc[34m';
  static const String magenta = '$esc[35m';
  static const String cyan = '$esc[36m';
  // static const String white = '$esc[37m'; // Already defined above

  // Bright/Bold Colors
  static const String brightBlack = '$esc[90m'; // Dark Grey
  static const String brightRed = '$esc[91m';
  static const String brightGreen = '$esc[92m';
  static const String brightYellow = '$esc[93m';
  static const String brightBlue = '$esc[94m';
  static const String brightMagenta = '$esc[95m';
  static const String brightCyan = '$esc[96m';
  static const String brightWhite = '$esc[97m';

  // Colors - Background
  static const String bgWhite = '$esc[47m';
  static const String bgBlack = '$esc[40m';
  static const String bgRed = '$esc[41m';
  static const String bgGreen = '$esc[42m';
  static const String bgYellow = '$esc[43m';
  static const String bgBlue = '$esc[44m';
  static const String bgMagenta = '$esc[45m';
  static const String bgCyan = '$esc[46m';

  /// Generates a colored string.
  static String color(String text, {String? fg, String? bg}) {
    final StringBuffer buffer = StringBuffer();
    if (fg != null) buffer.write(fg);
    if (bg != null) buffer.write(bg);
    buffer.write(text);
    if (fg != null || bg != null) buffer.write(reset);
    return buffer.toString();
  }

  // TrueColor (RGB)
  static String rgb(int r, int g, int b) => '$esc[38;2;$r;$g;${b}m';
  static String bgRgb(int r, int g, int b) => '$esc[48;2;$r;$g;${b}m';
}
