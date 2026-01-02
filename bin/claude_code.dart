import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

void main() {
  runApp(ClaudeCodeApp());
}

class ClaudeCodeApp extends StatelessWidget {
  const ClaudeCodeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Ansi.bgRgb(20, 20, 20)),
      child: Column(
        children: [
          Expanded(
            child: VPanel(
              children: [
                // 1. Header
                Panel(
                  height: 3,
                  borderColor: Ansi.brightRed,
                  borderStyle: BorderStyle.dashed,
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(children: [Spacer(), ClaudeHeader(), Spacer()]),
                  ),
                ),

                // 2. Main Content
                HPanel(
                  flex: 1,
                  children: [
                    // Left Column
                    Panel(
                      flex: 1,
                      borderColor: Ansi.brightRed,
                      borderStyle: BorderStyle.dashed,
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

                    // Right Column
                    VPanel(
                      flex: 1,
                      children: [
                        // Recent Activity
                        Panel(
                          flex: 1,
                          borderColor: Ansi.brightRed,
                          borderStyle: BorderStyle.dashed,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recent activity', styleFg: Ansi.brightRed),
                              _buildRecentActivityRow(
                                '1m ago',
                                'Updated project memory',
                              ),
                              _buildRecentActivityRow(
                                '8m ago',
                                'Updated claw\'d feet',
                              ),
                              _buildRecentActivityRow(
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

                        // What's New
                        Panel(
                          flex: 1,
                          borderColor: Ansi.brightRed,
                          borderStyle: BorderStyle.dashed,
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
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Input
          Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              border: BoxBorder.all(
                color: Ansi.brightBlack,
                style: BorderStyle.solid,
              ),
            ),
            child: TextField(
              decorationPrefix: '> ',
              placeholder: 'Try "edit < filepath> to ..."',
            ),
          ),
        ],
      ),
    );
  }
}

class RecentActivityRow extends StatelessWidget {
  final String time;
  final String desc;
  const RecentActivityRow(this.time, this.desc, {super.key});

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
Widget _buildRecentActivityRow(String time, String action) {
  // Simple Row
  return Row(
    children: [
      Container(width: 10, child: Text(time, styleFg: Ansi.brightWhite)),
      Text(action, styleFg: Ansi.brightWhite),
    ],
  );
}

class ClaudeHeader extends StatelessWidget {
  const ClaudeHeader({super.key});
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
  const PixelArtLogo({super.key});
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
