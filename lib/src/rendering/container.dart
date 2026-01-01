import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';
import 'constraints.dart';

class RenderContainer extends RenderObject {
  String? color;
  int? width;
  int? height;
  RenderObject? child;

  RenderContainer({this.color, this.width, this.height, this.child}) {
    child?.parent = this;
  }

  @override
  void performLayout() {
    int minW = constraints.minWidth;
    int maxW = constraints.maxWidth;
    int minH = constraints.minHeight;
    int maxH = constraints.maxHeight;

    if (width != null) {
      minW = width!;
      maxW = width!;
    }

    if (height != null) {
      minH = height!;
      maxH = height!;
    }

    minW = minW.clamp(constraints.minWidth, constraints.maxWidth);
    maxW = maxW.clamp(constraints.minWidth, constraints.maxWidth);
    minH = minH.clamp(constraints.minHeight, constraints.maxHeight);
    maxH = maxH.clamp(constraints.minHeight, constraints.maxHeight);

    final effConstraints = BoxConstraints(
      minWidth: minW,
      maxWidth: maxW,
      minHeight: minH,
      maxHeight: maxH,
    );

    if (child != null) {
      child!.layout(effConstraints, parentUsesSize: true);
      size = child!.size;
    } else {
      int w = (width != null)
          ? width!
          : (effConstraints.maxWidth == 100000 ? 0 : effConstraints.maxWidth);
      int h = (height != null)
          ? height!
          : (effConstraints.maxHeight == 100000 ? 0 : effConstraints.maxHeight);

      size = effConstraints.constrain(Size(w, h));
    }

    // Final clamp
    size = constraints.constrain(size);
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    if (color != null) {
      canvas.fillRect(offset.dx, offset.dy, size.width, size.height, bg: color);
    }

    if (child != null) {
      child!.paint(canvas, offset);
    }
  }
}
