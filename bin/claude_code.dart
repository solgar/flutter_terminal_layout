import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';
import 'package:flutter_terminal_layout/src/widgets/text_field.dart';

void main() {
  runApp(ClaudeCodeApp());
}

class ClaudeCodeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Ansi.bgRgb(20, 20, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: Ansi.bgRgb(20, 20, 20),
              border: BoxBorder.all(
                color: Ansi.brightRed,
                style: BorderStyle.dashed,
              ),
            ),
            padding: EdgeInsets.all(1),
            child: Container(
              alignment: Alignment.center,
              child: Row(children: [Spacer(), ClaudeHeader(), Spacer()]),
            ),
          ),

          // 2. Main Content (Row)
          Expanded(
            child: Transform.translate(
              offset: Offset(0, -1), // Shift up to overlap header
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Column
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Ansi.bgRgb(20, 20, 20),
                        border: BoxBorder.all(
                          color: Ansi.brightRed,
                          style: BorderStyle.dashed,
                        ),
                      ),
                      padding: EdgeInsets.all(1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Spacer(),
                          Text(
                            'Welcome back Meaghan!',
                            styleFg: Ansi.brightWhite,
                          ),
                          Container(height: 1),
                          PixelArtLogo(),
                          Container(height: 1),
                          Text(
                            'Sonnet 3.5 • Max 20x',
                            styleFg: Ansi.brightBlack,
                          ),
                          Text('/users/m/code/apps', styleFg: Ansi.brightBlack),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),

                  // Right Column
                  Expanded(
                    flex: 1,
                    child: Transform.translate(
                      offset: Offset(
                        -1,
                        0,
                      ), // Shift left to overlap Left Column
                      child: Column(
                        children: [
                          // Recent Activity
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Ansi.bgRgb(20, 20, 20),
                                border: BoxBorder.all(
                                  color: Ansi.brightRed,
                                  style: BorderStyle.dashed,
                                ),
                              ),
                              padding: EdgeInsets.all(1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recent activity',
                                    styleFg: Ansi.brightRed,
                                  ),
                                  RecentActivityRow(
                                    '1m ago',
                                    'Updated project memory',
                                  ),
                                  RecentActivityRow(
                                    '8m ago',
                                    'Updated claw\'d feet',
                                  ),
                                  RecentActivityRow(
                                    '2d ago',
                                    'Add words to spinner',
                                  ),
                                  Text(
                                    '... /resume for more',
                                    styleFg: Ansi.brightBlack,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // What's New
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Ansi.bgRgb(20, 20, 20), // Added color
                                border: BoxBorder.all(
                                  color: Ansi.brightRed,
                                  style: BorderStyle.dashed,
                                ),
                              ),
                              padding: EdgeInsets.all(1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('What\'s new', styleFg: Ansi.brightRed),
                                  Text(
                                    '/agents to create subagents',
                                    styleFg: Ansi.brightWhite,
                                  ),
                                  Text(
                                    '/security-review for review',
                                    styleFg: Ansi.brightWhite,
                                  ),
                                  Text(
                                    'ctrl+b to bg bashes',
                                    styleFg: Ansi.brightWhite,
                                  ),
                                  Text(
                                    '... /help for more',
                                    styleFg: Ansi.brightBlack,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1),

          // 3. Input
          Transform.translate(
            offset: Offset(
              0,
              -2,
            ), // Shift up to overlap Body (Accumulated -1 from Body + -1 for this?)
            child: Container(
              decoration: BoxDecoration(
                color: Ansi.bgRgb(20, 20, 20),
                border: BoxBorder.all(
                  color: Ansi.brightBlack,
                  style: BorderStyle.solid,
                ),
              ),
              padding: EdgeInsets.all(1),
              child: Container(
                child: TextField(
                  decorationPrefix: '> ',
                  placeholder: 'Try "edit < filepath> to ..."',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class recentActivityRow extends StatelessWidget {
  final String time;
  final String desc;
  recentActivityRow(this.time, this.desc);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, child: Text(time, styleFg: Ansi.brightWhite)),
        Text(desc, styleFg: Ansi.brightWhite),
      ],
    );
  }
}

// Helper for Recent Activity
Widget RecentActivityRow(String time, String action) {
  // Simple Row
  return Row(
    children: [
      Container(width: 10, child: Text(time, styleFg: Ansi.brightWhite)),
      Text(action, styleFg: Ansi.brightWhite),
    ],
  );
}

class ClaudeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 1), // Margin
        Text('Claude Code v2.0.0', styleFg: Ansi.brightBlack),
      ],
    );
  }
}

class PixelArtLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Ansi.brightRed; // Brighter Orange/Red
    return Column(
      children: [
        Text('     ██████     ', styleFg: color),
        Text('    ██    ██    ', styleFg: color),
        Text('  ████    ████  ', styleFg: color),
        Text('    ████████    ', styleFg: color),
        Text('    █  █   █    ', styleFg: color),
      ],
    );
  }
}
