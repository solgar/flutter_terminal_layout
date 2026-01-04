import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

class VerticalDivider extends StatelessWidget {
  final int? width;
  final Color? color;
  final int?
  thickness; // Ignored for now (always 1 char border) or used for spacing?

  const VerticalDivider({
    super.key,
    this.width = 1,
    this.color,
    this.thickness,
  });

  @override
  Widget build(BuildContext context) {
    // A Vertical Divider in TUI is typically a single column with a left border or | char
    return Container(
      width: width ?? 1,
      decoration: BoxDecoration(
        border: BoxBorder(left: BorderSide(color: color ?? Colors.white)),
      ),
    );
  }
}
