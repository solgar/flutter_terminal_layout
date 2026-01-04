import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

void main() {
  runApp(ClaudeCodeApp());
}

class ClaudeCodeApp extends StatelessWidget {
  const ClaudeCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = Color.fromARGB(255, 20, 20, 20);
    // Peach/Red accent color (True Color)
    final accentColorStr = Color.fromARGB(255, 240, 95, 87);

    return Container(
      decoration: BoxDecoration(color: bgColor),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        children: [
          Container(height: 1), // Top margin
          // MAIN CONTENT SPLIT (Using HPanel with titled Panels)
          Expanded(
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
                      Text(
                        '/Users/ttorres/Documents/Competitive Analysis',
                        color: Colors.grey,
                      ),
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

                      // "Tray" Separator Line [ └──────┘ ]
                      // Keeping this custom row as it's content-level styling
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
          ),

          // INPUT AREA (Outside Panel)
          Container(height: 1),
          Container(
            decoration: BoxDecoration(
              border: BoxBorder.all(
                color: Colors.brightBlack,
                style: BorderStyle.solid,
              ),
            ),
            padding: EdgeInsets.all(1),
            child: TextField(
              decorationPrefix: '> ',
              placeholder: 'Try "how does <filepath> work?"',
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: Row(
              children: [
                Text('? for shortcuts', color: Colors.grey),
                Spacer(),
                Text('Thinking off (tab to toggle)', color: Colors.grey),
              ],
            ),
          ),
          Container(height: 1),
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
