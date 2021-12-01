import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class CenterPage extends StatelessWidget {
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
      name: 'Center',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Container with center container.'),
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
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Container with align container.'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: 44,
                    height: 44,
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
