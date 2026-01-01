import 'framework.dart';
import 'widget.dart';
import '../rendering/render_object.dart';
import '../rendering/text.dart';

class Text extends RenderObjectWidget {
  final String text;
  final String? styleFg;
  final String? styleBg;

  const Text(this.text, {this.styleFg, this.styleBg});

  @override
  Element createElement() => LeafRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderText(text, styleFg: styleFg, styleBg: styleBg);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderText renderObject,
  ) {
    renderObject.text = text;
  }
}
