import 'framework.dart';
import 'widget.dart';
import 'container.dart';
import '../rendering/render_object.dart';
import '../rendering/flex.dart';

class Flex extends MultiChildRenderObjectWidget {
  final FlexDirection direction;

  const Flex({super.children, required this.direction});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlex(direction: direction);
  }
}

class Row extends Flex {
  const Row({super.children}) : super(direction: FlexDirection.horizontal);
}

class Column extends Flex {
  const Column({super.children}) : super(direction: FlexDirection.vertical);
}

class Expanded extends SingleChildRenderObjectWidget {
  final int flex;

  const Expanded({super.child, this.flex = 1});

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
  const Spacer({this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: Container());
  }
}
