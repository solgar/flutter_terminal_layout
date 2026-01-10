import 'framework.dart';
import 'widget.dart';
import 'container.dart';
import 'focus.dart';
import 'listener.dart';
import '../core/ansi.dart';
import '../core/events.dart';
import '../core/keys.dart';

class Button extends StatefulWidget {
  final Widget child;
  final void Function()? onPressed;
  final Color? color;
  final Color? focusColor;
  final Color? pressedColor;
  final EdgeInsets padding;
  final bool autofocus;
  final String? debugLabel;

  const Button({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.focusColor,
    this.pressedColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 1),
    this.autofocus = false,
    this.debugLabel,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _isFocused = false;
  bool _isPressed = false;

  void _handleFocusChange(bool focused) {
    if (_isFocused != focused) {
      setState(() {
        _isFocused = focused;
      });
    }
  }

  // Adjusted key handler to trigger on Down and flash visual
  bool _handleKeyTrigger(FocusNode node, KeyEvent event) {
    if (widget.onPressed == null) return false;
    if (event is! KeyDownEvent) return false;

    if (Keys.isEnter(event.bytes) || (event.bytes.length == 1 && event.bytes[0] == Keys.space)) {
      setState(() => _isPressed = true);
      // Trigger callback
      widget.onPressed!();
      
      // Reset visual after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _isPressed = false);
        }
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Color? bgColor = widget.color ?? Colors.blue;
    if (widget.onPressed == null) {
      bgColor = Colors.grey;
    } else if (_isPressed) {
      bgColor = widget.pressedColor ?? Colors.white;
    } else if (_isFocused) {
      bgColor = widget.focusColor ?? Colors.cyan;
    }

    // Determine text color/style based on bg? 
    // For now, let child handle text color, or we could enforce contrast.
    
    return Focus(
      debugLabel: widget.debugLabel,
      autofocus: widget.autofocus,
      canRequestFocus: widget.onPressed != null,
      skipTraversal: widget.onPressed == null,
      onFocusChange: _handleFocusChange,
      onKey: _handleKeyTrigger,
      child: Listener(
        onPointerDown: (event) {
          if (widget.onPressed != null) {
             setState(() => _isPressed = true);
          }
        },
        onPointerUp: (event) {
          if (widget.onPressed != null && _isPressed) {
            setState(() => _isPressed = false);
            widget.onPressed!();
          }
        },
        child: Container(
          color: bgColor,
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}
