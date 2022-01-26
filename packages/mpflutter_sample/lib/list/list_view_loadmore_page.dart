import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class ListViewLoadmorePage extends StatefulWidget {
  @override
  _ListViewLoadmorePageState createState() => _ListViewLoadmorePageState();
}

class _ListViewLoadmorePageState extends State<ListViewLoadmorePage> {
  bool loadingMore = false;
  bool showFloatingTop = false;
  int count = 20;
  final customViewKey = GlobalKey();
  final sliverListKey = GlobalKey();

  Widget buildFloatingTop() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Opacity(
        opacity: showFloatingTop ? 1.0 : 0.0,
        child: Container(
          height: 44,
          color: Colors.blue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'ListView + LoadMore',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      onRefresh: () async {
        print('start refresh');
        await Future.delayed(Duration(seconds: 5));
        print('end refresh');
      },
      onReachBottom: () async {
        if (loadingMore) return;
        loadingMore = true;
        setState(() {
          count += 20;
        });
        print(count);
        await Future.delayed(Duration(seconds: 1));
        loadingMore = false;
      },
      onPageScroll: (scrollTop) {
        if (scrollTop > 100 && !showFloatingTop) {
          setState(() {
            showFloatingTop = true;
          });
        } else if (scrollTop <= 100 && showFloatingTop) {
          setState(() {
            showFloatingTop = false;
          });
        }
      },
      floatingBody: buildFloatingTop(),
      bottomBar: Container(
        height: 44,
        color: Colors.yellow,
        child: Center(
          child: Text('BottomBar'),
        ),
      ),
      bottomBarWithSafeArea: true,
      bottomBarSafeAreaColor: Colors.yellow,
      body: CustomScrollView(
        slivers: [
          SliverList(
            key: sliverListKey,
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
              childCount: count,
            ),
          )
        ],
      ),
      // body: ListView.builder(
      //   padding: EdgeInsets.only(left: 12, right: 12),
      //   itemBuilder: (context, index) {
      //     return Container(
      //       height: 44,
      //       alignment: Alignment.centerLeft,
      //       child: Text(
      //         'Index - $index',
      //         style: TextStyle(
      //           fontSize: 14,
      //         ),
      //       ),
      //     );
      //   },
      //   itemCount: count,
      // ),
    );
  }
}
