import 'package:flutter/widgets.dart';

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/src/rendering/sliver_grid.dart';

class SliverWaterfallDelegate
    extends SliverGridDelegateWithFixedCrossAxisCount {
  const SliverWaterfallDelegate({
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
  }) : super(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: 1.0,
        );

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final usableCrossAxisExtent = math.max(0.0,
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1));
    final childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    return _SliverWaterfallLayout(childCrossAxisExtent: childCrossAxisExtent);
  }
}

class _SliverWaterfallLayout extends SliverGridLayout {
  final double childCrossAxisExtent;

  const _SliverWaterfallLayout({
    this.childCrossAxisExtent = 2,
  });

  @override
  double computeMaxScrollOffset(int childCount) {
    return 1000.0 * childCount;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    return _SliverWaterfallGridGeometry(childCrossAxisExtent);
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    return 100000;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return 0;
  }
}

class _SliverWaterfallGridGeometry extends SliverGridGeometry {
  _SliverWaterfallGridGeometry(double crossAxisExtent)
      : super(
            scrollOffset: 0,
            crossAxisExtent: crossAxisExtent,
            mainAxisExtent: 0,
            crossAxisOffset: 0);

  @override
  BoxConstraints getBoxConstraints(SliverConstraints constraints) {
    return constraints.asBoxConstraints(
      minExtent: mainAxisExtent,
      maxExtent: 2000,
      crossAxisExtent: crossAxisExtent,
    );
  }
}

class SliverWaterfallItem extends StatelessWidget {
  final Widget child;
  final Size? size;

  SliverWaterfallItem({required this.child, this.size});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
