import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

void main() {
  runApp(const ButtonDemo());
}

class ButtonDemo extends StatefulWidget {
  const ButtonDemo({super.key});

  @override
  State<ButtonDemo> createState() => _ButtonDemoState();
}

class _ButtonDemoState extends State<ButtonDemo> {
  int _counter = 0;
  String _status = 'Idle';

  void _increment() {
    setState(() {
      _counter++;
      _status = 'Incremented!';
    });
  }

  void _decrement() {
    setState(() {
      _counter--;
      _status = 'Decremented!';
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
      _status = 'Reset';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 50,
        height: 20,
        decoration: BoxDecoration(
          border: BoxBorder.all(color: Colors.green, style: BorderStyle.rounded),
        ),
        child: Column(
          children: [
            Container(height: 1),
            Text('Button Demo', color: Colors.brightGreen),
            Container(
              height: 1,
              child: Center(child: Text('─' * 46, color: Colors.green)),
            ),
            Spacer(),
            Text('Counter: $_counter', color: Colors.white),
            Text('Status: $_status', color: Colors.grey),
            Spacer(),
            Row(
              children: [
                Spacer(),
                Button(
                  debugLabel: 'BtnMinus',
                  autofocus: true,
                  onPressed: _decrement,
                  child: Text(' - ', color: Colors.white),
                ),
                Container(width: 2),
                Button(
                  debugLabel: 'BtnPlus',
                  onPressed: _increment,
                  child: Text(' + ', color: Colors.white),
                ),
                Spacer(),
              ],
            ),
            Container(height: 1),
            Button(
              debugLabel: 'BtnReset',
              onPressed: _reset,
              color: Colors.red,
              focusColor: Colors.magenta,
              child: Text(' Reset ', color: Colors.white),
            ),
            Container(height: 1),
            Button(
              debugLabel: 'BtnDisabled',
              onPressed: null, // Disabled
              child: Text(' Disabled ', color: Colors.black),
            ),
            Spacer(),
            Text('Use Tab/Shift+Tab to navigate', color: Colors.darkGray),
            Text('Enter/Space/Click to activate', color: Colors.darkGray),
            Container(height: 1),
          ],
        ),
      ),
    );
  }
}
