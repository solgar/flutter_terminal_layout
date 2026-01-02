import 'framework.dart';
import 'widget.dart';
import 'dart:async';

class KeyboardListener extends StatefulWidget {
  final Widget child;
  final void Function(List<int>) onKeyEvent;

  const KeyboardListener({
    super.key,
    required this.child,
    required this.onKeyEvent,
  });

  @override
  State<KeyboardListener> createState() => _KeyboardListenerState();
}

class _KeyboardListenerState extends State<KeyboardListener> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = TerminalApp.onInput.listen((input) {
      if (mounted) {
        widget.onKeyEvent(input);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
