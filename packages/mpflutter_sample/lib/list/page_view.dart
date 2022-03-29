import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class PageViewPage extends StatelessWidget {
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
      name: 'PageView',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader(
                'PageView horizontal',
              ),
              _PageViewSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader(
                'PageView vertical',
              ),
              Container(
                height: 100,
                child: MPPageView(
                  scrollDirection: Axis.vertical,
                  children: [
                    Container(color: Colors.pink),
                    Container(color: Colors.blue),
                    Container(color: Colors.yellow),
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

class _PageViewSample extends StatefulWidget {
  const _PageViewSample({
    Key? key,
  }) : super(key: key);

  @override
  State<_PageViewSample> createState() => _PageViewSampleState();
}

class _PageViewSampleState extends State<_PageViewSample> {
  final pageController = MPPageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          child: MPPageView(
            children: [
              Container(color: Colors.pink),
              Container(color: Colors.blue),
              Container(color: Colors.yellow),
            ],
            loop: true,
            autoplay: true,
            controller: pageController,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Current Index = ${pageController.page}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: [
            GestureDetector(
              onTap: () {
                pageController.previousPage();
              },
              child: _renderToPageButton('Prev'),
            ),
            GestureDetector(
              onTap: () {
                pageController.jumpToPage(0);
              },
              child: _renderToPageButton('0'),
            ),
            GestureDetector(
              onTap: () {
                pageController.animateToPage(1);
              },
              child: _renderToPageButton('1'),
            ),
            GestureDetector(
              onTap: () {
                pageController.animateToPage(2);
              },
              child: _renderToPageButton('2'),
            ),
            GestureDetector(
              onTap: () {
                pageController.nextPage();
              },
              child: _renderToPageButton('Next'),
            ),
          ],
        )
      ],
    );
  }

  Container _renderToPageButton(String v) {
    return Container(
      width: 44,
      height: 44,
      color: Colors.blue,
      child: Center(
        child: Text(
          v,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
