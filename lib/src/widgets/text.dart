import 'framework.dart';
import 'widget.dart';
import '../rendering/render_object.dart';
import '../rendering/text.dart';
import '../core/ansi.dart';

class Text extends RenderObjectWidget {
  final String text;
  final Color? color;
  final Color? backgroundColor;

  const Text(this.text, {super.key, this.color, this.backgroundColor});

  @override
  Element createElement() => LeafRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderText(text, color: color, backgroundColor: backgroundColor);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderText renderObject,
  ) {
    renderObject.text = text;
    renderObject.color = color;
    renderObject.backgroundColor = backgroundColor;
  }
}
