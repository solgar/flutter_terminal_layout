import 'package:flutter_terminal_layout/src/widgets/framework.dart';
import 'package:flutter_terminal_layout/src/widgets/widget.dart';
import '../core/events.dart';

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

  FocusManager? _manager;
  FocusNode? _parent;
  final List<FocusNode> _children = [];

  bool get hasFocus => _manager?.primaryFocus == this;

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
    _primaryFocus = node;
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
    return false;
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

  const Focus({
    super.key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.onKey,
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
    _node = widget.focusNode ?? FocusNode();
    _node._manager = FocusManager.instance;
    // Sync onKey
    if (widget.onKey != null) {
      _node.onKey = widget.onKey;
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
    if (widget.onKey != null) {
      _node.onKey = widget.onKey;
    }
  }

  @override
  void dispose() {
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
