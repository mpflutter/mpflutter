import 'package:flutter/widgets.dart';

class MPPageView extends StatelessWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final bool loop;

  MPPageView({
    required this.children,
    this.scrollDirection = Axis.horizontal,
    this.loop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          children.map((e) => Positioned.fill(child: MPPageItem(e))).toList(),
    );
  }
}

class MPPageItem extends StatelessWidget {
  final Widget child;

  MPPageItem(this.child);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
