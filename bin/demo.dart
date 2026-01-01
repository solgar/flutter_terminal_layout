import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';
import 'dart:io';

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Ansi.bgBlue,
          height: 20,
          child: Column(
            children: [
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  Text(' FLUTTER TERMINAL LAYOUT DEMO ', styleFg: Ansi.white),
                  Spacer(),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
        Container(height: 1), // Margin
        Row(
          children: [
            Expanded(
              child: Container(
                color: Ansi.bgRed,
                height: 10,
                child: Column(
                  children: [
                    Text(' Left Panel ', styleFg: Ansi.white),
                    Spacer(),
                    Text(' Bottom Left ', styleFg: Ansi.white),
                  ],
                ),
              ),
            ),
            Container(width: 2), // Gap
            Expanded(
              flex: 2,
              child: Container(
                color: Ansi.bgGreen,
                height: 10,
                child: Column(
                  children: [
                    Text(' Right Panel (Flex 2) ', styleFg: Ansi.black),
                    Container(height: 1, color: Ansi.bgBlack),
                    Text(' Content Line 1 ', styleFg: Ansi.black),
                    Text(' Content Line 2 ', styleFg: Ansi.black),
                  ],
                ),
              ),
            ),
          ],
        ),
        Spacer(),
        Container(
          color: Ansi.bgYellow,
          height: 1,
          child: Row(
            children: [
              Text(' Footer Status: OK ', styleFg: Ansi.black),
              Spacer(),
              Text(' v1.0.0 ', styleFg: Ansi.black),
            ],
          ),
        ),
      ],
    );
  }
}

void main() async {
  // Enable alt buffer
  stdout.write(Ansi.enableAltBuffer);
  // Clear screen
  stdout.write(Ansi.clearScreen);
  // Hide cursor
  stdout.write(Ansi.hideCursor);

  runApp(DemoApp());

  // In a real app we'd have an event loop.
  // Here we just wait for a key to exit so the user can see the result in alt buffer.
  stdout.write(Ansi.moveTo(24, 1)); // safe spot
  stdout.write(
    Ansi.color('Press any key to exit...', fg: Ansi.white, bg: Ansi.bgBlack),
  );

  stdin.echoMode = false;
  stdin.lineMode = false;
  await stdin.first;

  // Cleanup
  stdout.write(Ansi.showCursor);
  stdout.write(Ansi.disableAltBuffer);
}
