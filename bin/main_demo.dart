import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

import 'border_demo.dart';
import 'claude_code.dart';
import 'counter_demo.dart';
import 'focus_demo.dart';
import 'gemini_app.dart';
import 'layout_demo.dart';
import 'list_demo.dart';
import 'loading_demo.dart';
import 'mouse_app.dart';

class MainDemoApp extends StatefulWidget {
  const MainDemoApp({super.key});

  @override
  State<MainDemoApp> createState() => _MainDemoAppState();
}

class _MainDemoAppState extends State<MainDemoApp> {
  int _selectedIndex = 0;
  Widget? _activeDemo;

  late final List<MapEntry<String, Widget Function()>> _demos;

  @override
  void initState() {
    super.initState();
    _demos = [
      MapEntry('Border Demo', () => const BorderDemo()),
      MapEntry('Claude Code', () => const ClaudeCodeApp()),
      MapEntry('Counter', () => const CounterApp()),
      MapEntry('Focus Demo', () => const FocusDemo()),
      MapEntry('Gemini TUI', () => const GeminiApp()),
      MapEntry('Layout Demo', () => const DemoApp()),
      MapEntry('List Demo', () => const ListDemoApp()),
      MapEntry('Loading Demo', () => const LoadingDemo()),
      MapEntry('Mouse Demo', () => const MouseApp()),
    ];
  }

  void _handleInput(List<int> bytes) {
    if (_activeDemo != null) {
      // Check for Escape to go back
      if (bytes.length == 1 && bytes[0] == 27) {
        setState(() {
          _activeDemo = null;
        });
        // We prevent bubbling/other logic?
        // KeyboardListener doesn't stop propagation in this implementation.
        // It's a passive listener.
        // But since we setState to null, the demo is unmounted immediately.
      }
      return;
    }

    // Menu Navigation
    if (bytes.length == 3 && bytes[0] == 27 && bytes[1] == 91) {
      if (bytes[2] == 65) {
        // Up
        setState(() {
          _selectedIndex = (_selectedIndex - 1 + _demos.length) % _demos.length;
        });
      } else if (bytes[2] == 66) {
        // Down
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % _demos.length;
        });
      }
    } else if (bytes.length == 1) {
      if (bytes[0] == 10 || bytes[0] == 13) {
        // Enter
        setState(() {
          _activeDemo = _demos[_selectedIndex].value();
        });
      } else if (bytes[0] == 113) {
        // 'q'
        TerminalApp.instance.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeDemo != null) {
      // We wrap with KeyboardListener to capture Escape even if demo uses input
      return KeyboardListener(onKeyEvent: _handleInput, child: _activeDemo!);
    }

    return KeyboardListener(
      onKeyEvent: _handleInput,
      child: Container(
        color: Ansi.bgBlack,
        alignment: Alignment.center,
        child: Container(
          width: 40,
          height: 20,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: BoxBorder.all(color: Ansi.cyan, style: BorderStyle.double),
          ),
          child: Column(
            children: [
              Text('Main Demo Switcher', styleFg: Ansi.brightCyan),
              Container(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _demos.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedIndex;
                    final label = _demos[index].key;
                    return Container(
                      color: isSelected ? Ansi.bgBlue : null,
                      child: Text(
                        (isSelected ? '> ' : '  ') + label,
                        styleFg: isSelected ? Ansi.white : Ansi.white,
                      ),
                    );
                  },
                ),
              ),
              Container(height: 1),
              Text(
                'Up/Down/Enter. Esc=Back. q=Quit.',
                styleFg: Ansi.brightBlack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
