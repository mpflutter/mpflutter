import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class ListViewPage extends StatelessWidget {
  Widget _renderBlock(Widget child) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          child: child,
        ),
      ),
    );
  }

  Widget _renderHeader(String title) {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'ListView',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: MPRefreshIndicator(
        onRefresh: (key) async {
          print('start refresh');
          await Future.delayed(Duration(seconds: 5));
          print('end refresh');
        },
        enableChecker: (key) {
          return key is ValueKey && key.value == 'main';
        },
        child: ListView(
          key: Key('main'),
          children: [
            _renderBlock(Column(
              children: [
                _renderHeader('ListView with Builder'),
                Container(
                  height: 400,
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    itemBuilder: (context, index) {
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
                    itemCount: 100,
                  ),
                ),
                SizedBox(height: 16),
              ],
            )),
            _renderBlock(Column(
              children: [
                _renderHeader('ListView with Builder and Seperator'),
                MPRefreshIndicator(
                  onRefresh: (_) async {
                    await Future.delayed(Duration(seconds: 2));
                  },
                  child: Container(
                    height: 400,
                    child: ListView.separated(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      itemBuilder: (context, index) {
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
                      separatorBuilder: (context, index) {
                        return Container(height: 1, color: Colors.black12);
                      },
                      itemCount: 100,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            )),
            _renderBlock(Column(
              children: [
                _renderHeader('ListView horizontal scroll'),
                Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        color: Color.fromARGB(255, Random().nextInt(255),
                            Random().nextInt(255), Random().nextInt(255)),
                        alignment: Alignment.center,
                        child: Text(
                          '$index',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                    itemCount: 100,
                  ),
                ),
                SizedBox(height: 16),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
