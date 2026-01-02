import 'geometry.dart';
import 'dart:math' as math;

class BoxConstraints {
  final int minWidth;
  final int maxWidth;
  final int minHeight;
  final int maxHeight;

  const BoxConstraints({
    this.minWidth = 0,
    this.maxWidth = 100000,
    this.minHeight = 0,
    this.maxHeight = 100000,
  });

  BoxConstraints.tight(Size size)
    : minWidth = size.width,
      maxWidth = size.width,
      minHeight = size.height,
      maxHeight = size.height;

  const BoxConstraints.tightFor({int? width, int? height})
    : minWidth = width ?? 0,
      maxWidth = width ?? 100000,
      minHeight = height ?? 0,
      maxHeight = height ?? 100000;

  Size constrain(Size size) {
    return Size(
      size.width.clamp(minWidth, maxWidth),
      size.height.clamp(minHeight, maxHeight),
    );
  }

  bool get isTight => minWidth >= maxWidth && minHeight >= maxHeight;

  BoxConstraints loosen() {
    return BoxConstraints(
      minWidth: 0,
      maxWidth: maxWidth,
      minHeight: 0,
      maxHeight: maxHeight,
    );
  }

  BoxConstraints deflate({int horizontal = 0, int vertical = 0}) {
    return BoxConstraints(
      minWidth: math.max(0, minWidth - horizontal),
      maxWidth: math.max(0, maxWidth - horizontal),
      minHeight: math.max(0, minHeight - vertical),
      maxHeight: math.max(0, maxHeight - vertical),
    );
  }

  @override
  String toString() =>
      'BoxConstraints($minWidth<=$maxWidth, $minHeight<=$maxHeight)';
}
