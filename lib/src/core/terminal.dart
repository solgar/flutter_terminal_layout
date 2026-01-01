import 'dart:io';

/// Manages the terminal state.
class Terminal {
  bool _isRaw = false;

  void enableRawMode() {
    if (stdin.hasTerminal) {
      // Echo mode: false (don't print keys as they are typed)
      // Line mode: false (send input immediately, don't wait for enter)
      stdin.echoMode = false;
      stdin.lineMode = false;
      _isRaw = true;
    }
  }

  void disableRawMode() {
    if (stdin.hasTerminal) {
      stdin.echoMode = true;
      stdin.lineMode = true;
      _isRaw = false;
    }
  }

  int get width {
    try {
      return stdout.terminalColumns;
    } catch (_) {
      return 80; // Fallback
    }
  }

  int get height {
    try {
      return stdout.terminalLines;
    } catch (_) {
      return 24; // Fallback
    }
  }

  /// Writes string to stdout.
  void write(String text) {
    stdout.write(text);
  }

  /// Writeln to stdout.
  void writeln(String text) {
    stdout.writeln(text);
  }
}
