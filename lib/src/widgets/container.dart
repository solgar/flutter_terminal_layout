import 'framework.dart';
import 'widget.dart';
import '../rendering/render_object.dart';
import '../rendering/container.dart';

import '../rendering/geometry.dart';

class Container extends SingleChildRenderObjectWidget {
  final String? color;
  final int? width;
  final int? height;
  final Alignment? alignment;

  const Container({
    super.child,
    this.color,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContainer(
      color: color,
      width: width,
      height: height,
      alignment: alignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderContainer renderObject,
  ) {
    renderObject.color = color;
    renderObject.width = width;
    renderObject.height = height;
    renderObject.alignment = alignment;
  }
}
