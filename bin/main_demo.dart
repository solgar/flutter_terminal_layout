import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

import 'border_demo.dart';
import 'claude_code.dart';
import 'counter_demo.dart';
import 'cube_demo.dart';
import 'focus_demo.dart';
import 'gemini_app.dart';
import 'layout_demo.dart';
import 'list_demo.dart';
import 'loading_demo.dart';
import 'mouse_app.dart';
import 'text_field_demo.dart';

void main() {
  runApp(const MainDemoApp());
}

class MainDemoApp extends StatefulWidget {
  const MainDemoApp({super.key});

  @override
  State<MainDemoApp> createState() => _MainDemoAppState();
}

class _MainDemoAppState extends State<MainDemoApp> {
  int _selectedIndex = 0;
  Widget? _activeDemo;
  late FocusNode _rootNode;

  late final List<MapEntry<String, Widget Function()>> _demos;

  @override
  void initState() {
    super.initState();
    _rootNode = FocusNode(debugLabel: 'Main Menu');
    _demos = [
      MapEntry('Border Demo', () => const BorderDemo()),
      MapEntry('Claude Code', () => const ClaudeCodeApp()),
      MapEntry('Counter', () => const CounterApp()),
      MapEntry('Cube 3D', () => const CubeApp()),
      MapEntry('Focus Demo', () => const FocusDemo()),
      MapEntry('Gemini TUI', () => const GeminiApp()),
      MapEntry('Layout Demo', () => const DemoApp()),
      MapEntry('List Demo', () => const ListDemoApp()),
      MapEntry('Loading Demo', () => const LoadingDemo()),
      MapEntry('Mouse Demo', () => const MouseApp()),
      MapEntry('TextField Demo', () => const TextFieldDemo()),
    ];
  }

  @override
  void dispose() {
    _rootNode.dispose();
    super.dispose();
  }

  bool _handleInput(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final bytes = event.bytes;

    if (_activeDemo != null) {
      // Check for Escape to go back (if bubbled up)
      if (Keys.isEscape(bytes)) {
        setState(() {
          _activeDemo = null;
          // Re-focus menu when returning
          _rootNode.requestFocus();
        });
        return true;
      }
      return false; // Let active demo handle it (if it has focus logic)
    }

    // Menu Navigation
    if (Keys.isArrowUp(bytes)) {
      // Up
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + _demos.length) % _demos.length;
      });
      return true;
    } else if (Keys.isArrowDown(bytes)) {
      // Down
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _demos.length;
      });
      return true;
    } else if (Keys.isEnter(bytes)) {
      // Enter
      setState(() {
        _activeDemo = _demos[_selectedIndex].value();
      });
      return true;
    } else if (bytes.length == 1 && bytes[0] == Keys.q) {
      // 'q'
      TerminalApp.instance.stop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // If demo is active, we just show it. 
    // It should manage its own focus or bubble up keys to us via parent Focus.
    // We wrap everything in a Root Focus to catch bubbled keys.
    
    Widget content;
    if (_activeDemo != null) {
      content = _activeDemo!;
    } else {
      content = Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Container(
          width: 40,
          height: 20,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: BoxBorder.all(color: Colors.cyan, style: BorderStyle.double),
          ),
          child: Column(
            children: [
              Text('Main Demo Switcher', color: Colors.brightCyan),
              Container(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _demos.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedIndex;
                    final label = _demos[index].key;
                    return Container(
                      color: isSelected ? Colors.blue : null,
                      child: Text(
                        (isSelected ? '> ' : '  ') + label,
                        color: isSelected ? Colors.white : Colors.white,
                      ),
                    );
                  },
                ),
              ),
              Container(height: 1),
              Text(
                'Up/Down/Enter. Esc=Back. q=Quit.',
                color: Colors.brightBlack,
              ),
            ],
          ),
        ),
      );
    }

    return Focus(
      focusNode: _rootNode,
      autofocus: true, // Focus menu on start
      onKey: _handleInput,
      child: content,
    );
  }
}