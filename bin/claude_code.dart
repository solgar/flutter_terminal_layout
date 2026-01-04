import 'dart:io';

import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(ClaudeCodeApp());
}

class ClaudeCodeApp extends StatefulWidget {
  const ClaudeCodeApp({super.key});

  @override
  State<ClaudeCodeApp> createState() => _ClaudeCodeAppState();
}

class _ClaudeCodeAppState extends State<ClaudeCodeApp> {
  final List<String> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  bool _thinkingEnabled = false;
  String _pwd = '';

  final List<String> _randomResponses = [
    "I can help with that.",
    "Analyzing the codebase...",
    "Here is the refactored code.",
    "Running tests...",
    "Found 3 errors.",
    "Deployment successful.",
    "Explain line 42?",
    "Processing data...",
    "Configuration updated.",
    "Hello! How can I assist you today?",
  ];
  @override
  void initState() {
    super.initState();
    _pwd = Directory.current.path;
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.add(text);
      _textController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    // Simulate response
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add(
            _randomResponses[Random().nextInt(_randomResponses.length)],
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    // Schedule scroll after build
    Timer(const Duration(milliseconds: 50), () {
      _scrollController.jumpTo(_scrollController.maxScrollExtent);
    });
  }

  void _handleGlobalInput(List<int> chars) {
    // Page Up: ESC [ 5 ~ (27, 91, 53, 126)
    // Page Down: ESC [ 6 ~ (27, 91, 54, 126)

    if (chars.length == 1 && chars[0] == Keys.tab) {
      setState(() => _thinkingEnabled = !_thinkingEnabled);
    } else if (chars.length >= 4 &&
        chars[0] == Keys.esc &&
        chars[1] == Keys.bracket &&
        chars[3] == Keys.tilde) {
      if (chars[2] == Keys.pageUp) {
        // Page Up
        final newOffset = max(
          0.0,
          _scrollController.offset - 5,
        ); // Scroll up 5 lines
        _scrollController.jumpTo(newOffset);
      } else if (chars[2] == Keys.pageDown) {
        // Page Down
        final newOffset = min(
          _scrollController.maxScrollExtent,
          _scrollController.offset + 5,
        );
        _scrollController.jumpTo(newOffset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Color.fromARGB(255, 20, 20, 20);

    return KeyboardListener(
      onKeyEvent: _handleGlobalInput,
      child: Container(
        decoration: BoxDecoration(color: bgColor),
        padding: EdgeInsets.symmetric(horizontal: 1),
        child: Column(
          children: [
            Container(height: 1), // Top margin
            // Chat List (includes Dashboard as header)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: 1 + _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Dashboard(
                      compact: false,
                      currentWorkingDirectory: _pwd,
                    );
                  }

                  // Adjust index for messages
                  int msgIndex = index - 1;

                  if (msgIndex < _messages.length) {
                    // Message Bubble
                    // Even index in list = User, Odd = Bot
                    final bool isUserMessage = (msgIndex % 2 == 0);

                    return Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isUserMessage) ...[
                            Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 45, 45, 45),
                                border: BoxBorder.all(
                                  color: Colors.grey,
                                  style: BorderStyle.rounded,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 1,
                              ),
                              child: Text(
                                _messages[msgIndex],
                                color: Colors.white,
                              ),
                            ),
                          ] else ...[
                            Text(
                              ' Claude: ',
                              color: Color.fromARGB(255, 240, 95, 87),
                            ),
                            Expanded(
                              child: Text(
                                _messages[msgIndex],
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  // Loading Indicator
                  return Container(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Row(
                      children: [
                        Text(
                          ' Claude: ',
                          color: Color.fromARGB(255, 240, 95, 87),
                        ),
                        const Spinner(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // INPUT AREA
            Container(height: 1),
            Container(
              decoration: BoxDecoration(
                border: BoxBorder.all(
                  color: Colors.brightBlack,
                  style: .rounded,
                ),
              ),
              padding: EdgeInsets.all(1),
              child: TextField(
                controller: _textController,
                decorationPrefix: '> ',
                placeholder: 'Try "how does <filepath> work?"',
                onSubmitted: _handleSubmit,
                onChanged: (_) => _scrollToBottom(),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1),
              child: Row(
                children: [
                  Text('? for shortcuts', color: Colors.grey),
                  Spacer(),
                  Text(
                    'Thinking ${_thinkingEnabled ? 'on' : 'off'} (tab to toggle)',
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(height: 1),
          ],
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final bool compact;

  final String currentWorkingDirectory;

  const Dashboard({
    super.key,
    required this.compact,
    required this.currentWorkingDirectory,
  });

  @override
  Widget build(BuildContext context) {
    final accentColorStr = Color.fromARGB(255, 240, 95, 87);

    if (compact) {
      // Minimal header when chat is active
      // "panels should shrink in height... down to some hardcoded value"
      // We'll just show a small header instead of the big panels.
      return Container(
        height: 3,
        decoration: BoxDecoration(
          border: BoxBorder(bottom: BorderSide(color: Colors.darkGray)),
        ),
        alignment: Alignment.center,
        child: Text('Claude Code v2.0.23', color: Colors.grey),
      );
    }

    // Full Dashboard
    return Container(
      height: 25, // Fixed height to allow proper layout inside List item
      child: HPanel(
        children: [
          // LEFT PANEL
          Panel(
            flex: 6,
            title: 'Claude Code v2.0.23',
            titleColor: Colors.white,
            borderColor: accentColorStr,
            borderStyle: BorderStyle.solid,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Text('Welcome back Teresa!', color: Colors.brightWhite),
                Container(height: 1),

                // LOGO
                const PixelArtLogo(),

                Container(height: 1),
                // User Info
                Text('Sonnet 4.5 • Claude Max', color: Colors.grey),
                Text(currentWorkingDirectory, color: Colors.grey),
                Spacer(),
              ],
            ),
          ),

          // RIGHT PANEL
          Panel(
            flex: 4,
            borderColor: accentColorStr,
            borderStyle: BorderStyle.solid,
            padding: EdgeInsets.all(1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tips Header (Content)
                Text('Tips for getting started', color: accentColorStr),
                Container(height: 1),
                // Tips content
                Text('Run /init to create a C...', color: Colors.white),
                Container(height: 1),

                // "Tray" Separator Line
                Row(
                  children: [
                    Text('└', color: Colors.brightBlack),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          border: BoxBorder(
                            bottom: BorderSide(color: Colors.brightBlack),
                          ),
                        ),
                      ),
                    ),
                    Text('┘', color: Colors.brightBlack),
                  ],
                ),

                Container(height: 2),

                // Recent Activity
                Text('Recent activity', color: accentColorStr),
                Text('No recent activity', color: Colors.grey),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PixelArtLogo extends StatelessWidget {
  const PixelArtLogo({super.key});

  @override
  Widget build(BuildContext context) {
    // The "Box with eyes" logo
    final color = Color.fromARGB(255, 240, 95, 87);
    return Column(
      children: [
        Text('  ▄▄▄▄▄▄▄  ', color: color),
        Text('  █ ▀ ▀ █  ', color: color), // Eyes
        Text('  █ ▄▄▄ █  ', color: color), // Mouth/Bottom
      ],
    );
  }
}
