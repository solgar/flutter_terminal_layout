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
  final bool Function(FocusNode node, KeyEvent event)? onKey;

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
  /*
  FocusScopeNode? _parent;
  final List<FocusNode> _children = [];
  */

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

  /*
  void _notify() {
    // Notify listeners (ChangeNotifier logic if we add it)
  }
  */

  // Attachment logic
  /*
  BuildContext? _context;
  */
  void attach(BuildContext context, {FocusOnKeyCallback? onKey}) {
    /* _context = context; */
    // Auto-register with manager if found in context?
    // For now we rely on explicit hierarchy or manual registration?
    // Flutter uses Focus widget to attach logic.
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

  /*
  FocusNode? _focusedChild;

  void _setFocusedChild(FocusNode? child) {
    _focusedChild = child;
  }
  */
}

class FocusManager {
  static final FocusManager instance = FocusManager._();
  FocusManager._();

  FocusNode? _primaryFocus;
  FocusNode? get primaryFocus => _primaryFocus;

  /*
  final List<FocusNode> _dirtyNodes = [];
  */

  void _setPrimaryFocus(FocusNode? node) {
    if (_primaryFocus == node) return;
    // final previous = _primaryFocus;
    _primaryFocus = node;

    // Notify changes
    // previous?._notify();
    // node?._notify();
  }

  void _markNeedsUpdate() {
    // schedule microtask?
  }

  // Input dispatch
  bool handleKey(KeyEvent event) {
    if (_primaryFocus != null) {
      // Walk up the tree?
      // For now just dispatch to primary
      if (_primaryFocus!.onKey?.call(_primaryFocus!, event) == true) {
        return true;
      }
    }
    return false;
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
    _node._manager = FocusManager.instance; // Simplified attachment
    if (widget.autofocus && !_didAutofocus) {
      _didAutofocus = true;
      _node.requestFocus();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      // Dipose internal node
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
