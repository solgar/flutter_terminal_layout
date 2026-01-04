import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';
import 'dart:async';

Future<void> main() async {
  await runApp(const LoadingDemo());
}

class LoadingDemo extends StatefulWidget {
  const LoadingDemo({super.key});

  @override
  State<LoadingDemo> createState() => _LoadingDemoState();
}

class _LoadingDemoState extends State<LoadingDemo> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSimulatedLoading();
  }

  void _startSimulatedLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.003;
          if (_progress > 1.0) {
            _progress = 0.0;
          }
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
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Container(
        width: 50,
        height: 20,
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: BoxBorder.all(color: Colors.blue, style: BorderStyle.rounded),
        ),
        child: Column(
          children: [
            Container(height: 1),
            Text('Loading Indicators Demo', color: Colors.brightWhite),
            Container(height: 2),

            Text('Spinner:', color: Colors.grey),
            Container(height: 1),
            const Spinner(),

            Container(height: 2),

            Text('Progress Bar:', color: Colors.grey),
            Container(height: 1),
            ProgressBar(progress: _progress),
            Container(height: 1),
            Text('${(_progress * 100).toInt()}%', color: Colors.green),

            Spacer(),
            Container(height: 1),
          ],
        ),
      ),
    );
  }
}

class Spinner extends StatefulWidget {
  const Spinner({super.key});

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
    return Text(_frames[_index], color: Colors.cyan);
  }
}

class ProgressBar extends StatelessWidget {
  final double progress;
  final int width;

  const ProgressBar({super.key, required this.progress, this.width = 30});

  @override
  Widget build(BuildContext context) {
    // [████████░░░░░░░░]

    final int filled = (progress.clamp(0.0, 1.0) * width).toInt();
    final int empty = width - filled;

    // We use RichText to apply styles to parts of the string
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '[', color: Colors.darkGray),
              TextSpan(text: '█' * filled, color: Colors.cyan),
              TextSpan(text: '░' * empty, color: Colors.darkGray),
              TextSpan(text: ']', color: Colors.darkGray),
            ],
          ),
        ),
      ],
    );
  }
}
