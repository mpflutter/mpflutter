part of 'mpkit.dart';

class MPRefreshIndicator extends StatelessWidget {
  final Future Function(Key? scrollViewKey)? onRefresh;
  final bool Function(Key? scrollViewKey)? enableChecker;
  final Widget child;

  const MPRefreshIndicator({
    required this.child,
    this.onRefresh,
    this.enableChecker,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
