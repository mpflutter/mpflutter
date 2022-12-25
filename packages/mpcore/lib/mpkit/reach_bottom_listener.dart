part of 'mpkit.dart';

class MPReachBottomListener extends StatelessWidget {
  final void Function(Key? scrollViewKey)? onReachBottom;
  final Widget child;

  const MPReachBottomListener({
    required this.child,
    this.onReachBottom,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
