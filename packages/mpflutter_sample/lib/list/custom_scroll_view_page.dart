import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class CustomScrollViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'CustomScrollView',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: MPRefreshIndicator(
        onRefresh: (key) async {
          print('start refresh');
          await Future.delayed(Duration(seconds: 5));
          print('end refresh');
        },
        child: CustomScrollView(
          slivers: [
            SliverOpacity(
              opacity: 0.75,
              sliver: SliverPadding(
                padding: EdgeInsets.all(12),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 100,
                    color: Colors.pink,
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(delegate: YellowBoxDelegate()),
            SliverPadding(
              padding: EdgeInsets.all(12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                      height: 44,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Index - $index',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                  childCount: 10,
                ),
              ),
            ),
            SliverPersistentHeader(delegate: BlueBoxDelegate()),
            // SliverToBoxAdapter(
            //   child: Container(
            //     height: 44,
            //     color: Colors.blue,
            //   ),
            // ),
            SliverPadding(
              padding: EdgeInsets.all(12),
              sliver: SliverWaterfall(
                gridDelegate: SliverWaterfallDelegate(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                      height: 100 + 20 * (index % 5),
                      color: Colors.brown,
                      child: Center(child: Text('Index - $index')),
                    );
                  },
                  childCount: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlueBoxDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 44,
      color: Colors.blue,
    );
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class YellowBoxDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 44,
      color: Colors.yellow,
    );
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
