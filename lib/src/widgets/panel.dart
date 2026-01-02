import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';

// Base Panel class that functions as a content container (Leaf)
// and handles common properties like flex.
class Panel extends StatelessWidget {
  final int flex;
  final Widget? child;
  final double? width;
  final double? height;
  final String? borderColor;
  final BorderStyle borderStyle;
  final String? color;
  final EdgeInsets? padding;

  const Panel({
    this.child,
    this.flex = 0,
    this.width,
    this.height,
    this.borderColor, // Default usually white, but nullable string
    this.borderStyle = BorderStyle.solid,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.toInt(),
      height: height?.toInt(),
      decoration: BoxDecoration(
        color: color ?? Ansi.bgRgb(20, 20, 20),
        border: BoxBorder.all(
          color: borderColor ?? Ansi.white,
          style: borderStyle,
        ),
      ),
      padding: padding ?? EdgeInsets.all(1),
      child: child,
    );
  }
}

// Vertical Panel Layout
class VPanel extends Panel {
  final List<Panel> children;
  final CrossAxisAlignment crossAxisAlignment;

  const VPanel({
    required this.children,
    super.flex,
    super.width,
    super.height,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  }) : super(child: null);

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: crossAxisAlignment,
      spacing: -1,
      children: _buildChildren(),
    );
    return content;
  }

  List<Widget> _buildChildren() {
    List<Widget> widgets = [];
    for (int i = 0; i < children.length; i++) {
      var child = children[i];
      Widget w = child;

      // Apply Flex/Expanded
      if (child.flex > 0) {
        w = Expanded(flex: child.flex, child: w);
      }
      widgets.add(w);
    }
    return widgets;
  }
}

// Horizontal Panel Layout
class HPanel extends Panel {
  final List<Panel> children;
  final CrossAxisAlignment crossAxisAlignment;

  const HPanel({
    required this.children,
    super.flex,
    super.width,
    super.height,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  }) : super(child: null);

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      crossAxisAlignment: crossAxisAlignment,
      spacing: -1,
      children: _buildChildren(),
    );
    return content;
  }

  List<Widget> _buildChildren() {
    List<Widget> widgets = [];
    for (int i = 0; i < children.length; i++) {
      var child = children[i];
      Widget w = child;

      // Apply Flex/Expanded
      if (child.flex > 0) {
        w = Expanded(flex: child.flex, child: w);
      }
      widgets.add(w);
    }
    return widgets;
  }
}
