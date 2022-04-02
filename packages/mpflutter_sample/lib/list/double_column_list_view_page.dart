import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class DoubleColumnListViewPage extends StatefulWidget {
  @override
  State<DoubleColumnListViewPage> createState() =>
      _DoubleColumnListViewPageState();
}

class _DoubleColumnListViewPageState extends State<DoubleColumnListViewPage> {
  final scrollController = ScrollController();
  final sixtyGlobalKey = GlobalKey();
  int selected = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      final currentSelect = (scrollController.position.pixels / 440).floor();
      if (currentSelect != selected) {
        setState(() {
          selected = currentSelect;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'DoubleColumnListView',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: Row(
        children: [
          Container(
            width: 88,
            color: Colors.yellow,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (index == 10) {
                      final renderBox =
                          sixtyGlobalKey.currentContext?.findRenderObject();
                      if (renderBox is RenderBox) {
                        final offset = renderBox.localToGlobal(Offset(0, 0)).dy;
                        scrollController.jumpTo(offset);
                      }
                      return;
                    }
                    scrollController.jumpTo(44.0 * 10 * index);
                    setState(() {
                      selected = index;
                    });
                  },
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    child: Text(
                      index == 10 ? 'Go to 60' : 'S - $index',
                      style: TextStyle(
                        fontSize: 16,
                        color: selected == index ? Colors.blue : Colors.black,
                        fontWeight: selected == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
              itemCount: 10 + 1,
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey,
              child: ListView.builder(
                controller: scrollController,
                itemBuilder: (context, index) {
                  return Container(
                    key: index == 60 ? sixtyGlobalKey : null,
                    height: 44,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Index - $index',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
                itemCount: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
