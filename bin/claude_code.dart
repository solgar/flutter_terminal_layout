import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

void main() {
  runApp(ClaudeCodeApp());
}

class ClaudeCodeApp extends StatelessWidget {
  const ClaudeCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = Ansi.bgRgb(20, 20, 20);
    // Peach/Red accent color (True Color)
    final accentColorStr = Ansi.rgb(240, 95, 87);

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
                  titleColor: Ansi.white,
                  borderColor: accentColorStr,
                  borderStyle: BorderStyle.solid,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      Text('Welcome back Teresa!', styleFg: Ansi.brightWhite),
                      Container(height: 1),

                      // LOGO
                      const PixelArtLogo(),

                      Container(height: 1),
                      // User Info
                      Text('Sonnet 4.5 • Claude Max', styleFg: Ansi.grey),
                      Text(
                        '/Users/ttorres/Documents/Competitive Analysis',
                        styleFg: Ansi.grey,
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
                  // Add padding inside the panel content? Panel handles padding default 1.
                  padding: EdgeInsets.only(
                    left: 2,
                    right: 1,
                    top: 1,
                    bottom: 1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tips Header (Content)
                      Text('Tips for getting started', styleFg: accentColorStr),
                      Container(height: 1),
                      // Tips content
                      Text('Run /init to create a C...', styleFg: Ansi.white),
                      Container(height: 1),

                      // "Tray" Separator Line [ └──────┘ ]
                      // Keeping this custom row as it's content-level styling
                      Row(
                        children: [
                          Text('└', styleFg: Ansi.brightBlack),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                border: BoxBorder(
                                  bottom: BorderSide(color: Ansi.brightBlack),
                                ),
                              ),
                            ),
                          ),
                          Text('┘', styleFg: Ansi.brightBlack),
                        ],
                      ),

                      Container(height: 2),

                      // Recent Activity
                      Text('Recent activity', styleFg: accentColorStr),
                      Text('No recent activity', styleFg: Ansi.grey),
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
            height: 3, // Fixed height for input
            decoration: BoxDecoration(
              border: BoxBorder.all(
                color: Ansi.brightBlack,
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
                Text('? for shortcuts', styleFg: Ansi.grey),
                Spacer(),
                Text('Thinking off (tab to toggle)', styleFg: Ansi.grey),
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
    final color = Ansi.rgb(240, 95, 87);
    return Column(
      children: [
        Text('  ▄▄▄▄▄▄▄  ', styleFg: color),
        Text('  █ ▀ ▀ █  ', styleFg: color), // Eyes
        Text('  █ ▄▄▄ █  ', styleFg: color), // Mouth/Bottom
      ],
    );
  }
}
