import '../rendering/render_object.dart';
import '../rendering/geometry.dart';
import '../rendering/canvas.dart';
import '../rendering/constraints.dart';
import '../rendering/proxy.dart';
import '../core/events.dart';
import '../core/terminal.dart';
import '../core/ansi.dart';
import 'widget.dart';
import 'dart:io';
import 'dart:async';

abstract class BuildContext {
  Widget get widget;
}

abstract class Element implements BuildContext {
  Widget widget;
  Element? _parent;
  bool _dirty = true;

  static final List<Element> _dirtyElements = [];
  static void Function()? requestFrame;

  Element(this.widget);

  void mount(Element? parent) {
    _parent = parent;
  }

  void update(covariant Widget newWidget) {
    widget = newWidget;
  }

  void markNeedsBuild() {
    if (!_dirty) {
      _dirty = true;
      _dirtyElements.add(this);
      requestFrame?.call();
    }
  }

  void rebuild() {
    _dirty = false;
    performRebuild();
  }

  void performRebuild();

  Element? updateChild(Element? child, Widget? newWidget, dynamic newSlot) {
    if (newWidget == null) {
      if (child != null) {
        // child.unmount(); // Unmount not implemented
      }
      return null;
    }

    if (child != null) {
      if (child.widget.runtimeType == newWidget.runtimeType) {
        child.update(newWidget);
        return child;
      }
      // child.unmount();
    }

    final newChild = newWidget.createElement();
    newChild.mount(this);
    return newChild;
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

abstract class ComponentElement extends Element {
  ComponentElement(super.widget);
  Element? _child;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    _firstBuild();
  }

  void _firstBuild() {
    rebuild();
  }

  @override
  void performRebuild() {
    final built = build();
    _child = updateChild(_child, built, null);
  }

  Widget build();

  @override
  void visitChildren(void Function(Element element) visitor) {
    if (_child != null) visitor(_child!);
  }
}

class StatelessElement extends ComponentElement {
  StatelessElement(StatelessWidget super.widget);

  @override
  Widget build() => (widget as StatelessWidget).build(this);
}

abstract class State<T extends StatefulWidget> {
  T get widget => _widget!;
  T? _widget;
  BuildContext get context => _element!;
  StatefulElement? _element;
  bool _mounted = false;
  bool get mounted => _mounted;

  void initState() {}
  void didUpdateWidget(covariant T oldWidget) {}
  void dispose() {}

  void setState(void Function() fn) {
    fn();
    _element!.markNeedsBuild();
  }

  Widget build(BuildContext context);
}

class StatefulElement extends ComponentElement {
  StatefulElement(StatefulWidget super.widget) {
    _state = (widget as StatefulWidget).createState();
    _state._element = this;
    _state._widget = widget as dynamic; // Cast to dynamic or T
  }

  late State<StatefulWidget> _state;

  @override
  void mount(Element? parent) {
    // We need state initialized before first build (which happens in super.mount)
    // But super.mount calls _firstBuild -> rebuild -> build.
    // So state must be ready.
    _state._mounted = true;
    _state.initState();
    super.mount(parent);
  }

  @override
  Widget build() => _state.build(this);

  @override
  void update(covariant StatefulWidget newWidget) {
    super.update(newWidget);
    final oldWidget = _state._widget!;
    _state._widget = newWidget as dynamic;
    _state.didUpdateWidget(oldWidget);
    rebuild();
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

  @override
  void update(covariant RenderObjectWidget newWidget) {
    super.update(newWidget);
    performRebuild();
  }

  @override
  void performRebuild() {
    (widget as RenderObjectWidget).updateRenderObject(this, _renderObject!);
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
      _child = updateChild(null, widgetChild, null);
    }
    _attachChildRenderObject();
  }

  @override
  void performRebuild() {
    super.performRebuild();
    _child = updateChild(
      _child,
      (widget as SingleChildRenderObjectWidget).child,
      null,
    );
    _attachChildRenderObject();
  }

