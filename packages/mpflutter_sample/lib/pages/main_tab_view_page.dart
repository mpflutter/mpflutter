import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class MainTabViewPage extends StatefulWidget {
  @override
  State<MainTabViewPage> createState() => _MainTabViewPageState();
}

class _MainTabViewPageState extends State<MainTabViewPage> {
  final controller = MPMainTabController(canJump: (page) async {
    return true;
  });

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 5)).then((value) {
    //   controller.jumpToPage(1);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MPMainTabView(
      tabs: [
        MPMainTabItem(
          activeTabWidget: Container(
            width: 22,
            height: 22,
            color: Colors.blue,
          ),
          inactiveTabWidget: Container(
            width: 22,
            height: 22,
            color: Colors.red,
          ),
          builder: (context) => _HomePage(),
        ),
        MPMainTabItem(
          activeTabWidget: Container(
            width: 22,
            height: 22,
            color: Colors.blue,
          ),
          inactiveTabWidget: Container(
            width: 22,
            height: 22,
            color: Colors.red,
          ),
          builder: (context) => _SecondPage(),
        )
      ],
      controller: controller,
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            height: 44,
            alignment: Alignment.centerLeft,
            child: Text('Index - $index'),
          );
        },
        itemCount: 1000,
      ),
    );
  }
}

class _SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            height: 44,
            alignment: Alignment.centerLeft,
            child: Text('Second - $index'),
          );
        },
        itemCount: 1000,
      ),
    );
  }
}
