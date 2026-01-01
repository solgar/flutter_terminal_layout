import '../rendering/render_object.dart';
import 'framework.dart';

abstract class Widget {
  const Widget();
  Element createElement();
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget();

  @override
  Element createElement() => StatelessElement(this);

  Widget build(BuildContext context);
}

abstract class StatefulWidget extends Widget {
  const StatefulWidget();

  @override
  Element createElement() => StatefulElement(this);

  State createState();
}

abstract class RenderObjectWidget extends Widget {
  const RenderObjectWidget();

  @override
  Element createElement();

  RenderObject createRenderObject(BuildContext context);
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {}
}

class SingleChildRenderObjectWidget extends RenderObjectWidget {
  final Widget? child;
  const SingleChildRenderObjectWidget({this.child});

  @override
  Element createElement() => SingleChildRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    throw UnimplementedError();
  }
}

class MultiChildRenderObjectWidget extends RenderObjectWidget {
  final List<Widget> children;
  const MultiChildRenderObjectWidget({this.children = const []});

  @override
  Element createElement() => MultiChildRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    throw UnimplementedError();
  }
}
