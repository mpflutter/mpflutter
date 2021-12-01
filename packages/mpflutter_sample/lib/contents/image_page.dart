import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class ImagePage extends StatelessWidget {
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
      name: 'Image',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Image with remote url.'),
              Container(
                width: 100,
                height: 100,
                child: Image.network(
                  'https://www-jsdelivr-com.onrender.com/img/landing/built-for-production-icon@2x.png',
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Image with asset.'),
              Container(
                width: 100,
                height: 100,
                child: Image.asset(
                  'assets/images/pony_avatar.jpeg',
                  package: 'mpflutter_template',
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Image with fit = BoxFit.fill.'),
              Container(
                width: 200,
                height: 100,
                child: Image.network(
                  'https://www-jsdelivr-com.onrender.com/img/landing/built-for-production-icon@2x.png',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Image with remote svg url.'),
              Container(
                width: 100,
                height: 100,
                child: Image.network(
                  'https://www-jsdelivr-com.onrender.com/img/logo-horizontal.svg',
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
