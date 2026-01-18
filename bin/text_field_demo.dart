import 'package:flutterlike_tui/flutterlike_tui.dart';

void main() {
  runApp(const TextFieldDemo());
}

class TextFieldDemo extends StatefulWidget {
  const TextFieldDemo({super.key});

  @override
  State<TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  late FocusNode _rootNode;
  late FocusNode _node1;
  late FocusNode _node2;
  late FocusNode _node3;
  late List<FocusNode> _nodes;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _rootNode = FocusNode(debugLabel: 'Root');
    _node1 = FocusNode(debugLabel: 'First Name');
    _node2 = FocusNode(debugLabel: 'Last Name');
    _node3 = FocusNode(debugLabel: 'Email');
    _nodes = [_node1, _node2, _node3];

    _node1.addListener(_update);
    _node2.addListener(_update);
    _node3.addListener(_update);
    _rootNode.addListener(_update);
    
    // Use microtask to wait for nodes to be attached to the FocusManager
    Future.microtask(() {
      if (mounted) _nodes[_focusedIndex].requestFocus();
    });
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _node1.removeListener(_update);
    _node2.removeListener(_update);
    _node3.removeListener(_update);
    _rootNode.removeListener(_update);
    _rootNode.dispose();
    for (var node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool _handleGlobalKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (Keys.isTab(event.bytes)) {
        setState(() {
          _focusedIndex = (_focusedIndex + 1) % _nodes.length;
          _nodes[_focusedIndex].requestFocus();
        });
        return true;
      }
      
      if (Keys.isEscape(event.bytes)) {
        // Focus root instead of null, so we keep receiving keys
        if (!_rootNode.hasFocus) {
          _rootNode.requestFocus();
          return true;
        }
        return false; // Bubble up (e.g. to exit demo)
      }
      
      // If root has focus (or no field has focus), allow quit
      if (event.character == 'q' && _rootNode.hasFocus) {
         TerminalApp.instance.stop();
         return true;
      }
    }
    return false;
  }

  bool get _anyFieldHasFocus => _nodes.any((n) => n.hasFocus);

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _rootNode,
      onKey: _handleGlobalKey,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Container(
          width: 50,
          height: 25,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: BoxBorder.all(color: Colors.blue, style: BorderStyle.double),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(' Multi-Field Focus Test ', color: Colors.brightCyan),
              Container(height: 1),
              Text('TAB: Cycle. ESC: Unfocus. Q: Quit (if unfocused).', color: Colors.grey),
              Container(height: 2),
              
              Text('First Name:', color: _node1.hasFocus ? Colors.cyan : Colors.white),
              TextField(
                focusNode: _node1,
                autofocus: true,
                placeholder: 'Enter first name...',
                decorationPrefix: '> ',
              ),
              Container(height: 1),
              
              Text('Last Name:', color: _node2.hasFocus ? Colors.cyan : Colors.white),
              TextField(
                focusNode: _node2,
                placeholder: 'Enter last name...',
                decorationPrefix: '> ',
              ),
              Container(height: 1),
              
              Text('Email Address:', color: _node3.hasFocus ? Colors.cyan : Colors.white),
              TextField(
                focusNode: _node3,
                placeholder: 'Enter email...',
                decorationPrefix: '> ',
              ),
              
              Spacer(),
              Text('Focused: ${_nodes[_focusedIndex].debugLabel}', color: Colors.brightBlack),
            ],
          ),
        ),
      ),
    );
  }
}