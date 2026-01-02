import 'framework.dart';
import 'widget.dart';
import '../rendering/render_object.dart';
import '../rendering/canvas.dart';
import '../core/ansi.dart';
import '../rendering/geometry.dart';

/// An immutable span of text.
class TextSpan {
  final String? text;
  final String? styleFg;
  final String? styleBg;
  final List<TextSpan>? children;

  const TextSpan({this.text, this.styleFg, this.styleBg, this.children});

  /// Flattens the span tree into a list of styled segments for easier rendering.
  void visitChildren(
    void Function(String text, String? fg, String? bg) visitor, {
    String? parentFg,
    String? parentBg,
  }) {
    final effectiveFg = styleFg ?? parentFg;
    final effectiveBg = styleBg ?? parentBg;

    if (text != null) {
      visitor(text!, effectiveFg, effectiveBg);
    }

    if (children != null) {
      for (final child in children!) {
        child.visitChildren(
          visitor,
          parentFg: effectiveFg,
          parentBg: effectiveBg,
        );
      }
    }
  }
}

class RichText extends RenderObjectWidget {
  final TextSpan text;

  const RichText({required this.text});

  @override
  Element createElement() => LeafRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParagraph(text);
  }

  @override
  void updateRenderObject(BuildContext context, RenderParagraph renderObject) {
    renderObject.text = text;
  }
}

class RenderParagraph extends RenderObject {
  TextSpan _text;

  RenderParagraph(this._text);

  TextSpan get text => _text;
  set text(TextSpan value) {
    if (_text == value) return;
    _text = value;
    markNeedsLayout();
  }

  // Computed lines for rendering. Each line is a list of spans (text, fg, bg).
  List<List<_StyledSpan>> _computedLines = [];

  @override
  void performLayout() {
    _computedLines = [];

    // 1. Flatten all spans into a single stream of styled segments
    // This simplifies wrapping logic
    final List<_StyledSpan> segments = [];
    _text.visitChildren((text, fg, bg) {
      if (text.isNotEmpty) {
        segments.add(_StyledSpan(text, fg, bg));
      }
    });

    // 2. Wrap segments into lines
    if (segments.isEmpty) {
      size = Size(0, 1); // Empty line
      return;
    }

    int maxWidth = constraints.maxWidth;
    if (maxWidth == 0 || maxWidth >= 100000) {
      // Unbounded or zero width, assume single line (or no render?)
      // For terminal, usually we have a width. If unbounded, maybe 80?
      // Let's just use a large number if unbounded to effectively disable wrapping
      if (maxWidth >= 100000) maxWidth = 100000;
      if (maxWidth == 0) maxWidth = 1; // Prevent div by zero/stuck
    }

    List<_StyledSpan> currentLine = [];
    int currentWidth = 0;

    for (final segment in segments) {
      String text = segment.text;
      String? fg = segment.fg;
      String? bg = segment.bg;

      while (text.isNotEmpty) {
        int available = maxWidth - currentWidth;
        if (available <= 0) {
          // Line full, push and reset
          _computedLines.add(currentLine);
          currentLine = [];
          currentWidth = 0;
          available = maxWidth;
        }

        if (text.length <= available) {
          // Fits entirely
          currentLine.add(_StyledSpan(text, fg, bg));
          currentWidth += text.length;
          text = '';
        } else {
          // Must split
          String part = text.substring(0, available);
          currentLine.add(_StyledSpan(part, fg, bg));
          _computedLines.add(currentLine);
          currentLine = [];
          currentWidth = 0;
          text = text.substring(available);
        }
      }
    }

    if (currentLine.isNotEmpty) {
      _computedLines.add(currentLine);
    }

    // 3. Set size
    size = Size(maxWidth, _computedLines.length);
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    int startX = offset.dx;
    int y = offset.dy;

    for (final line in _computedLines) {
      int x = startX;
      for (final span in line) {
        canvas.drawText(x, y, span.text, fg: span.fg, bg: span.bg);
        x += span.text.length;
      }
      y++;
    }
  }
}

class _StyledSpan {
  final String text;
  final String? fg;
  final String? bg;
  _StyledSpan(this.text, this.fg, this.bg);
}
