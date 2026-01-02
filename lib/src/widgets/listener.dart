import 'widget.dart';
import 'framework.dart';
import '../rendering/render_object.dart';
import '../rendering/proxy.dart';

class Listener extends SingleChildRenderObjectWidget {
  final PointerEventListener? onPointerDown;

  const Listener({super.key, Widget? child, this.onPointerDown})
    : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPointerListener(onPointerDown: onPointerDown);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderPointerListener renderObject,
  ) {
    renderObject.onPointerDown = onPointerDown;
  }
}
