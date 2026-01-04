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
    return Stack(
      children: [
        KeyboardListener(
          onKeyEvent: _onKeyEvent,
          child: Container(
            color: Colors.blue,
            alignment: Alignment.center,
            child: Text(' Counter: $_counter ', color: Colors.white),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Text(
            'ESC to go back, space to increment',
            color: Colors.white,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Text('Top left', color: Colors.white),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Text('Top right', color: Colors.white),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Text('Bottom right', color: Colors.white),
        ),
      ],
    );
  }

  void _onKeyEvent(List<int> input) {
    if (input.contains(Keys.space)) {
      setState(() {
        _counter++;
      });
    }
  }
}
