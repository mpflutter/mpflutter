import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class ColumnRowPage extends StatelessWidget {
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
      name: 'Column and Row',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Column'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Column(
                  children: [
                    Container(height: 22, color: Colors.yellow),
                    Container(height: 33, color: Colors.green),
                    Container(height: 45, color: Colors.blue),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Row'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Row(
                  children: [
                    Container(width: 22, color: Colors.yellow),
                    Container(width: 33, color: Colors.green),
                    Container(width: 45, color: Colors.blue),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Expanded'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Column(
                  children: [
                    Container(height: 22, color: Colors.yellow),
                    Expanded(child: Container(color: Colors.blue)),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Flexible'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Column(
                  children: [
                    Flexible(flex: 2, child: Container(color: Colors.orange)),
                    Container(height: 22, color: Colors.yellow),
                    Flexible(flex: 1, child: Container(color: Colors.blue)),
                  ],
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
