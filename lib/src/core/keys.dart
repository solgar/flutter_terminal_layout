/// Common ASCII and ANSI key codes for input handling.
///
/// Includes standard C0 control codes, printable ASCII characters, and common
/// values used in ANSI escape sequences.
class Keys {
  // --- C0 Control Codes (0-31) ---
  static const int nul = 0;
  static const int soh = 1; // Ctrl+A
  static const int stx = 2; // Ctrl+B
  static const int etx = 3; // Ctrl+C
  static const int eot = 4; // Ctrl+D
  static const int enq = 5; // Ctrl+E
  static const int ack = 6; // Ctrl+F
  static const int bel = 7; // Ctrl+G
  static const int bs = 8;  // Ctrl+H (Backspace standard ASCII)
  static const int ht = 9;  // Ctrl+I (Tab)
  static const int lf = 10; // Ctrl+J (Line Feed / Newline)
  static const int vt = 11; // Ctrl+K
  static const int ff = 12; // Ctrl+L
  static const int cr = 13; // Ctrl+M (Carriage Return / Enter)
  static const int so = 14; // Ctrl+N
  static const int si = 15; // Ctrl+O
  static const int dle = 16; // Ctrl+P
  static const int dc1 = 17; // Ctrl+Q
  static const int dc2 = 18; // Ctrl+R
  static const int dc3 = 19; // Ctrl+S
  static const int dc4 = 20; // Ctrl+T
  static const int nak = 21; // Ctrl+U
  static const int syn = 22; // Ctrl+V
  static const int etb = 23; // Ctrl+W
  static const int can = 24; // Ctrl+X
  static const int em = 25;  // Ctrl+Y
  static const int sub = 26; // Ctrl+Z
  static const int esc = 27; // Escape
  static const int fs = 28;
  static const int gs = 29;
  static const int rs = 30;
  static const int us = 31;

  // --- Common Aliases ---
  static const int ctrlC = etx;
  static const int ctrlD = eot;
  static const int tab = ht;
  static const int newline = lf;
  static const int enter = cr;
  
  /// The Delete character (127).
  /// Note: Many terminals send this code when the Backspace key is pressed.
  static const int del = 127;
  static const int backspace = 127; // Alias for project convention

  // --- Printable ASCII (32-126) ---
  static const int space = 32;
  static const int exclamation = 33; // !
  static const int doubleQuote = 34; // "
  static const int hash = 35; // #
  static const int dollar = 36; // $
  static const int percent = 37; // %
  static const int ampersand = 38; // &
  static const int singleQuote = 39; // '
  static const int lParen = 40; // (
  static const int rParen = 41; // )
  static const int asterisk = 42; // *
  static const int plus = 43; // +
  static const int comma = 44; // ,
  static const int minus = 45; // -
  static const int dot = 46; // .
  static const int slash = 47; // /

  // Digits
  static const int zero = 48;
  static const int one = 49;
  static const int two = 50;
  static const int three = 51;
  static const int four = 52;
  static const int five = 53;
  static const int six = 54;
  static const int seven = 55;
  static const int eight = 56;
  static const int nine = 57;

  static const int colon = 58; // :
  static const int semicolon = 59; // ;
  static const int lessThan = 60; // <
  static const int equals = 61; // =
  static const int greaterThan = 62; // >
  static const int question = 63; // ?
  static const int at = 64; // @

  // Uppercase Letters
  static const int A = 65;
  static const int B = 66;
  static const int C = 67;
  static const int D = 68;
  static const int E = 69;
  static const int F = 70;
  static const int G = 71;
  static const int H = 72;
  static const int I = 73;
  static const int J = 74;
  static const int K = 75;
  static const int L = 76;
  static const int M = 77;
  static const int N = 78;
  static const int O = 79;
  static const int P = 80;
  static const int Q = 81;
  static const int R = 82;
  static const int S = 83;
  static const int T = 84;
  static const int U = 85;
  static const int V = 86;
  static const int W = 87;
  static const int X = 88;
  static const int Y = 89;
  static const int Z = 90;

  static const int lBracket = 91; // [
  static const int backslash = 92; // \
  static const int rBracket = 93; // ]
  static const int caret = 94; // ^
  static const int underscore = 95; // _
  static const int backtick = 96; // `

  // Lowercase Letters
  static const int a = 97;
  static const int b = 98;
  static const int c = 99;
  static const int d = 100;
  static const int e = 101;
  static const int f = 102;
  static const int g = 103;
  static const int h = 104;
  static const int i = 105;
  static const int j = 106;
  static const int k = 107;
  static const int l = 108;
  static const int m = 109;
  static const int n = 110;
  static const int o = 111;
  static const int p = 112;
  static const int q = 113;
  static const int r = 114;
  static const int s = 115;
  static const int t = 116;
  static const int u = 117;
  static const int v = 118;
  static const int w = 119;
  static const int x = 120;
  static const int y = 121;
  static const int z = 122;

  static const int lBrace = 123; // {
  static const int pipe = 124; // |
  static const int rBrace = 125; // }
  static const int tilde = 126; // ~

  // --- ANSI / Xterm Escape Sequence Suffixes ---
  // Note: These values appear in escape sequences like ESC [ <Value>
  
  // Arrow Keys (when following ESC [)
  static const int arrowUp = A;
  static const int arrowDown = B;
  static const int arrowRight = C;
  static const int arrowLeft = D;

  // Common characters used in CSI sequences
  static const int bracket = lBracket; // [ (91)
  
  // Navigation & Editing (often part of sequences like ESC [ 3 ~)
  // These are the digits used in the sequence, not the raw bytes 0-9 unless parsed as such.
  // However, in "ESC [ 5 ~", the byte is '5' (53).
  static const int insert = 50; // '2'
  static const int delete = 51; // '3'
  static const int home = 49; // '1' (sometimes 7 or H)
  // static const int end = 52; // '4' (sometimes 8 or F) - varies widely
  
  static const int pageUp = 53; // '5'
  static const int pageDown = 54; // '6'
}

/// Mouse button codes extracted from SGR mouse events.
class MouseButtons {
  static const int left = 0;
  static const int middle = 1;
  static const int right = 2;
  
  // Scroll directions in SGR mode are encoded as buttons
  static const int scrollUp = 64;
  static const int scrollDown = 65;
}