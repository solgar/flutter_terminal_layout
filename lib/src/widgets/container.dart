import 'framework.dart';
import 'widget.dart';
import '../rendering/render_object.dart';
import '../rendering/container.dart';
import '../core/ansi.dart';

class Container extends SingleChildRenderObjectWidget {
  final Color? color;
  final BoxDecoration? decoration;
  final int? width;
  final int? height;
  final Alignment? alignment;
  final EdgeInsets? padding;

  const Container({
    super.key,
    super.child,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.padding,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContainer(
      decoration: _getEffectiveDecoration(),
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderContainer renderObject,
  ) {
    renderObject.decoration = _getEffectiveDecoration();
    renderObject.width = width;
    renderObject.height = height;
    renderObject.alignment = alignment;
    renderObject.padding = padding;
  }

  BoxDecoration? _getEffectiveDecoration() {
    if (decoration != null) {
      if (color != null) {
        return BoxDecoration(color: color, border: decoration!.border);
      }
      return decoration;
    }
    if (color != null) {
      return BoxDecoration(color: color);
    }
    return null;
  }
}
