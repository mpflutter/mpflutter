import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';
import 'package:mpflutter_template/theme.dart';

class MyHomePage extends StatelessWidget {
  Widget _renderBlock(Widget child, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Theme.of(context).segmentBackgroundColor,
          child: child,
        ),
      ),
    );
  }

  Widget _renderHeader(String title, dynamic icon, BuildContext context) {
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
                  color: Theme.of(context).textColor,
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

  Widget _renderItem(String title,
      {required BuildContext context, String? route}) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: 1.0,
          color: Theme.of(context).seperatorColor,
        ),
        GestureDetector(
          onTap: () {
            if (route == null) return;
            Navigator.of(context).pushNamed(route);
          },
          child: Container(
            height: 48,
            color: Theme.of(context).segmentBackgroundColor,
            padding: EdgeInsets.only(left: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style:
                    TextStyle(fontSize: 15, color: Theme.of(context).textColor),
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
      backgroundColor: Theme.of(context).backgroundColor,
      appBarColor: Theme.of(context).appBarColor,
      appBarTintColor: Theme.of(context).textColor,
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
                fontSize: 14,
                color: Theme.of(context).textColor.withOpacity(0.60),
              ),
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('布局类组件', MaterialIcons.layers_outlined, context),
                _renderItem('Container', context: context, route: '/container'),
                _renderItem('Padding', context: context, route: '/padding'),
                _renderItem('Center / Align',
                    context: context, route: '/center'),
                _renderItem('Column / Row / Expanded / Flexible',
                    context: context, route: '/columnRow'),
                _renderItem('Stack / Positioned',
                    context: context, route: '/stack'),
                _renderItem('IndexedStack',
                    context: context, route: '/indexedStack'),
                _renderItem('AspectRatio',
                    context: context, route: '/aspectRatio'),
                _renderItem('Wrap', context: context, route: '/wrap'),
                _renderItem('Transform', context: context, route: '/transform'),
                _renderItem('Table', context: context, route: '/table'),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('列表类组件', MaterialIcons.list_outlined, context),
                _renderItem('ListView', context: context, route: '/listView'),
                _renderItem('DoubleColumnListView',
                    context: context, route: '/doubleColumnListView'),
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
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('内容类组件', MaterialIcons.image_outlined, context),
                _renderItem('Image', context: context, route: '/image'),
                _renderItem('VideoView', context: context, route: '/videoView'),
                _renderItem('WebView', context: context, route: '/webView'),
                _renderItem('Icon', context: context, route: '/icon'),
                _renderItem('Text / RichText',
                    context: context, route: '/text'),
                _renderItem('Chart', context: context, route: '/chart'),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('样式类组件', MaterialIcons.list_outlined, context),
                _renderItem('Opacity', context: context, route: '/opacity'),
                _renderItem('ClipOval', context: context, route: '/clipOval'),
                _renderItem('ClipRRect', context: context, route: '/clipRRect'),
                _renderItem('Offstage / Visibility',
                    context: context, route: '/offstage'),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('自定义组件', MaterialIcons.list_outlined, context),
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
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('触摸', MaterialIcons.touch_app, context),
                _renderItem('GestureDetector',
                    context: context, route: '/gestureDetector'),
                _renderItem('IgnorePointer',
                    context: context, route: '/ignorePointer'),
                _renderItem('AbsorbPointer',
                    context: context, route: '/absorbPointer'),
                _renderItem('EditableText',
                    context: context, route: '/editableText'),
                _renderItem('Signature', context: context, route: '/signature'),
                _renderItem('MouseRegion',
                    context: context, route: '/mouseRegion'),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('动画', MaterialIcons.animation, context),
                _renderItem('AnimationController',
                    context: context, route: '/animationController'),
                _renderItem('AnimatedContainer',
                    context: context, route: '/animatedContainer'),
                _renderItem('PerformanceTest',
                    context: context, route: '/animatedPerformanceTest'),
              ],
            ),
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('页面', MaterialIcons.pages_outlined, context),
                _renderItem('MPScaffold', context: context, route: '/scaffold'),
                _renderItem('TabPage', context: context, route: '/tabPage'),
                _renderItem('Dialogs', context: context, route: '/dialogs'),
                _renderItem('ModalDialogs',
                    context: context, route: '/modalDialogs'),
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
            context,
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('扩展 API', MaterialIcons.extension, context),
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
                _renderItem('File', context: context, route: '/file'),
                _renderItem('Wasm', context: context, route: '/wasm'),
              ],
            ),
            context,
          ),
        ],
      ),
    );
  }
}
