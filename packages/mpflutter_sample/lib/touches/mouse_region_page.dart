import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class MouseRegionPage extends StatelessWidget {
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
      name: 'MouseRegion',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Clickable mouse region.'),
              _TestCase(),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class _TestCase extends StatefulWidget {
  const _TestCase({
    Key? key,
  }) : super(key: key);

  @override
  State<_TestCase> createState() => _TestCaseState();
}

class _TestCaseState extends State<_TestCase> {
  double size = 100;
  bool entered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          entered = true;
        });
      },
      onExit: (event) {
        setState(() {
          entered = false;
        });
      },
      onHover: (event) {},
      cursor: SystemMouseCursors.zoomIn,
      child: GestureDetector(
        onTap: () {
          setState(() {
            size += 10.0;
          });
        },
        child: Container(
          width: size,
          height: size,
          color: entered ? Colors.yellow : Colors.pink,
        ),
      ),
    );
  }
}
