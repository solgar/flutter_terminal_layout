import 'dart:io';

/// Manages the terminal state.
class Terminal {
  static Terminal? _instance;
  static Terminal get instance {
    if (_instance == null) {
      throw StateError('Terminal is not initialized. Call Terminal() first.');
    }
    return _instance!;
  }

  Terminal() {
    if (_instance != null) {
      throw StateError('Terminal is already initialized.');
    }
    _instance = this;
  }

  // ignore: unused_field
  bool _isRaw = false;

  Stream<List<int>> get input => stdin;

  void enableRawMode() {
    try {
      if (stdin.hasTerminal) {
        // Echo mode: false (don't print keys as they are typed)
        // Line mode: false (send input immediately, don't wait for enter)
        stdin.echoMode = false;
        stdin.lineMode = false;
        _isRaw = true;
      }
    } catch (_) {
      // Ignore if socket closed or not a terminal
    }
  }

  void disableRawMode() {
    try {
      if (stdin.hasTerminal) {
        stdin.echoMode = true;
        stdin.lineMode = true;
        _isRaw = false;
      }
    } catch (_) {
      // Ignore if socket closed or not a terminal
    }
  }

  int get width {
    if (stdout.hasTerminal) {
      try {
        return stdout.terminalColumns;
      } catch (_) {
        return 80; // Fallback if getting size fails despite hasTerminal
      }
    }
    return 80; // Default width when no terminal
  }

  int get height {
    if (stdout.hasTerminal) {
      try {
        return stdout.terminalLines;
      } catch (_) {
        return 24; // Fallback if getting size fails despite hasTerminal
      }
    }
    return 24; // Default height when no terminal
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
