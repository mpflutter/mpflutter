import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class TextPage extends StatelessWidget {
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
      name: 'Text',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Text with style.'),
              Container(
                height: 100,
                color: Colors.pink,
                alignment: Alignment.center,
                child: Text(
                  'Hello, World!\n你好，中国！',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('RichText with GestureDetector'),
              Container(
                height: 100,
                color: Colors.pink,
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Hello, World! ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: '你好，中国！',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.yellow,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          MPWebDialogs.alert(message: '你好， 中国！');
                        },
                    ),
                  ]),
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('RichText with WidgetSpan and NestedText'),
              Container(
                height: 100,
                color: Colors.pink,
                alignment: Alignment.center,
                child: RichText(
                  text: WidgetSpan(
                    child: Container(
                      width: 100,
                      height: 44,
                      color: Colors.yellow,
                      child: Center(
                        child: Text(
                          '文本',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Text with limit lines (selectable).'),
              Container(
                height: 200,
                padding: EdgeInsets.only(left: 20, right: 20),
                color: Colors.pink,
                alignment: Alignment.center,
                child: MPText(
                  'Millions of developers and companies build, ship, and maintain their software on GitHub—the largest and most advanced development platform in the world.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                  selectable: true,
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
