import '../rendering/render_object.dart';
import '../rendering/constraints.dart';
import '../rendering/geometry.dart';
import '../rendering/canvas.dart';
import '../core/terminal.dart';
import 'widget.dart';
import 'dart:io';

abstract class BuildContext {
  Widget get widget;
}

abstract class Element implements BuildContext {
  final Widget widget;
  Element? _parent;

  Element(this.widget);

  void mount(Element? parent) {
    _parent = parent;
  }

  void visitChildren(void Function(Element element) visitor) {}

  RenderObject? get renderObject {
    var current = this;
    while (current is! RenderObjectElement) {
      Element? child;
      current.visitChildren((c) => child = c);
      if (child == null) return null;
      current = child!;
    }
    return (current as RenderObjectElement)._renderObject;
  }
}

class StatelessElement extends Element {
  StatelessElement(StatelessWidget super.widget);

  Element? _child;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    final built = (widget as StatelessWidget).build(this);
    _child = built.createElement();
    _child!.mount(this);
  }

  @override
  void visitChildren(void Function(Element element) visitor) {
    if (_child != null) visitor(_child!);
  }
}

abstract class RenderObjectElement extends Element {
  RenderObjectElement(RenderObjectWidget super.widget);

  RenderObject? _renderObject;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    _renderObject = (widget as RenderObjectWidget).createRenderObject(this);
    if (widget is RenderObjectWidget) {
      (widget as RenderObjectWidget).updateRenderObject(this, _renderObject!);
    }
  }
}

class LeafRenderObjectElement extends RenderObjectElement {
  LeafRenderObjectElement(super.widget);
}

class SingleChildRenderObjectElement extends RenderObjectElement {
  SingleChildRenderObjectElement(SingleChildRenderObjectWidget super.widget);

  Element? _child;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    final widgetChild = (widget as SingleChildRenderObjectWidget).child;
    if (widgetChild != null) {
      _child = widgetChild.createElement();
      _child!.mount(this);

      if (_child!.renderObject != null) {
        if (_renderObject is RenderObject) {
          // We need to attach children.
          // Logic in RenderObject/subclasses handles specific children addition.
          // This framework is simplified.
          // We assume parent is RenderContainer which takes one child.
          // Or we rely on casting.

          // Simplification: We don't auto-attach here because RenderContainer/RenderFlex
          // adds child via specific methods (child=, add()).
          // BUT `mount` is when we build.

          // In Flutter, `updateChild` / `mount` calls `insertRenderObjectChild`.

          // For this prototype:
          // If parent is RenderContainer, set child.
          // If parent is RenderFlex, add child.

          final parentRender = _renderObject!;
          final childRender = _child!.renderObject!;

          // Hacks for the showcase:
          // Reflection or `is` checks.
          // Since we import those types (which creates circular dependency if framework imports specific widgets),
          // WE can't easily check for RenderContainer here without importing 'rendering/container.dart'.
          // BUT `framework.dart` already imports `render_object.dart`.

          // Solution: `RenderObject` generic interface or `dynamic`.
          try {
            (parentRender as dynamic).child = childRender;
          } catch (_) {
            try {
              (parentRender as dynamic).add(childRender);
            } catch (e) {
              // print('Failed to attach child: $e');
            }
          }
        }
      }
    }
  }

  @override
  void visitChildren(void Function(Element element) visitor) {
    if (_child != null) visitor(_child!);
  }
}

class MultiChildRenderObjectElement extends RenderObjectElement {
  MultiChildRenderObjectElement(MultiChildRenderObjectWidget super.widget);

  final List<Element> _children = [];

  @override
  void mount(Element? parent) {
    super.mount(parent);
    for (final widgetChild
        in (widget as MultiChildRenderObjectWidget).children) {
      final childWithElement = widgetChild.createElement();
      _children.add(childWithElement);
      childWithElement.mount(this);

      if (childWithElement.renderObject != null) {
        final parentRender = _renderObject!;
        final childRender = childWithElement.renderObject!;

        try {
          (parentRender as dynamic).add(childRender);
        } catch (e) {
          // print('Failed to attach child to MultiChild: $e');
        }
      }
    }
  }

  @override
  void visitChildren(void Function(Element element) visitor) {
    for (final child in _children) {
      visitor(child);
    }
  }
}

class TerminalApp {
  final Terminal _terminal = Terminal();

  void run(Widget app) {
    final element = app.createElement();
    element.mount(null);

    final rootRenderObject = element.renderObject;
    if (rootRenderObject != null) {
      final width = _terminal.width;
      final height = _terminal.height;

      rootRenderObject.layout(BoxConstraints.tight(Size(width, height)));

      final canvas = Canvas(Size(width, height));
      rootRenderObject.paint(canvas, Offset.zero);

      _terminal.write(canvas.render());
    }
  }
}

void runApp(Widget app) {
  TerminalApp().run(app);
}
