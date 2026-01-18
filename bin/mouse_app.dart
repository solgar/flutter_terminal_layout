import 'package:flutterlike_tui/flutterlike_tui.dart';

class MouseApp extends StatefulWidget {
  const MouseApp({super.key});
  @override
  State<MouseApp> createState() => _MouseAppState();
}

class _MouseAppState extends State<MouseApp> {
  final Map<int, Color> _colors = {};

  @override
  Widget build(BuildContext context) {
    // Grid of 5x5
    final rows = <Widget>[];
    // Create header
    rows.add(
      Container(
        height: 1,
        child: Text(
          ' Click on cells to toggle Green/Blue ',
          color: Colors.white,
          backgroundColor: Colors.black,
        ),
      ),
    );
    rows.add(Container(height: 1, color: Colors.black));

    for (int y = 0; y < 5; y++) {
      final cols = <Widget>[];
      for (int x = 0; x < 5; x++) {
        final index = y * 5 + x;
        final color = _colors[index] ?? Colors.blue;

        cols.add(
          Expanded(
            child: Listener(
              onPointerDown: (event) {
                setState(() {
                  if (_colors[index] == Colors.green) {
                    _colors[index] = Colors.blue;
                  } else {
                    _colors[index] = Colors.green;
                  }
                });
              },
              child: Container(
                color: color,
                // alignment: Alignment.center,
                child: Text('$x,$y', color: Colors.white),
              ),
            ),
          ),
        );
        if (x < 4) cols.add(Container(width: 1, color: Colors.black));
      }
      // Wrap Row in Expanded to fill vertical space
      rows.add(
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cols,
          ),
        ),
      );
      if (y < 4) rows.add(Container(height: 1, color: Colors.black));
    }

    // Add footer
    rows.add(Container(height: 1, color: Colors.black));
    rows.add(
      Container(
        height: 1,
        child: Row(
          children: [
            Text(
              ' Ctrl+C to Exit ',
              color: Colors.white,
              backgroundColor: Colors.black,
            ),
            Spacer(),
          ],
        ),
      ),
    );

    return Column(children: rows);
  }
}
