import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});
  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _counter = 321;
  }

  @override
  void dispose() {
    _counter = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      onKeyEvent: (input) {
        if (input.contains(32)) {
          setState(() {
            _counter++;
          });
        }
      },
      child: Container(
        color: Ansi.bgBlue,
        child: Column(
          children: [
            Spacer(),
            Row(
              children: [
                Spacer(),
                Text(' Counter: $_counter ', styleFg: Ansi.white),
                Spacer(),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
