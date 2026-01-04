import 'widget.dart';
import 'framework.dart';
import '../rendering/render_object.dart';
import '../rendering/proxy.dart';

class Listener extends SingleChildRenderObjectWidget {
  final PointerEventListener? onPointerDown;
  final PointerEventListener? onPointerMove;
  final PointerEventListener? onPointerUp;
  final PointerEventListener? onPointerScroll;

  const Listener({
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerScroll,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPointerListener(
      onPointerDown: onPointerDown,
      onPointerScroll: onPointerScroll,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderPointerListener renderObject,
  ) {
    renderObject.onPointerDown = onPointerDown;
    renderObject.onPointerScroll = onPointerScroll;
  }
}
