import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

final _tabDatas = [
  'Home',
  'Cart',
  'News',
  'Long Long Long A',
  'Long Long Long B',
  'Long Long Long C',
  'Long Long Long D',
];

class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'TabPage',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      appBar: MPAppBarPinned(
        headerContent: Container(
          height: 100,
          color: Colors.yellow,
        ),
        appBarContent: _TabBar(
          currentPage: currentPage,
          onChangePage: (nextPage) {
            setState(() {
              this.currentPage = nextPage;
            });
          },
        ),
        footerContent: Container(
          height: 44,
          color: Colors.blue,
        ),
        appBarHeight: 44,
      ),
      bottomBar: Container(
        height: 44,
        color: Colors.brown,
      ),
      bottomBarWithSafeArea: true,
      bottomBarSafeAreaColor: Colors.brown,
      body: (() {
        switch (currentPage) {
          case 0:
            return _Page0();
          case 1:
            return _Page1();
          case 2:
            return _Page2();
          case 3:
            return _Page3();
          default:
            return _Page0();
        }
      })(),
    );
  }
}

class _TabBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentPage;
  final Function(int)? onChangePage;

  _TabBar({required this.currentPage, this.onChangePage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.white,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _TabItem(index, index == this.currentPage, () {
            this.onChangePage?.call(index);
          });
        },
        itemCount: _tabDatas.length,
        scrollDirection: Axis.horizontal,
        restorationId: 'tabbar',
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(44);
}

class _TabItem extends StatelessWidget {
  final int index;
  final bool selected;
  final Function onSelect;

  _TabItem(this.index, this.selected, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelect();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Center(
          child: Text(
            _tabDatas[index],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.blue : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}

class _Page0 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      child: Center(
        child: Text(
          'Home',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Container(
          height: 44,
          padding: EdgeInsets.only(left: 12),
          alignment: Alignment.centerLeft,
          child: Text(
            'Index - $index',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        );
      },
      itemCount: 100,
    );
  }
}

class _Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      child: Center(
        child: Text(
          'Body2',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          delegate: PinkBoxDelegate(),
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Container(
                height: 44,
                padding: EdgeInsets.only(left: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Index - $index',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
              );
            },
            childCount: 20,
          ),
        ),
        SliverPersistentHeader(
          delegate: PinkBoxDelegate(),
          pinned: true,
          // lazying: true,
          // lazyOffset: 100,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Container(
                height: 44,
                padding: EdgeInsets.only(left: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Index - $index',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
              );
            },
            childCount: 20,
          ),
        ),
      ],
    );
  }
}

class PinkBoxDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 44,
      color: Colors.pink,
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
