import 'framework.dart';
import 'widget.dart';
import 'container.dart';

class Center extends StatelessWidget {
  final Widget? child;

  const Center({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: child,
    );
  }
}
