import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

Future<void> main() async {
  await runApp(const FocusDemo());
}

class FocusDemo extends StatefulWidget {
  const FocusDemo({super.key});

  @override
  State<FocusDemo> createState() => _FocusDemoState();
}

class _FocusDemoState extends State<FocusDemo> {
  late FocusNode _node1;
  late FocusNode _node2;
  String _log = 'Press 1 or 2 to select box. Press q to quit.';

  @override
  void initState() {
    super.initState();
    _node1 = FocusNode(debugLabel: 'Box 1');
    _node2 = FocusNode(debugLabel: 'Box 2');
  }

  bool _handleGlobalKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.character == '1') {
        _node1.requestFocus();
        setState(() => _log = 'Box 1 Focused type: ${event.bytes}');
        return true;
      }
      if (event.character == '2') {
        _node2.requestFocus();
        setState(() => _log = 'Box 2 Focused type: ${event.bytes}');
        return true;
      }
      if (event.character == 'q') {
        TerminalApp.instance.stop();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKey: _handleGlobalKey,
      child: Container(
        padding: const EdgeInsets.all(1),
        child: Column(
          children: [
            Text('Focus Demo'),
            Text(_log),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildBox(_node1, 'Box 1')),
                  Expanded(child: _buildBox(_node2, 'Box 2')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(FocusNode node, String label) {
    // Note: In real app, we would listen to node changes.
    // Here we rely on parent setState to rebuild us.
    final bool isFocused = node.hasFocus;
    return Focus(
      focusNode: node,
      child: Container(
        color: isFocused ? Colors.blue : Colors.white,
        alignment: Alignment.center,
        child: Text(label, color: isFocused ? Colors.white : Colors.black),
      ),
    );
  }
}
