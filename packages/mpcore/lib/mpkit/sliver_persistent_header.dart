part of 'mpkit.dart';

class MPSliverPersistentHeader extends StatelessWidget {
  final Widget child;
  final bool? lazying;
  final double? lazyOffset;

  const MPSliverPersistentHeader({
    required this.child,
    this.lazying,
    this.lazyOffset,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
