import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

import '../theme.dart';

class PaddingPage extends StatelessWidget {
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
      name: 'Padding',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      appBarColor: Theme.of(context).appBarColor,
      appBarTintColor: Theme.of(context).textColor,
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Container with Padding.'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    top: 24,
                    right: 18,
                    bottom: 32,
                  ),
                  child: Container(
                    color: Colors.yellow,
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}
