import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final webViewController = MPWebViewController();

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

  Widget _renderReloadButton() {
    return GestureDetector(
      onTap: () {
        webViewController.reload();
      },
      child: Container(
        width: 200,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            'Reload WebView',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _renderLoadUrlButton() {
    return GestureDetector(
      onTap: () {
        webViewController.loadUrl('https://qq.com/');
      },
      child: Container(
        width: 200,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            'Load QQ.com',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'WebView',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      onWechatMiniProgramShareAppMessage: (request) async {
        return MPWechatMiniProgramShareInfo(title: request.webViewUrl);
      },
      body: _renderBlock(Column(
        children: [
          _renderHeader('WebView'),
          Container(
            height: 240,
            child: MPWebView(
              url: 'https://www.baidu.com/',
              controller: webViewController,
            ),
          ),
          SizedBox(height: 16),
          _renderReloadButton(),
          SizedBox(height: 16),
          _renderLoadUrlButton(),
          SizedBox(height: 16),
        ],
      )),
    );
  }
}
