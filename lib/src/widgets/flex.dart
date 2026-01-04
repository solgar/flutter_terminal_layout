import 'framework.dart';
import 'widget.dart';
import 'container.dart';
import '../rendering/render_object.dart';
import '../rendering/flex.dart';

export '../rendering/flex.dart' show FlexDirection, CrossAxisAlignment;

class Flex extends MultiChildRenderObjectWidget {
  final FlexDirection direction;
  final CrossAxisAlignment crossAxisAlignment;
  final int spacing;

  const Flex({
    super.key,
    super.children,
    required this.direction,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 0,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlex(
      direction: direction,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderFlex renderObject,
  ) {
    renderObject.direction = direction;
    renderObject.crossAxisAlignment = crossAxisAlignment;
    renderObject.spacing = spacing;
  }
}

class Row extends Flex {
  const Row({
    super.key,
    super.children,
    super.crossAxisAlignment,
    super.spacing,
  }) : super(direction: FlexDirection.horizontal);
}

class Column extends Flex {
  const Column({
    super.key,
    super.children,
    super.crossAxisAlignment,
    super.spacing,
  }) : super(direction: FlexDirection.vertical);
}

class Expanded extends SingleChildRenderObjectWidget {
  final int flex;

  const Expanded({super.key, super.child, this.flex = 1});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderExpanded(flex: flex);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderExpanded renderObject,
  ) {
    renderObject.flex = flex;
    // In a real system we would need to mark parent as needing layout if flex changes.
  }
}

class Spacer extends StatelessWidget {
  final int flex;
  const Spacer({super.key, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: Container(width: 0, height: 0));
  }
}
