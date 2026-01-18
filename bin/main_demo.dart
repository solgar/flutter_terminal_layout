import 'dart:math' as math;

import 'package:flutterlike_tui/flutterlike_tui.dart';

import 'border_demo.dart';
import 'button_demo.dart';
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
  final ScrollController _scrollController = ScrollController();

  late final List<MapEntry<String, Widget Function()>> _demos;

  @override
  void initState() {
    super.initState();
    _rootNode = FocusNode(debugLabel: 'Main Menu');
    _rootNode.skipTraversal = true;
    _demos = [
      MapEntry('Border Demo', () => const BorderDemo()),
      MapEntry('Button Demo', () => const ButtonDemo()),
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

  void _scrollToSelection() {
    // Calculate viewport height (must match build logic)
    final termHeight = Terminal.instance.height;
    const int maxH = 25;
    final int dialogH = math.max(10, math.min(maxH, termHeight - 2));

    // Height consumed by non-list items:
    // Top: Spacer(1) + Title(1) + Separator(1) = 3
    // Bottom: Footer(1) + Spacer(1) = 2
    const int bottomOverhead = 2;
    final int viewportHeight = dialogH - 3 - bottomOverhead;

    if (viewportHeight <= 0) return;

    final double currentOffset = _scrollController.offset;

    // Ensure selected index is visible
    if (_selectedIndex < currentOffset) {
      _scrollController.jumpTo(_selectedIndex.toDouble());
    } else if (_selectedIndex >= currentOffset + viewportHeight) {
      _scrollController.jumpTo(
        (_selectedIndex - viewportHeight + 1).toDouble(),
      );
    }
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
        _scrollToSelection();
      });
      return true;
    } else if (Keys.isArrowDown(bytes)) {
      // Down
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _demos.length;
        _scrollToSelection();
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
    Widget content;
    if (_activeDemo != null) {
      content = _activeDemo!;
    } else {
      // Calculate responsive size
      final termWidth = Terminal.instance.width;
      final termHeight = Terminal.instance.height;

      const int maxW = 60;
      const int maxH = 25;

      // Ensure some margin
      final int dialogW = math.max(20, math.min(maxW, termWidth - 4));
      final int dialogH = math.max(10, math.min(maxH, termHeight - 2));

      final int contentW = dialogW - 2; // Inside borders

      content = Center(
        child: Container(
          width: dialogW + 2, // +2 for shadow offset space
          height: dialogH + 1, // +1 for shadow offset space
          child: Stack(
            children: [
              // Shadow
              Positioned(
                left: 2,
                top: 1,
                width: dialogW,
                height: dialogH,
                child: Container(color: Colors.darkGray),
              ),
              // Main Box
              Positioned(
                left: 0,
                top: 0,
                width: dialogW,
                height: dialogH,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: BoxBorder.all(
                      color: Colors.brightBlue,
                      style: BorderStyle.rounded,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(height: 1),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          contentW < 25 ? 'DEMO HUB' : '* TERMINAL DEMO HUB *',
                          color: Colors.brightYellow,
                        ),
                      ),
                      Container(
                        height: 1,
                        child: Center(
                          child: Text('─' * (contentW - 4), color: Colors.blue),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _demos.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == _selectedIndex;
                            final label = _demos[index].key;
                            // Truncate label if too narrow
                            String displayLabel =
                                (isSelected ? '> ' : '  ') + label;
                            if (displayLabel.length > contentW - 2) {
                              displayLabel =
                                  '${displayLabel.substring(0, contentW - 3)}…';
                            }

                            return Container(
                              color: isSelected ? Colors.blue : null,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Text(
                                displayLabel,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.brightWhite,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          children: [
                            Text(
                              contentW < 40
                                  ? '↑/↓/Ent | q:Quit'
                                  : '↑/↓/Enter | Quit: q',
                              color: Colors.grey,
                            ),
                            Spacer(),
                            Text(
                              '${_selectedIndex + 1}/${_demos.length}',
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Focus(
      focusNode: _rootNode,
      autofocus: true,
      onKey: _handleInput,
      child: content,
    );
  }
}
