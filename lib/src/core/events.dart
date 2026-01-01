import '../rendering/geometry.dart';

abstract class PointerEvent {
  final Offset position;
  const PointerEvent({required this.position});
}

class PointerDownEvent extends PointerEvent {
  const PointerDownEvent({required super.position});
}

class PointerUpEvent extends PointerEvent {
  const PointerUpEvent({required super.position});
}
