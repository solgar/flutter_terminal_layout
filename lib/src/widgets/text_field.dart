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
  final String? decorationPrefix; // e.g. "> "
  final String? placeholder;

  const TextField({
    super.key,
    this.controller,
    this.onSubmitted,
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
      for (final char in chars) {
        if (char == 127) {
          // Backspace
          if (_controller.text.isNotEmpty && _controller.selectionIndex > 0) {
            var newText =
                _controller.text.substring(0, _controller.selectionIndex - 1) +
                _controller.text.substring(_controller.selectionIndex);
            _controller.text = newText;
            _controller.selectionIndex--;
          }
        } else if (char == 13) {
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
        }
      }
    });
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
      spans.add(TextSpan(text: widget.decorationPrefix!, styleFg: Ansi.white));
    }
    spans.add(TextSpan(text: before, styleFg: Ansi.white));
    spans.add(
      TextSpan(text: cursorChar, styleFg: Ansi.black, styleBg: Ansi.white),
    );
    spans.add(TextSpan(text: after, styleFg: Ansi.white));

    if (text.isEmpty && widget.placeholder != null) {
      // If text is empty, cursor is a space. We render placeholder after it?
      // Or if cursor is at 0, maybe we should render placeholder starting from cursor position?
      // But cursor is currently "inverted space".
      // Let's just append placeholder for now as a simple solution.
      spans.add(TextSpan(text: widget.placeholder!, styleFg: Ansi.brightBlack));
    }

    return KeyboardListener(
      onKeyEvent: _handleKeyEvent,
      child: RichText(text: TextSpan(children: spans)),
    );
  }
}
