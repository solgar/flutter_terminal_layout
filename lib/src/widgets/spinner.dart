import 'framework.dart';
import 'widget.dart';
import 'text.dart';
import '../core/colors.dart';
import 'dart:async';

class Spinner extends StatefulWidget {
  final Color? color;
  const Spinner({super.key, this.color});

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {
  int _index = 0;
  final List<String> _frames = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _frames.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_frames[_index], color: widget.color ?? Colors.cyan);
  }
}
