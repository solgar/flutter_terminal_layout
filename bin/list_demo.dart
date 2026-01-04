import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';
import 'mouse_app.dart';

class ListDemoApp extends StatefulWidget {
  const ListDemoApp({super.key});
  @override
  State<ListDemoApp> createState() => _ListDemoAppState();
}

class _ListDemoAppState extends State<ListDemoApp> {
  final ScrollController _controller = ScrollController();
  final int _itemCount = 50;

  void _scroll(double delta) {
    setState(() {
      double newOffset = _controller.offset + delta;
      if (newOffset < 0) newOffset = 0;
      if (newOffset > _controller.maxScrollExtent) {
        newOffset = _controller.maxScrollExtent;
      }
      _controller.jumpTo(newOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildListSection()),
        Expanded(
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Expanded(
                child: Container(color: Colors.black, child: MouseApp()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListSection() => KeyboardListener(
    onKeyEvent: (input) {
      // j (106) or Down (ESC [ B -> 27, 91, 66)
      if (input.contains(Keys.j) ||
          (input.length >= 3 &&
              input[0] == Keys.esc &&
              input[1] == Keys.bracket &&
              input[2] == Keys.arrowDown)) {
        _scroll(1);
      }
      // k (107) or Up (ESC [ A -> 27, 91, 65)
      else if (input.contains(Keys.k) ||
          (input.length >= 3 &&
              input[0] == Keys.esc &&
              input[1] == Keys.bracket &&
              input[2] == Keys.arrowUp)) {
        _scroll(-1);
      }
    },
    child: Column(
      children: [
        Container(
          height: 3,
          color: Colors.magenta,
          child: Text(' Header (Fixed) ', color: Colors.white),
        ),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            itemCount: _itemCount,
            itemBuilder: (context, i) {
              return Container(
                height: 3, // height 3
                width: 20, // width 20
                color: (i % 2 == 0) ? Colors.blue : Colors.cyan,
                child: Text('Item $i', color: Colors.white),
              );
            },
          ),
        ),
        Container(
          height: 3,
          color: Colors.magenta,
          child: Text(' Footer (Fixed) ', color: Colors.white),
        ),
      ],
    ),
  );
}
