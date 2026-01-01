import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';
import 'constraints.dart';
import 'dart:math' as math;

enum FlexDirection { horizontal, vertical }

class FlexParentData extends ParentData {
  int? flex;
  Offset offset = Offset.zero;
}

class RenderFlex extends RenderObject {
  final FlexDirection direction;
  final List<RenderObject> children = [];

  RenderFlex({this.direction = FlexDirection.horizontal});

  void add(RenderObject child) {
    children.add(child);
    child.parent = this;
    setupParentData(child);
    child.attach(this);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! FlexParentData) {
      child.parentData = FlexParentData();
    }
  }

  @override
  void performLayout() {
    int totalFlex = 0;
    int allocatedMain = 0;
    int crossSize = 0;

    // 1. Measure non-flex children
    for (final child in children) {
      final pd = child.parentData as FlexParentData;
      if (pd.flex == null || pd.flex == 0) {
        BoxConstraints innerConstraints;
        if (direction == FlexDirection.horizontal) {
          innerConstraints = BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
          );
        } else {
          innerConstraints = BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
          );
        }

        child.layout(innerConstraints, parentUsesSize: true);

        final childSize = child.size;
        allocatedMain += (direction == FlexDirection.horizontal
            ? childSize.width
            : childSize.height);
        crossSize = math.max(
          crossSize,
          direction == FlexDirection.horizontal
              ? childSize.height
              : childSize.width,
        );
      } else {
        totalFlex += pd.flex!;
      }
    }

    // 2. Distribute remaining space
    final maxMain = (direction == FlexDirection.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight);
    final remainingSpace = math.max(0, maxMain - allocatedMain);

    // 3. Layout flex children
    int allocatedFlexParams = 0;
    int currentFlexSpace = 0;

    for (final child in children) {
      final pd = child.parentData as FlexParentData;
      if (pd.flex != null && pd.flex! > 0) {
        allocatedFlexParams += pd.flex!;

        // Calculate target space for *all* flex items up to this one,
        // then subtract what we've already allocated.
        final int targetTotalSpace = (totalFlex > 0)
            ? (remainingSpace * allocatedFlexParams / totalFlex).round()
            : 0;
        final int flexSize = targetTotalSpace - currentFlexSpace;
        currentFlexSpace = targetTotalSpace;

        BoxConstraints innerConstraints;
        if (direction == FlexDirection.horizontal) {
          innerConstraints = BoxConstraints(
            minWidth: flexSize,
            maxWidth: flexSize,
            maxHeight: constraints.maxHeight,
          );
        } else {
          innerConstraints = BoxConstraints(
            maxWidth: constraints.maxWidth,
            minHeight: flexSize,
            maxHeight: flexSize, // Force exact height
          );
        }

        child.layout(innerConstraints, parentUsesSize: true);
        final childSize = child.size;
        crossSize = math.max(
          crossSize,
          direction == FlexDirection.horizontal
              ? childSize.height
              : childSize.width,
        );
      }
    }

    // 4. Set size
    if (direction == FlexDirection.horizontal) {
      int width = (totalFlex > 0) ? constraints.maxWidth : allocatedMain;
      if (width > 10000) width = allocatedMain;

      size = constraints.constrain(Size(width, crossSize));
    } else {
      int height = (totalFlex > 0) ? constraints.maxHeight : allocatedMain;
      if (height > 10000) height = allocatedMain;

      size = constraints.constrain(Size(crossSize, height));
    }

    // 5. Position children
    int offsetMain = 0;
    for (final child in children) {
      final pd = child.parentData as FlexParentData;
      final childSize = child.size;

      if (direction == FlexDirection.horizontal) {
        pd.offset = Offset(offsetMain, 0);
        offsetMain += childSize.width;
      } else {
        pd.offset = Offset(0, offsetMain);
        offsetMain += childSize.height;
      }
    }
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    for (final child in children) {
      final pd = child.parentData as FlexParentData;
      child.paint(canvas, offset + pd.offset);
    }
  }
}

class RenderExpanded extends RenderObject {
  int flex;
  RenderExpanded({required this.flex});

  RenderObject? child;

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = constraints.constrain(Size.zero);
    }
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    child?.paint(canvas, offset);
  }

  @override
  void attach(RenderObject owner) {
    if (parentData is FlexParentData) {
      (parentData as FlexParentData).flex = flex;
    }
  }
}
