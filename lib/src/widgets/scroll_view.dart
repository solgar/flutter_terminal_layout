import 'framework.dart';
import 'widget.dart';
import 'flex.dart';
import 'listener.dart';
import '../rendering/render_object.dart';
import '../rendering/viewport.dart';
import '../core/events.dart';

class ScrollController {
  double _offset;
  double _maxScrollExtent = 0.0;
  final List<void Function()> _listeners = [];

  ScrollController({double initialScrollOffset = 0.0})
    : _offset = initialScrollOffset;

  double get offset => _offset;
  double get maxScrollExtent => _maxScrollExtent;

  // Internal use
  void setMaxScrollExtent(double value) {
    _maxScrollExtent = value;
  }

  void jumpTo(double value) {
    if (_offset == value) return;
    _offset = value;
    notifyListeners();
  }

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

class Viewport extends SingleChildRenderObjectWidget {
  final double offset;
  final void Function(double)? onLayoutChanged;

  const Viewport({
    super.key,
    super.child,
    this.offset = 0.0,
    this.onLayoutChanged,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderViewport(offset: offset, onLayoutChanged: onLayoutChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderViewport renderObject,
  ) {
    renderObject.offset = offset;
    renderObject.onLayoutChanged = onLayoutChanged;
  }
}

typedef IndexedWidgetBuilder = Widget Function(BuildContext context, int index);

class ListView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final IndexedWidgetBuilder? itemBuilder;
  final int? itemCount;

  const ListView({super.key, required this.children, this.controller})
    : itemBuilder = null,
      itemCount = null;

  const ListView.builder({
    super.key,
    required this.itemBuilder,
    this.itemCount,
    this.controller,
  }) : children = const [];

  @override
  State<ListView> createState() => _ListViewState();
}

class _ListViewState extends State<ListView> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        // We created local one, now switching to external
        // _controller.dispose() ? // We don't have dispose yet
      }
      _controller.removeListener(_onScroll);
      _controller = widget.controller ?? ScrollController();
      _controller.addListener(_onScroll);
    }
  }

  void _onScroll() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children;
    if (widget.itemBuilder != null) {
      // Simple eagerly build everything for now
      // If itemCount is null, we can't really build infinite list yet without real layout logic
      // supporting infinite constraints (which we kinda do but need to stop somewhere).
      // Let's assume itemCount is provided or default to some reasonable limit if not?
      // Flutter requires itemCount for builder unless using slivers.
      // Let's assume non-null itemCount for now.
      final count = widget.itemCount ?? 0;
      children = List.generate(
        count,
        (index) => widget.itemBuilder!(context, index),
      );
    } else {
      children = widget.children;
    }

    return Listener(
      onPointerScroll: (event) {
        if (event is PointerScrollEvent) {
          double newOffset = _controller.offset + event.scrollDelta.dy;
          // Clamp
          if (newOffset < 0) newOffset = 0;
          if (newOffset > _controller.maxScrollExtent) {
            newOffset = _controller.maxScrollExtent;
          }
          _controller.jumpTo(newOffset);
        }
      },
      child: Viewport(
        offset: _controller.offset,
        onLayoutChanged: (max) {
          // Only update if changed to avoid loops?
          if (_controller.maxScrollExtent != max) {
            _controller.setMaxScrollExtent(max);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Fill width
          children: children,
        ),
      ),
    );
  }
}
