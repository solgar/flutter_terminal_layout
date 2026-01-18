import 'package:flutterlike_tui/flutterlike_tui.dart';

// Base Panel class that functions as a content container (Leaf)
// and handles common properties like flex.
class Panel extends StatelessWidget {
  final int flex;
  final Widget? child;
  final double? width;
  final double? height;
  final Color? borderColor;
  final BorderStyle borderStyle;
  final Color? color;
  final EdgeInsets? padding;
  final String? title;
  final Color? titleColor;

  const Panel({
    super.key,
    this.child,
    this.flex = 0,
    this.width,
    this.height,
    this.borderColor,
    this.borderStyle = BorderStyle.solid,
    this.color,
    this.padding,
    this.title,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    if (title != null) {
      final bColor = borderColor ?? Colors.white;
      final border = BorderSide(color: bColor, style: borderStyle);
      // Construct Header Row + Body
      return Column(
        children: [
          Row(
            spacing: 0,
            children: [
              // Top Left Corner (border-aware)
              Container(
                width: 1,
                height: 1,
                decoration: BoxDecoration(
                  border: BoxBorder(top: border, left: border),
                ),
              ),
              // Dash after corner (border-aware)
              Container(
                width: 1,
                height: 1,
                decoration: BoxDecoration(border: BoxBorder(top: border)),
              ),
              // Title
              Text(' $title ', color: titleColor ?? Colors.white),
              // Filler Line
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(border: BoxBorder(top: border)),
                ),
              ),
              // Top Right Corner (border-aware)
              Container(
                width: 1,
                height: 1,
                decoration: BoxDecoration(
                  border: BoxBorder(top: border, right: border),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: width?.toInt(),
              // height is handled by Column/Expanded
              decoration: BoxDecoration(
                color: color ?? const Color(0xFF141414),
                border: BoxBorder(left: border, right: border, bottom: border),
              ),
              padding: padding ?? EdgeInsets.all(1),
              child: child,
            ),
          ),
        ],
      );
    }

    return Container(
      width: width?.toInt(),
      height: height?.toInt(),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF141414),
        border: BoxBorder.all(
          color: borderColor ?? Colors.white,
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
    super.key,
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
    super.key,
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
