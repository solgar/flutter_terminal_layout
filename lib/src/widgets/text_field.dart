import 'framework.dart';
import 'widget.dart';
import 'focus.dart'; // Replaces keyboard_listener.dart
import '../core/ansi.dart';
import '../core/keys.dart';
import '../core/events.dart'; // Added for KeyEvent
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
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? decorationPrefix; // e.g. "> "
  final String? placeholder;

  const TextField({
    super.key,
    this.controller,
    this.focusNode,
    this.autofocus = false,
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
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  bool _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final chars = event.bytes;
    bool handled = false;

    setState(() {
      int i = 0;
      bool changed = false;
      while (i < chars.length) {
        // Try to match multi-byte sequences first
        final remaining = chars.sublist(i);

        if (Keys.isArrowUp(remaining)) {
          _moveVertical(-1);
          i += 3;
          handled = true;
          continue;
        } else if (Keys.isArrowDown(remaining)) {
          _moveVertical(1);
          i += 3;
          handled = true;
          continue;
        } else if (Keys.isArrowRight(remaining)) {
          if (_controller.selectionIndex < _controller.text.length) {
            _controller.selectionIndex++;
          }
          i += 3;
          handled = true;
          continue;
        } else if (Keys.isArrowLeft(remaining)) {
          if (_controller.selectionIndex > 0) {
            _controller.selectionIndex--;
          }
          i += 3;
          handled = true;
          continue;
        } else if (Keys.isDelete(remaining)) {
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
          handled = true;
          continue;
        } else if (Keys.isPageUp(remaining) || Keys.isPageDown(remaining)) {
          i += 4;
          handled = true; // Consume but ignore
          continue;
        }

        final char = chars[i];
        final singleCharList = [char];

        if (Keys.isBackspace(singleCharList)) {
          // Backspace
          if (_controller.text.isNotEmpty && _controller.selectionIndex > 0) {
            var newText =
                _controller.text.substring(0, _controller.selectionIndex - 1) +
                _controller.text.substring(_controller.selectionIndex);
            _controller.text = newText;
            _controller.selectionIndex--;
            changed = true;
          }
          handled = true;
        } else if (Keys.isEnter(singleCharList)) {
          // Enter
          widget.onSubmitted?.call(_controller.text);
          handled = true;
        } else if (char >= 32 && char <= 126) {
          // Printable ASCII
          var newText =
              _controller.text.substring(0, _controller.selectionIndex) +
              String.fromCharCode(char) +
              _controller.text.substring(_controller.selectionIndex);
          _controller.text = newText;
          _controller.selectionIndex++;
          changed = true;
          handled = true;
        }
        i++;
      }
      if (changed) {
        widget.onChanged?.call(_controller.text);
      }
    });
    return handled;
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
    
    // Only show cursor if focused
    if (_focusNode.hasFocus) {
      spans.add(
        TextSpan(text: cursorChar, color: Colors.black, backgroundColor: Colors.white),
      );
    } else {
      // If not focused, render character normally (or empty space if at end)
      spans.add(TextSpan(text: cursorChar, color: Colors.white));
    }
    
    spans.add(TextSpan(text: after, color: Colors.white));

    if (text.isEmpty && widget.placeholder != null) {
      spans.add(TextSpan(text: widget.placeholder!, color: Colors.brightBlack));
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKey: _handleKeyEvent,
      child: RichText(text: TextSpan(children: spans)),
    );
  }
}
