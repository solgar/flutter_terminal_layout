
const String _esc = '\x1b';

/// A color in the terminal.
class Color {
  /// A 32 bit value representing this color.
  ///
  /// Bits 24-31 are the alpha value.
  /// Bits 16-23 are the red value.
  /// Bits 8-15 are the green value.
  /// Bits 0-7 are the blue value.
  final int value;

  const Color(this.value);

  /// Construct a color from the lower 8 bits of four integers.
  const Color.fromARGB(int a, int r, int g, int b)
      : value = (((a & 0xff) << 24) |
                ((r & 0xff) << 16) |
                ((g & 0xff) << 8) |
                ((b & 0xff) << 0)) &
            0xFFFFFFFF;

  const Color.fromRGBO(int r, int g, int b, double opacity)
      : value = ((((opacity * 0xff ~/ 1) & 0xff) << 24) |
                ((r & 0xff) << 16) |
                ((g & 0xff) << 8) |
                ((b & 0xff) << 0)) &
            0xFFFFFFFF;

  int get alpha => (value >> 24) & 0xFF;
  int get red => (value >> 16) & 0xFF;
  int get green => (value >> 8) & 0xFF;
  int get blue => value & 0xFF;

  /// Returns the ANSI escape sequence to set this color as the Foreground.
  /// Default implementation returns TrueColor (RGB) sequence.
  String get ansiFg => '$_esc[38;2;$red;$green;${blue}m';

  /// Returns the ANSI escape sequence to set this color as the Background.
  /// Default implementation returns TrueColor (RGB) sequence.
  String get ansiBg => '$_esc[48;2;$red;$green;${blue}m';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Color && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Color(0x${value.toRadixString(16).padLeft(8, '0')})';
}

/// A color that maps directly to a standard ANSI color index.
class AnsiColor extends Color {
  /// The ANSI color index (0-7).
  final int index;

  /// Whether this is a bright/bold version of the color.
  final bool isBright;

  const AnsiColor(super.value, this.index, {this.isBright = false});

  @override
  String get ansiFg => isBright ? '$_esc[9${index}m' : '$_esc[3${index}m';

  @override
  String get ansiBg => isBright ? '$_esc[10${index}m' : '$_esc[4${index}m';
}

/// Standard colors commonly available in terminals.
class Colors {
  Colors._();

  // Standard Colors
  static const Color black = AnsiColor(0xFF000000, 0);
  static const Color red = AnsiColor(0xFFCD3131, 1);
  static const Color green = AnsiColor(0xFF0DBC79, 2);
  static const Color yellow = AnsiColor(0xFFE5E510, 3);
  static const Color blue = AnsiColor(0xFF2472C8, 4);
  static const Color magenta = AnsiColor(0xFFBC3FBC, 5);
  static const Color cyan = AnsiColor(0xFF11A8CD, 6);
  static const Color white = AnsiColor(0xFFE5E5E5, 7);

  // Bright Colors
  static const Color brightBlack = AnsiColor(0xFF666666, 0, isBright: true);
  static const Color grey = brightBlack;
  static const Color darkGray = brightBlack;
  static const Color brightRed = AnsiColor(0xFFF14C4C, 1, isBright: true);
  static const Color brightGreen = AnsiColor(0xFF23D18B, 2, isBright: true);
  static const Color brightYellow = AnsiColor(0xFFF5F543, 3, isBright: true);
  static const Color brightBlue = AnsiColor(0xFF3B8EEA, 4, isBright: true);
  static const Color brightMagenta = AnsiColor(0xFFD670D6, 5, isBright: true);
  static const Color brightCyan = AnsiColor(0xFF29B8DB, 6, isBright: true);
  static const Color brightWhite = AnsiColor(0xFFFFFFFF, 7, isBright: true);
  
  static const Color transparent = Color(0x00000000);
}
