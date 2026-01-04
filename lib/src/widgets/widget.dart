import '../rendering/render_object.dart';
import 'framework.dart';

import 'package:meta/meta.dart';

@immutable
class Key {
  final String? _value;
  const Key(this._value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Key && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Key($_value)';
}

class ValueKey<T> extends Key {
  final T value;
  const ValueKey(this.value) : super(null);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ValueKey<T> && other.value == value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    final String valueString = T == String ? "<'$value'>" : '<$value>';
    return 'ValueKey$valueString';
  }
}

abstract class Widget {
  final Key? key;
  const Widget({this.key});
  Element createElement();
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});

  @override
  Element createElement() => StatelessElement(this);

  Widget build(BuildContext context);
}

abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});

  @override
  Element createElement() => StatefulElement(this);

  State createState();
}

abstract class ProxyWidget extends Widget {
  final Widget child;
  const ProxyWidget({super.key, required this.child});
}

abstract class InheritedWidget extends ProxyWidget {
  const InheritedWidget({super.key, required super.child});

  @override
  Element createElement() => InheritedElement(this);

  bool updateShouldNotify(covariant InheritedWidget oldWidget);
}

abstract class RenderObjectWidget extends Widget {
  const RenderObjectWidget({super.key});

  @override
  Element createElement();

  RenderObject createRenderObject(BuildContext context);
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {}
}

class SingleChildRenderObjectWidget extends RenderObjectWidget {
  final Widget? child;
  const SingleChildRenderObjectWidget({super.key, this.child});

  @override
  Element createElement() => SingleChildRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    throw UnimplementedError();
  }
}

class MultiChildRenderObjectWidget extends RenderObjectWidget {
  final List<Widget> children;
  const MultiChildRenderObjectWidget({super.key, this.children = const []});

  @override
  Element createElement() => MultiChildRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    throw UnimplementedError();
  }
}
