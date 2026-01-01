import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';

class RenderText extends RenderObject {
  String _text;
  String? _styleFg;
  String? _styleBg;

  RenderText(this._text, {String? styleFg, String? styleBg})
    : _styleFg = styleFg,
      _styleBg = styleBg;

  set text(String value) {
    if (_text == value) return;
    _text = value;
  }

  @override
  void performLayout() {
    int width = _text.length;
    int height = 1;

    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    canvas.drawText(offset.dx, offset.dy, _text, fg: _styleFg, bg: _styleBg);
  }
}
