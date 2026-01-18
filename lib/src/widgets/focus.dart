import 'package:flutterlike_tui/src/widgets/framework.dart';
import 'package:flutterlike_tui/src/widgets/widget.dart';
import '../core/events.dart';
import '../core/keys.dart';

class FocusNode {
  FocusNode({
    this.debugLabel,
    this.onKey,
    bool skipTraversal = false,
    bool canRequestFocus = true,
  }) : _skipTraversal = skipTraversal,
       _canRequestFocus = canRequestFocus;

  final String? debugLabel;
  // Made mutable to allow Focus widget to update it
  bool Function(FocusNode node, KeyEvent event)? onKey;

  bool _skipTraversal;
  bool get skipTraversal => _skipTraversal;
  set skipTraversal(bool value) {
    if (_skipTraversal != value) {
      _skipTraversal = value;
      _manager?._markNeedsUpdate();
    }
  }

  bool _canRequestFocus;
  bool get canRequestFocus => _canRequestFocus;
  set canRequestFocus(bool value) {
    if (_canRequestFocus != value) {
      _canRequestFocus = value;
      if (hasFocus && !value) {
        unfocus();
      }
    }
  }

  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  FocusManager? _manager;
  FocusNode? _parent;
  final List<FocusNode> _children = [];

  bool get hasFocus => FocusManager.instance.primaryFocus == this;

  void requestFocus() {
    if (canRequestFocus) {
      _manager?._setPrimaryFocus(this);
    }
  }

  void unfocus() {
    if (hasFocus) {
      _manager?._setPrimaryFocus(null);
    }
  }

  void _reparent(FocusNode? newParent) {
    if (_parent == newParent) return;
    _parent?._children.remove(this);
    _parent = newParent;
    _parent?._children.add(this);
    // Inherit manager from parent if not set?
    if (newParent != null && newParent._manager != null) {
      _manager = newParent._manager;
    }
  }
  
  // Clean up
  void dispose() {
    _parent?._children.remove(this);
    if (hasFocus) unfocus();
  }
}

typedef FocusOnKeyCallback = bool Function(FocusNode node, KeyEvent event);

class FocusScopeNode extends FocusNode {
  FocusScopeNode({
    super.debugLabel,
    super.onKey,
    super.skipTraversal,
    super.canRequestFocus,
  });
}

class FocusManager {
  static final FocusManager instance = FocusManager._();
  FocusManager._();

  FocusNode? _primaryFocus;
  FocusNode? get primaryFocus => _primaryFocus;

  void _setPrimaryFocus(FocusNode? node) {
    if (_primaryFocus == node) return;
    final previous = _primaryFocus;
    _primaryFocus = node;
    previous?.notifyListeners();
    _primaryFocus?.notifyListeners();
  }

  void _markNeedsUpdate() {}

  // Input dispatch with bubbling
  bool handleKey(KeyEvent event) {
    FocusNode? current = _primaryFocus;
    while (current != null) {
      if (current.onKey?.call(current, event) == true) {
        return true;
      }
      current = current._parent;
    }

    if (event is KeyDownEvent) {
      if (Keys.isTab(event.bytes)) {
        _nextFocus();
        return true;
      } else if (Keys.isBacktab(event.bytes)) {
        _previousFocus();
        return true;
      }
    }

    return false;
  }

  void _nextFocus() {
    final list = _getFocusList();
    if (list.isEmpty) return;
    final index = list.indexOf(_primaryFocus!);
    // If not found (shouldn't happen if list is derived from root of primary), start at 0
    if (index == -1 || index == list.length - 1) {
      list.first.requestFocus();
    } else {
      list[index + 1].requestFocus();
    }
  }

  void _previousFocus() {
    final list = _getFocusList();
    if (list.isEmpty) return;
    final index = list.indexOf(_primaryFocus!);
    if (index <= 0) {
      list.last.requestFocus();
    } else {
      list[index - 1].requestFocus();
    }
  }

  List<FocusNode> _getFocusList() {
    FocusNode? root = _primaryFocus;
    if (root == null) return [];
    while (root!._parent != null) {
      root = root._parent;
    }

    final list = <FocusNode>[];
    void visit(FocusNode node) {
      if (node.canRequestFocus && !node.skipTraversal) {
        list.add(node);
      }
      for (final child in node._children) {
        visit(child);
      }
    }
    visit(root);
    return list;
  }
}

class _FocusInheritedWidget extends InheritedWidget {
  final FocusNode node;

  const _FocusInheritedWidget({
    required this.node,
    required super.child,
  });

  @override
  bool updateShouldNotify(_FocusInheritedWidget oldWidget) {
    return node != oldWidget.node;
  }
}

class Focus extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;
  final bool autofocus;
  final Function(bool)? onFocusChange;
  final FocusOnKeyCallback? onKey;
  final bool canRequestFocus;
  final bool skipTraversal;
  final String? debugLabel;

  const Focus({
    super.key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.onKey,
    this.canRequestFocus = true,
    this.skipTraversal = false,
    this.debugLabel,
  });

  static FocusNode? of(BuildContext context) {
    final _FocusInheritedWidget? inherited = context
        .dependOnInheritedWidgetOfExactType<_FocusInheritedWidget>();
    return inherited?.node;
  }

  @override
  State<Focus> createState() => _FocusState();
}

class _FocusState extends State<Focus> {
  late FocusNode _node;
  bool _didAutofocus = false;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode(debugLabel: widget.debugLabel);
    _node._manager = FocusManager.instance;
    // Sync properties
    _node.canRequestFocus = widget.canRequestFocus;
    _node.skipTraversal = widget.skipTraversal;
    if (widget.onKey != null) {
      _node.onKey = widget.onKey;
    }
    _node.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (widget.onFocusChange != null) {
      widget.onFocusChange!(_node.hasFocus);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parentNode = Focus.of(context);
    _node._reparent(parentNode);
    
    if (widget.autofocus && !_didAutofocus) {
      _didAutofocus = true;
      _node.requestFocus();
    }
  }
  
  @override
  void didUpdateWidget(Focus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
       // Handle node replacement if needed (complex)
    }
    _node.canRequestFocus = widget.canRequestFocus;
    _node.skipTraversal = widget.skipTraversal;
    if (widget.onKey != null) {
      _node.onKey = widget.onKey;
    }
  }

  @override
  void dispose() {
    _node.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _node.dispose();
    } else {
      // If node was external, just detach from tree, don't dispose
      _node._reparent(null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FocusInheritedWidget(
      node: _node,
      child: widget.child,
    );
  }
}