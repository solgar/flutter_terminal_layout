import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';
import 'package:dotenv/dotenv.dart';
import 'mistral_client.dart';
import 'dart:io';

void main() {
  // Load environment variables
  var env = DotEnv(includePlatformEnvironment: true);
  if (File('.env').existsSync()) {
    env.load();
  }
  
  final apiKey = env['MISTRAL_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('Error: MISTRAL_API_KEY environment variable is not set.');
    print('Please set it in your environment or a .env file.');
    print('If using shell variables, make sure to use "export MISTRAL_API_KEY=..."');
    exit(1);
  }

  runApp(MistralApp(apiKey: apiKey));
}

class MistralApp extends StatefulWidget {
  final String apiKey;
  const MistralApp({super.key, required this.apiKey});

  @override
  State<MistralApp> createState() => _MistralAppState();
}

class Message {
  final String role;
  final String content;
  Message(this.role, this.content);
}

class _MistralAppState extends State<MistralApp> {
  late MistralClient _client;
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String _status = 'Ready';

  @override
  void initState() {
    super.initState();
    _client = MistralClient(apiKey: widget.apiKey);
  }

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_isLoading) return;
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message('user', text));
      _textController.clear();
      _isLoading = true;
      _status = 'Thinking...';
    });

    // Auto-scroll to bottom
    _scrollToBottom();

    try {
      final response = await _client.chat(
        model: 'mistral-small-latest',
        messages: _messages
            .where((m) => m.role != 'system')
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
      );

      if (mounted) {
        setState(() {
          _messages.add(Message('assistant', response));
          _isLoading = false;
          _status = 'Ready';
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(Message('system', 'Error: $e'));
          _isLoading = false;
          _status = 'Error';
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    // Basic auto-scroll: Jump to max extent after layout update
    // Since we don't have post-frame callback easily, we can use a small delay or rely on next layout pass?
    // ScrollController.maxScrollExtent is updated during layout.
    // If we trigger rebuild, layout happens.
    // We can try to jump in the next event loop tick?
    Future.delayed(Duration(milliseconds: 50), () {
      if (_scrollController.maxScrollExtent > _scrollController.offset) {
        _scrollController.jumpTo(_scrollController.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.blue,
          height: 3,
          child: Center(
            child: Text('Mistral AI Chat - $_status', color: Colors.white),
          ),
        ),

        // Chat History
        Expanded(
          child: Container(
            color: Colors.black,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Container(
                    padding: const EdgeInsets.all(1),
                    child: Row(
                      children: [
                        Text('Assistant: ', color: Colors.green),
                        Spinner(color: Colors.green),
                      ],
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg.role == 'user';
                final isSystem = msg.role == 'system';

                Color bgColor = isUser ? Colors.darkGray : Colors.black;
                Color fgColor = isUser ? Colors.brightWhite : Colors.white;
                if (isSystem) {
                  bgColor = Colors.red;
                  fgColor = Colors.white;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 1,
                    horizontal: 2,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align left always for now
                    children: [
                      Container(
                        color: bgColor,
                        padding: const EdgeInsets.all(1),
                        child: Text(
                          '${msg.role.toUpperCase()}: ${msg.content}',
                          color: fgColor,
                        ),
                      ),
                      Container(height: 1), // Spacer
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Input Area
        Container(
          height: 3, // Fixed height for input
          color: Colors.darkGray,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  autofocus: true,
                  placeholder: 'Type a message...',
                  onSubmitted: (_) => _sendMessage(),
                  decorationPrefix: '> ',
                ),
              ),
              Button(
                onPressed: _isLoading ? null : _sendMessage,
                color: Colors.green,
                child: Text(' Send ', color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
