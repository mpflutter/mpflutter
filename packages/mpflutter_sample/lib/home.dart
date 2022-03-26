import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class MyHomePage extends StatelessWidget {
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

  Widget _renderHeader(String title, dynamic icon) {
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            MPIcon(icon, color: Colors.grey),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _renderItem(String title, {BuildContext? context, String? route}) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: 1.0,
          color: Colors.black.withOpacity(0.05),
        ),
        GestureDetector(
          onTap: () {
            if (context == null || route == null) return;
            Navigator.of(context).pushNamed(route);
          },
          child: Container(
            height: 48,
            color: Colors.white,
            padding: EdgeInsets.only(left: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'Samples',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 22),
            child: Center(
              child: MPIcon(
                MaterialIcons.widgets,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 16, top: 12, right: 16),
            child: Text(
              '以下将展示 MPFlutter 的官方组件能力，开发者可根据需要组合各个组件，满足业务需要，更多组件属性请参考 https://flutter.dev 或 https://mpflutter.com/ 。',
              style: TextStyle(
                  fontSize: 14, color: Colors.black.withOpacity(0.60)),
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('布局类组件', MaterialIcons.layers_outlined),
                _renderItem('Container', context: context, route: '/container'),
                _renderItem('Padding', context: context, route: '/padding'),
                _renderItem('Center / Align',
                    context: context, route: '/center'),
                _renderItem('Column / Row / Expanded / Flexible',
                    context: context, route: '/columnRow'),
                _renderItem('Stack / Positioned',
                    context: context, route: '/stack'),
                _renderItem('AspectRatio',
                    context: context, route: '/aspectRatio'),
                _renderItem('Wrap', context: context, route: '/wrap'),
                _renderItem('Transform', context: context, route: '/transform'),
                _renderItem('Table', context: context, route: '/table'),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('列表类组件', MaterialIcons.list_outlined),
                _renderItem('ListView', context: context, route: '/listView'),
                _renderItem('ListView + LoadMore',
                    context: context, route: '/listViewLoadMore'),
                _renderItem('GridView', context: context, route: '/gridView'),
                _renderItem('GridView / Waterfall',
                    context: context, route: '/gridViewWaterfall'),
                _renderItem('CustomScrollView',
                    context: context, route: '/customScrollView'),
                _renderItem('PageView', context: context, route: '/pageView'),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('内容类组件', MaterialIcons.image_outlined),
                _renderItem('Image', context: context, route: '/image'),
                _renderItem('VideoView', context: context, route: '/videoView'),
                _renderItem('WebView', context: context, route: '/webView'),
                _renderItem('Icon', context: context, route: '/icon'),
                _renderItem('Text / RichText',
                    context: context, route: '/text'),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('样式类组件', MaterialIcons.list_outlined),
                _renderItem('Opacity', context: context, route: '/opacity'),
                _renderItem('ClipOval', context: context, route: '/clipOval'),
                _renderItem('ClipRRect', context: context, route: '/clipRRect'),
                _renderItem('Offstage / Visibility',
                    context: context, route: '/offstage'),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('自定义组件', MaterialIcons.list_outlined),
                _renderItem(
                  'CustomPaint / Canvas',
                  context: context,
                  route: '/customPaint',
                ),
                _renderItem(
                  'CustomPaint(Async) / Canvas',
                  context: context,
                  route: '/customPaintAsync',
                ),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('触摸', MaterialIcons.touch_app),
                _renderItem('GestureDetector',
                    context: context, route: '/gestureDetector'),
                _renderItem('IgnorePointer',
                    context: context, route: '/ignorePointer'),
                _renderItem('AbsorbPointer',
                    context: context, route: '/absorbPointer'),
                _renderItem('EditableText',
                    context: context, route: '/editableText'),
                _renderItem('Signature', context: context, route: '/signature'),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('动画', MaterialIcons.animation),
                _renderItem('AnimationController',
                    context: context, route: '/animationController'),
                _renderItem('AnimatedContainer',
                    context: context, route: '/animatedContainer'),
                _renderItem('PerformanceTest',
                    context: context, route: '/animatedPerformanceTest'),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('页面', MaterialIcons.pages_outlined),
                _renderItem('MPScaffold', context: context, route: '/scaffold'),
                _renderItem('TabPage', context: context, route: '/tabPage'),
                _renderItem('Dialogs', context: context, route: '/dialogs'),
                _renderItem(
                  'DeferedPage',
                  context: context,
                  route: '/deferedPage',
                ),
                _renderItem('Forms', context: context, route: '/forms'),
                _renderItem('MainTabView',
                    context: context, route: '/mainTabView'),
                _renderItem('Route Test',
                    context: context, route: '/routeTest'),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('扩展 API', MaterialIcons.extension),
                _renderItem('SharedPreference',
                    context: context, route: '/sharedPreference'),
                _renderItem('HTTP Network',
                    context: context, route: '/httpNetwork'),
                _renderItem('Plugin', context: context, route: '/plugin'),
                _renderItem('ClipBoard', context: context, route: '/clipBoard'),
                _renderItem('通用小程序 API',
                    context: context, route: '/miniprogramApi'),
                _renderItem('MapView (WeChat)',
                    context: context, route: '/mapView'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
