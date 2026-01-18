import 'dart:io';

import 'package:flutterlike_tui/flutterlike_tui.dart';

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
          color: Colors.blue,
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
                    color: Colors.green,
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
                    color: Colors.red,
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
                    color: Colors.yellow,
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
                    color: Colors.cyan,
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
