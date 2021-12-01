import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class WrapPage extends StatelessWidget {
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
      name: 'Wrap',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _renderHeader('Wrap with runSpacing and spacing'),
              Container(
                width: 100,
                height: 200,
                color: Colors.pink,
                child: Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: [
                    Container(width: 80, height: 44, color: Colors.yellow),
                    Container(width: 120, height: 44, color: Colors.blue),
                    Container(width: 40, height: 44, color: Colors.green),
                    Container(width: 80, height: 44, color: Colors.yellow),
                    Container(width: 180, height: 44, color: Colors.orange),
                    Container(width: 100, height: 44, color: Colors.black),
                    Container(width: 66, height: 44, color: Colors.white),
                    Container(width: 99, height: 44, color: Colors.brown),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _renderHeader('Wrap with aligments'),
              Container(
                width: 100,
                height: 200,
                color: Colors.pink,
                child: Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    Container(width: 80, height: 44, color: Colors.yellow),
                    Container(width: 120, height: 44, color: Colors.blue),
                    Container(width: 40, height: 44, color: Colors.green),
                    Container(width: 80, height: 44, color: Colors.yellow),
                    Container(width: 180, height: 44, color: Colors.orange),
                    Container(width: 100, height: 44, color: Colors.black),
                    Container(width: 66, height: 44, color: Colors.white),
                    Container(width: 99, height: 44, color: Colors.brown),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _renderHeader('Wrap with vertical direction'),
              Container(
                width: 100,
                height: 200,
                color: Colors.pink,
                child: Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  direction: Axis.vertical,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    Container(width: 44, height: 80, color: Colors.yellow),
                    Container(width: 44, height: 120, color: Colors.blue),
                    Container(width: 44, height: 40, color: Colors.green),
                    Container(width: 44, height: 80, color: Colors.yellow),
                    Container(width: 44, height: 180, color: Colors.orange),
                    Container(width: 44, height: 100, color: Colors.black),
                    Container(width: 44, height: 66, color: Colors.white),
                    Container(width: 44, height: 99, color: Colors.brown),
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
