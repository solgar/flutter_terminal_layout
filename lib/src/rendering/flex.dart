import 'render_object.dart';
import 'geometry.dart';
import 'canvas.dart';
import 'constraints.dart';
import 'dart:math' as math;

enum FlexDirection { horizontal, vertical }

enum CrossAxisAlignment { start, end, center, stretch }

class FlexParentData extends ParentData {
  int? flex;
  Offset offset = Offset.zero;
}

class RenderFlex extends RenderObject {
  FlexDirection direction;
  CrossAxisAlignment crossAxisAlignment;
  final List<RenderObject> children = [];

  RenderFlex({
    this.direction = FlexDirection.horizontal,
    this.crossAxisAlignment =
        CrossAxisAlignment.start, // Default to start for now
  });

  void add(RenderObject child) {
    if (children.contains(child)) return;
    children.add(child);
    child.parent = this;
    setupParentData(child);
    child.attach(this);
  }

  void removeAll() {
    for (final child in children) {
      child.parent = null;
    }
    children.clear();
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

        // Determine cross-axis constraints
        int minCross = 0;
        int maxCross = (direction == FlexDirection.horizontal)
            ? constraints.maxHeight
            : constraints.maxWidth;

        if (crossAxisAlignment == CrossAxisAlignment.stretch) {
          // If we have a definite size in cross axis, force it.
          // If cross axis is unboundedMain (e.g. Column in ScrollView), stretching might be bad or impossible?
          // For standard cases (Row in Column), we usually have bounds.
          minCross = maxCross;
          // Ideally we should verify constraint is tight or bounded.
          // If maxCross is infinite (unconstrained), stretch does nothing or error?
          // Assuming bounded for terminal layout usually.
        }

        if (direction == FlexDirection.horizontal) {
          innerConstraints = BoxConstraints(
            maxWidth: constraints.maxWidth,
            minHeight: minCross,
            maxHeight: maxCross,
          );
        } else {
          innerConstraints = BoxConstraints(
            minWidth: minCross,
            maxWidth: maxCross,
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

        // Determine cross-axis constraints
        int minCross = 0;
        int maxCross = (direction == FlexDirection.horizontal)
            ? constraints.maxHeight
            : constraints.maxWidth;

        if (crossAxisAlignment == CrossAxisAlignment.stretch) {
          minCross = maxCross;
        }

        BoxConstraints innerConstraints;
        if (direction == FlexDirection.horizontal) {
          innerConstraints = BoxConstraints(
            minWidth: flexSize,
            maxWidth: flexSize,
            minHeight: minCross,
            maxHeight: maxCross,
          );
        } else {
          innerConstraints = BoxConstraints(
            minWidth: minCross,
            maxWidth: maxCross,
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
      // If expanding or stretch, we might take full cross height?
      // If crossAxisAlignment is stretch, and we have tight constraint, we are that height.
      // Else we are max(children).
      // If parent gave us tight height, we are that height regardless.
      // constraints.constrain() will handle tight constraints.

      int width = (totalFlex > 0) ? constraints.maxWidth : allocatedMain;
      if (width > 10000) width = allocatedMain;

      // If stretch, crossSize should be constraints.maxHeight?
      // But crossSize was calculated from children. If we stretched, children are that size.
      // Note: if children are stretched, crossSize == maxCross == constraints.maxHeight.

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

      int crossOffset = 0;
      if (crossAxisAlignment == CrossAxisAlignment.center) {
        crossOffset =
            ((crossSize -
                        (direction == FlexDirection.horizontal
                            ? childSize.height
                            : childSize.width)) /
                    2)
                .round();
      } else if (crossAxisAlignment == CrossAxisAlignment.end) {
        crossOffset =
            crossSize -
            (direction == FlexDirection.horizontal
                ? childSize.height
                : childSize.width);
      }

      if (direction == FlexDirection.horizontal) {
        pd.offset = Offset(offsetMain, crossOffset);
        offsetMain += childSize.width;
      } else {
        pd.offset = Offset(crossOffset, offsetMain);
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

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // 1. Check bounds
    // Note: RenderFlex size is set in performLayout.
    if (position.dx < 0 ||
        position.dx >= size.width ||
        position.dy < 0 ||
        position.dy >= size.height) {
      return false;
    }

    // 2. Test children (reverse order usually for Z-order, but simplified here)
    for (int i = children.length - 1; i >= 0; i--) {
      final child = children[i];
      final pd = child.parentData as FlexParentData;
      // Convert position to child's local coordinate system
      final childPosition = position - pd.offset;
      if (child.hitTest(result, position: childPosition)) {
        result.add(BoxHitTestEntry(this));
        return true;
      }
    }

    // 3. Hit self
    result.add(BoxHitTestEntry(this));
    return true;
  }
}

class RenderExpanded extends RenderObject {
  int flex;
  RenderExpanded({required this.flex});

  RenderObject? _child;
  RenderObject? get child => _child;
  set child(RenderObject? value) {
    if (_child != null) _child!.parent = null;
    _child = value;
    if (_child != null) {
      _child!.parent = this;
      _child!.attach(this);
    }
  }

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
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Expanded is just a wrapper, usually same size as child.
    // Check bounds?
    if (child != null) {
      // Expanded delegates to child, usually assumes offset 0,0 locally
      if (child!.hitTest(result, position: position)) {
        result.add(BoxHitTestEntry(this));
        return true;
      }
    }
    return false;
  }

  @override
  void attach(RenderObject owner) {
    if (parentData is FlexParentData) {
      (parentData as FlexParentData).flex = flex;
    }
  }
}
