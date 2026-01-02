import 'framework.dart';
import 'widget.dart';
import '../rendering/render_object.dart';
import '../rendering/canvas.dart';
import '../rendering/geometry.dart';
import '../rendering/constraints.dart';

class OverflowBox extends SingleChildRenderObjectWidget {
  final int? minWidth;
  final int? maxWidth;
  final int? minHeight;
  final int? maxHeight;
  final Alignment alignment;

  const OverflowBox({
    super.key,
    super.child,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.alignment = Alignment.center,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderOverflowBox(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      alignment: alignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverflowBox renderObject,
  ) {
    renderObject
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..minHeight = minHeight
      ..maxHeight = maxHeight
      ..alignment = alignment;
  }
}

class RenderOverflowBox extends RenderObject {
  int? minWidth;
  int? maxWidth;
  int? minHeight;
  int? maxHeight;
  Alignment alignment;
  RenderObject? child;

  RenderOverflowBox({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.alignment = Alignment.center,
  });

  set childRenderObject(RenderObject? c) {
    if (child != null) child!.parent = null;
    child = c;
    if (child != null) child!.parent = this;
    markNeedsLayout();
  }

  void add(RenderObject child) {
    this.childRenderObject = child;
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(
        BoxConstraints(
          minWidth: minWidth ?? constraints.minWidth,
          maxWidth: maxWidth ?? constraints.maxWidth,
          minHeight: minHeight ?? constraints.minHeight,
          maxHeight: maxHeight ?? constraints.maxHeight,
        ),
      );
      // OverflowBox sizes itself to constraints? Or child?
      // Standard OverflowBox sizes to constraints (parent size), allowing child to be bigger.
      size = Size(constraints.maxWidth, constraints.maxHeight);

      // Position child?
      // Not strictly necessary in this framework as paint handles offset,
      // but if we had proper layout offset support we'd do it here.
      // For now, we assume child paints at (0,0) relative to us unless aligned.
      // Implementing alignment manually in paint?
      // Or just assume 0,0 for now as we use it for explicit sizing.
    } else {
      size = Size(constraints.maxWidth, constraints.maxHeight);
    }
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    if (child != null) {
      // Calculate alignment offset if child size differs from our size
      // dx = (size.width - child.width) * (alignment.x + 1) / 2
      // alignment 0,0 -> center. -1,-1 -> top left.
      // This framework might not support child.size access easily if not stored?
      // RenderObject has 'size'.
      // Simple offset: 0,0 for now. Using it for fullscreen or fill.
      child!.paint(canvas, offset);
    }
  }
}
