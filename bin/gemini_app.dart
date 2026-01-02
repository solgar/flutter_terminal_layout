import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';
// RichText is exported by flutter_terminal_layout, but if it causes conflict or is needed explicitly:
// import 'package:flutter_terminal_layout/src/widgets/rich_text.dart';

class GeminiApp extends StatefulWidget {
  @override
  State<GeminiApp> createState() => _GeminiAppState();
}

class _GeminiAppState extends State<GeminiApp> {
  // Hardcoded ASCII Art for "GEMINI"
  final List<String> _logoArt = [
    '  ██████  ███████ ███    ███ ██ ███    ██ ██ ',
    ' ██       ██      ████  ████ ██ ████   ██ ██ ',
    ' ██   ███ █████   ██ ████ ██ ██ ██ ██  ██ ██ ',
    ' ██    ██ ██      ██  ██  ██ ██ ██  ██ ██ ██ ',
    '  ██████  ███████ ██      ██ ██ ██   ████ ██ ',
  ];

  @override
  Widget _buildLogoLine(String text) {
    // Gradient logic: Blue -> Pink
    // Start: #4285F4 (Google Blue) -> (66, 133, 244)
    // End: #FF66AA (Pink) -> (255, 102, 170)

    List<TextSpan> spans = [];
    int len = text.length;
    if (len == 0) return RichText(text: TextSpan(text: ''));

    for (int i = 0; i < len; i++) {
      double t = i / len;
      // Lerp
      int r = (66 + (255 - 66) * t).toInt();
      int g = (133 + (102 - 133) * t).toInt();
      int b = (244 + (170 - 244) * t).toInt();

      spans.add(TextSpan(text: text[i], styleFg: Ansi.rgb(r, g, b)));
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    // Custom colors using RGB
    final grey = Ansi.rgb(150, 150, 150);
    final darkGrey = Ansi.rgb(100, 100, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Logo Section
        ..._logoArt.map((line) => _buildLogoLine(line)).toList(),

        Container(height: 1), // Replacement for SizedBox
        // 2. Tips Section
        Text('Tips for getting started:', styleFg: Ansi.white),
        Text('1. /help for more information.', styleFg: grey),
        Text(
          '2. Ask coding questions, edit code or run commands.',
          styleFg: grey,
        ),
        Text('3. Be specific for the best results.', styleFg: grey),

        Container(height: 2), // Replacement for SizedBox
        // 3. Status Bar
        Row(
          children: [
            Text(
              'Using 1 GEMINI.md file and 1 MCP server (Ctrl+T to view descriptions)',
              styleFg: darkGrey,
            ),
            Spacer(),
            Text('YOLO mode (ctrl + y to toggle)', styleFg: Ansi.red),
          ],
        ),

        Container(height: 1), // Replacement for SizedBox
        // 4. Input Box
        // 4. Input Box
        Container(
          decoration: BoxDecoration(
            border: BoxBorder.all(color: Ansi.blue, style: BorderStyle.rounded),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.all(1),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(
                    text:
                        'Can you find and download the style guide that Google uses for JS? Save it in this projec',
                  ),
                  decorationPrefix: '> ',
                ),
              ),
            ],
          ),
        ),

        Spacer(),

        // 5. Footer
        Row(
          children: [
            Text('~/code/research-apps/voice-notes-app ', styleFg: Ansi.cyan),
            Text('(main*)', styleFg: grey),
            Text('no sandbox ', styleFg: Ansi.red),
            Text('(see docs) ', styleFg: grey),
            Spacer(),
            Text('gemini-2.5-pro-preview-06-05 ', styleFg: Ansi.blue),
            Text('(100% context left)', styleFg: grey),
          ],
        ),
      ],
    );
  }
}
