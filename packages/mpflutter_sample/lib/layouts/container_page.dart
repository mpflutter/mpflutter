import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

import '../theme.dart';

class ContainerPage extends StatelessWidget {
  Widget _renderBlock(Widget child, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Theme.of(context).segmentBackgroundColor,
          child: child,
        ),
      ),
    );
  }

  Widget _renderHeader(String title, dynamic icon, BuildContext context) {
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
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            icon != null ? MPIcon(icon, color: Colors.grey) : SizedBox(),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'Container',
      backgroundColor: Theme.of(context).backgroundColor,
      appBarColor: Colors.blue,
      appBarTintColor: Colors.white,
      onWechatMiniProgramShareAppMessage: (request) async {
        return MPWechatMiniProgramShareInfo(
          title: 'Container 容器标题(${request.from ?? ''})',
          imageUrl:
              'https://www-jsdelivr-com.onrender.com/img/landing/built-for-production-icon@2x.png',
        );
      },
      body: ListView(
        children: [
          _renderBlock(
            Column(
              children: [
                _renderHeader('Container with color and size.', null, context),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink,
                ),
                SizedBox(height: 16),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('Container with Center Container', null, context),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      color: Colors.yellow,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader(
                    'Container with alignment (topRight)', null, context),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink,
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 44,
                    height: 44,
                    color: Colors.yellow,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('Container with padding', null, context),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink,
                  padding: EdgeInsets.all(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: Colors.yellow,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('Container with decoration', null, context),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    border: Border.all(width: 4, color: Colors.black),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader(
                    'Container with foregroundDecoration', null, context),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    border: Border.all(width: 4, color: Colors.black),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader(
                    'Container with border and center text', null, context),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    border: Border.all(width: 4, color: Colors.black),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      'Hello',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
            context,
          ),
        ],
      ),
    );
  }
}
