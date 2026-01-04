import 'framework.dart';
import 'widget.dart';
import 'keyboard_listener.dart';
import '../core/ansi.dart';
import 'rich_text.dart';

typedef ValueChanged<T> = void Function(T value);

class TextEditingController {
  String text;
  int selectionIndex;

  TextEditingController({this.text = ''}) : selectionIndex = text.length;

  void clear() {
    text = '';
    selectionIndex = 0;
  }
}

class TextField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? decorationPrefix; // e.g. "> "
  final String? placeholder;

  const TextField({
    super.key,
    this.controller,
    this.onSubmitted,
    this.onChanged,
    this.decorationPrefix,
    this.placeholder,
  });

  @override
  State<TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> {
  late TextEditingController _controller;
  // bool _hasFocus = true; // Unused for now

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  void _handleKeyEvent(List<int> chars) {
    setState(() {
      int i = 0;
      bool changed = false;
      while (i < chars.length) {
        final char = chars[i];

        if (char == 27) {
          // ANSI Sequence?
          if (i + 2 < chars.length && chars[i + 1] == 91) {
            final code = chars[i + 2];
            if (code == 65) { // Up
              _moveVertical(-1);
              i += 3;
              continue;
            } else if (code == 66) { // Down
              _moveVertical(1);
              i += 3;
              continue;
            } else if (code == 67) { // Right
              if (_controller.selectionIndex < _controller.text.length) {
                _controller.selectionIndex++;
              }
              i += 3;
              continue;
            } else if (code == 68) { // Left
              if (_controller.selectionIndex > 0) {
                _controller.selectionIndex--;
              }
              i += 3;
              continue;
            } else if (code == 51 &&
                i + 3 < chars.length &&
                chars[i + 3] == 126) {
              // Delete (ESC [ 3 ~)
              if (_controller.selectionIndex < _controller.text.length) {
                var newText = _controller.text.substring(
                      0,
                      _controller.selectionIndex,
                    ) +
                    _controller.text.substring(_controller.selectionIndex + 1);
                _controller.text = newText;
                changed = true;
              }
              i += 4;
              continue;
            } else if ((code == 53 || code == 54) &&
                i + 3 < chars.length &&
                chars[i + 3] == 126) {
              // Page Up (5) / Page Down (6) - Ignore
              i += 4;
              continue;
            }
          }
        }

        if (char == 127) {
          // Backspace
          if (_controller.text.isNotEmpty && _controller.selectionIndex > 0) {
            var newText =
                _controller.text.substring(0, _controller.selectionIndex - 1) +
                _controller.text.substring(_controller.selectionIndex);
            _controller.text = newText;
            _controller.selectionIndex--;
            changed = true;
          }
        } else if (char == 13 || char == 10) {
          // Enter
          widget.onSubmitted?.call(_controller.text);
        } else if (char >= 32 && char <= 126) {
          // Printable ASCII
          var newText =
              _controller.text.substring(0, _controller.selectionIndex) +
              String.fromCharCode(char) +
              _controller.text.substring(_controller.selectionIndex);
          _controller.text = newText;
          _controller.selectionIndex++;
          changed = true;
        }
        i++;
      }
      if (changed) {
        widget.onChanged?.call(_controller.text);
      }
    });
  }

  void _moveVertical(int dir) {
    final element = context as Element;
    if (element.renderObject == null) return;
    int width = element.renderObject!.size.width.toInt();
    if (width <= 0) return;

    final prefixLen = widget.decorationPrefix?.length ?? 0;
    final currentVisualIndex = prefixLen + _controller.selectionIndex;

    // Calculate current visual (row, col)
    final row = currentVisualIndex ~/ width;
    final col = currentVisualIndex % width;

    // Target row
    final targetRow = row + dir;
    if (targetRow < 0) {
      // Move to start
      _controller.selectionIndex = 0;
      return;
    }

    int targetVisualIndex = targetRow * width + col;
    
    // Clamp to valid range relative to text
    // We want the cursor to stay on the text part.
    // Minimum visual index is prefixLen (start of text).
    // Maximum visual index is prefixLen + text.length.

    if (targetVisualIndex < prefixLen) {
      targetVisualIndex = prefixLen;
    } else if (targetVisualIndex > prefixLen + _controller.text.length) {
      targetVisualIndex = prefixLen + _controller.text.length;
    }

    _controller.selectionIndex = targetVisualIndex - prefixLen;
  }

  @override
  Widget build(BuildContext context) {
    // Render text with cursor
    String text = _controller.text;
    int idx = _controller.selectionIndex;

    // Safety check
    if (idx > text.length) idx = text.length;
    if (idx < 0) idx = 0;

    String before = text.substring(0, idx);
    String cursorChar = ' ';
    if (idx < text.length) {
      cursorChar = text.substring(idx, idx + 1);
    }
    String after = '';
    if (idx < text.length - 1) {
      after = text.substring(idx + 1);
    } else if (idx == text.length) {
      // Cursor is at end
      after = '';
    }

    final List<TextSpan> spans = [];
    if (widget.decorationPrefix != null) {
      spans.add(TextSpan(text: widget.decorationPrefix!, color: Colors.white));
    }
    spans.add(TextSpan(text: before, color: Colors.white));
    spans.add(
      TextSpan(text: cursorChar, color: Colors.black, backgroundColor: Colors.white),
    );
    spans.add(TextSpan(text: after, color: Colors.white));

    if (text.isEmpty && widget.placeholder != null) {
      // If text is empty, cursor is a space. We render placeholder after it?
      // Or if cursor is at 0, maybe we should render placeholder starting from cursor position?
      // But cursor is currently "inverted space".
      // Let's just append placeholder for now as a simple solution.
      spans.add(TextSpan(text: widget.placeholder!, color: Colors.brightBlack));
    }

    return KeyboardListener(
      onKeyEvent: _handleKeyEvent,
      child: RichText(text: TextSpan(children: spans)),
    );
  }
}
