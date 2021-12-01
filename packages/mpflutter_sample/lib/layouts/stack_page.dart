import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class StackPage extends StatelessWidget {
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
      name: 'Stack',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Constrainted Stack'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Stack(
                  children: [
                    Positioned(
                      left: 10,
                      top: 10,
                      width: 40,
                      height: 40,
                      child: Container(color: Colors.yellow),
                    ),
                    Positioned(
                      left: 30,
                      top: 30,
                      width: 40,
                      height: 40,
                      child: Container(color: Colors.green),
                    ),
                    Positioned(
                      left: 50,
                      top: 50,
                      width: 40,
                      height: 40,
                      child: Container(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Unconstrainted Stack'),
              Container(
                width: 100,
                color: Colors.pink,
                child: Stack(
                  children: [
                    Container(height: 100, color: Colors.black),
                    Positioned(
                      left: 10,
                      top: 10,
                      width: 40,
                      height: 40,
                      child: Container(color: Colors.yellow),
                    ),
                    Positioned(
                      left: 30,
                      top: 30,
                      width: 40,
                      height: 40,
                      child: Container(color: Colors.green),
                    ),
                    Positioned(
                      left: 50,
                      top: 50,
                      width: 40,
                      height: 40,
                      child: Container(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Positioned fill'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: Colors.yellow),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Positioned top right'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        width: 44,
                        height: 44,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Positioned left right bottom'),
              Container(
                width: 100,
                height: 100,
                color: Colors.pink,
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Container(
                        height: 44,
                        color: Colors.yellow,
                      ),
                    ),
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