  void _attachChildRenderObject() {
    if (_child?.renderObject != null && _renderObject != null) {
      // Simplified attachment logic
      try {
        (_renderObject as dynamic).child = _child!.renderObject;
      } catch (_) {
        try {
          (_renderObject as dynamic).add(_child!.renderObject);
        } catch (_) {}
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
      final childWithElement = updateChild(null, widgetChild, null);
      if (childWithElement != null) {
        _children.add(childWithElement);
      }
    }
    _attachChildrenRenderObjects();
  }

  @override
  void performRebuild() {
    super.performRebuild();
    final childrenWidgets = (widget as MultiChildRenderObjectWidget).children;
    final int oldLen = _children.length;
    final int newLen = childrenWidgets.length;
    final int commonLen = oldLen < newLen ? oldLen : newLen;

    for (int i = 0; i < commonLen; i++) {
      final child = _children[i];
      final newWidget = childrenWidgets[i];
      final updatedChild = updateChild(child, newWidget, null);
      if (updatedChild != null) {
        _children[i] = updatedChild;
      }
    }

    if (oldLen > newLen) {
      _children.removeRange(newLen, oldLen);
    }

    for (int i = oldLen; i < newLen; i++) {
      final newChild = updateChild(null, childrenWidgets[i], null);
      if (newChild != null) {
        _children.add(newChild);
      }
    }
    _attachChildrenRenderObjects();
  }

  void _attachChildrenRenderObjects() {
    // Try to clear first if supported (e.g. RenderFlex now has removeAll)
    try {
      (_renderObject as dynamic).removeAll();
    } catch (_) {}

    for (final child in _children) {
      if (child.renderObject != null) {
        try {
          (_renderObject as dynamic).add(child.renderObject);
        } catch (_) {}
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

  static final StreamController<List<int>> _inputController =
      StreamController<List<int>>.broadcast(sync: true);
  static Stream<List<int>> get onInput => _inputController.stream;

  // Subscriptions
  StreamSubscription? inputSub;
  StreamSubscription? signalSub;

  Future<void> run(Widget app) async {
    _terminal.enableRawMode();

    stdout.write(Ansi.hideCursor);
    stdout.write(Ansi.enableAltBuffer);
    stdout.write(Ansi.enableMouse);

    bool isRestored = false;
    void restoreTerminal() {
      if (isRestored) return;
      isRestored = true;

      // 1. Disable raw mode
      try {
        _terminal.disableRawMode();
      } catch (_) {}

      // 2. Output cleanup sequences
      stdout.write(Ansi.showCursor);
      stdout.write(Ansi.disableAltBuffer);
      stdout.write(Ansi.disableMouse);

      // 3. Force restore via stty (SYNC)
      if (Platform.isLinux || Platform.isMacOS) {
        try {
          Process.runSync('sh', ['-c', 'stty echo icanon < /dev/tty']);
        } catch (_) {}
      }
    }

    try {
      final element = app.createElement();

      int lastFrameTime = 0; // Moved up
      bool isFrameScheduled = false;
      void draw() {
        isFrameScheduled = false;
        lastFrameTime = DateTime.now().millisecondsSinceEpoch;
        // Build dirty elements
        if (Element._dirtyElements.isNotEmpty) {
          for (final dirty in List<Element>.of(Element._dirtyElements)) {
            dirty.rebuild();
          }
          Element._dirtyElements.clear();
        }

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

      final exitCompleter = Completer<void>();

      // Handle system signals (SIGINT)
      signalSub = ProcessSignal.sigint.watch().listen((signal) {
        restoreTerminal();
        exit(0);
      });

      void dispatchPointerEvent(PointerEvent event) {
        final root = element.renderObject;
        if (root == null) return;

        final result = BoxHitTestResult();
        if (root.hitTest(result, position: event.position)) {
          for (final entry in result.path) {
            if (entry.target is RenderPointerListener) {
              (entry.target as RenderPointerListener).handleEvent(event);
            }
          }
        }
      }

      // Handle Input
      inputSub = _terminal.input.listen(
        (input) {
          if (input.contains(3)) {
            if (!exitCompleter.isCompleted) {
              exitCompleter.complete();
            }
            return;
          }

          // Mouse parsing SGR: ESC [ < B ; X ; Y M (Press) or m (Release)
          if (input.length > 3 &&
              input[0] == 27 &&
              input[1] == 91 &&
              input[2] == 60) {
            try {
              final s = String.fromCharCodes(input);
              final RegExp regex = RegExp(r'\x1b\[<(\d+);(\d+);(\d+)([Mm])');
              final match = regex.firstMatch(s);
              if (match != null) {
                final b = int.parse(match.group(1)!);
                final x = int.parse(match.group(2)!);
                final y = int.parse(match.group(3)!);
                final type = match.group(4)!;

                if (type == 'M') {
                  // Press (Button down)
                  // B: 0=Left, 1=Middle, 2=Right
                  // We treat any click as pointer down for now
                  dispatchPointerEvent(
                    PointerDownEvent(position: Offset(x - 1, y - 1)),
                  );
                }
                draw();
                return; // Consume mouse event
              }
            } catch (e) {
              // Parse error, ignore
            }
          }

          _inputController.add(input);
          draw();
        },
        onError: (e) {
          if (!exitCompleter.isCompleted) exitCompleter.complete();
        },
        onDone: () {
          if (!exitCompleter.isCompleted) exitCompleter.complete();
        },
      );

      const int targetFrameMs = 4;

      Element.requestFrame = () {
        if (!isFrameScheduled) {
          isFrameScheduled = true;
          final int now = DateTime.now().millisecondsSinceEpoch;
          final int elapsed = now - lastFrameTime;

          if (elapsed >= targetFrameMs) {
            Timer.run(draw);
          } else {
            Timer(Duration(milliseconds: targetFrameMs - elapsed), draw);
          }
        }
      };

      element.mount(null);
      // Initial draw
      draw();

      // Wait for exit
      await exitCompleter.future;

      await inputSub?.cancel();
      await signalSub?.cancel();
    } catch (e) {
      // print("Error in run loop: $e");
    } finally {
      // 1. Restore terminal (if not already done by signal)
      // Since restoreTerminal is local, we cannot call it easily if we didn't define it outside?
      // Wait, it is in scope!
      restoreTerminal();

      try {
        await inputSub?.cancel();
      } catch (_) {}

      try {
        await signalSub?.cancel();
      } catch (_) {}
    }
  }
}

Future<void> runApp(Widget app) async {
  await TerminalApp().run(app);
}
