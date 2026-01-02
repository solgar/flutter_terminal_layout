import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

class MouseApp extends StatefulWidget {
  @override
  State<MouseApp> createState() => _MouseAppState();
}

class _MouseAppState extends State<MouseApp> {
  final Map<int, String> _colors = {};

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
          styleFg: Ansi.white,
          styleBg: Ansi.bgBlack,
        ),
      ),
    );
    rows.add(Container(height: 1, color: Ansi.bgBlack));

    for (int y = 0; y < 5; y++) {
      final cols = <Widget>[];
      for (int x = 0; x < 5; x++) {
        final index = y * 5 + x;
        final color = _colors[index] ?? Ansi.bgBlue;

        cols.add(
          Expanded(
            child: Listener(
              onPointerDown: (event) {
                setState(() {
                  if (_colors[index] == Ansi.bgGreen) {
                    _colors[index] = Ansi.bgBlue;
                  } else {
                    _colors[index] = Ansi.bgGreen;
                  }
                });
              },
              child: Container(
                color: color,
                // alignment: Alignment.center,
                child: Text('$x,$y', styleFg: Ansi.white),
              ),
            ),
          ),
        );
        if (x < 4) cols.add(Container(width: 1, color: Ansi.bgBlack));
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
      if (y < 4) rows.add(Container(height: 1, color: Ansi.bgBlack));
    }

    // Add footer
    rows.add(Container(height: 1, color: Ansi.bgBlack));
    rows.add(
      Container(
        height: 1,
        child: Row(
          children: [
            Text(
              ' Ctrl+C to Exit ',
              styleFg: Ansi.white,
              styleBg: Ansi.bgBlack,
            ),
            Spacer(),
          ],
        ),
      ),
    );

    return Column(children: rows);
  }
}
