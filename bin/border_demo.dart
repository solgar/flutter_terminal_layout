import 'dart:io';

import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

class BorderDemo extends StatelessWidget {
  const BorderDemo({super.key});
  @override
  Widget build(BuildContext context) {
    final width = stdout.hasTerminal ? stdout.terminalColumns : 80;
    return Column(
      children: [
        Container(
          height: 1,
          width: width,
          color: Ansi.bgBlue,
          alignment: Alignment.center,
          child: Text('Border Layout Demo'),
        ),
        Container(height: 1), // Spacer
        Row(
          children: [
            Expanded(
              child: Container(
                height: 10,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    color: Ansi.green,
                    style: BorderStyle.rounded,
                  ),
                ),
                child: Text('Solid Border'),
              ),
            ),
            Container(width: 2),
            Expanded(
              child: Container(
                height: 10,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    color: Ansi.red,
                    style: BorderStyle.double,
                  ),
                ),
                child: Text('Double Border'),
              ),
            ),
          ],
        ),
        Container(height: 1),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 10,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    color: Ansi.yellow,
                    style: BorderStyle.heavy,
                  ),
                ),
                child: Text('Heavy Border'),
              ),
            ),
            Container(width: 2),
            Expanded(
              child: Container(
                height: 10,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    color: Ansi.cyan,
                    style: BorderStyle.rounded,
                  ),
                ),
                child: Text('Rounded Border'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
