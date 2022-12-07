import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';
import 'package:universal_miniprogram_api/wechat_mini_program/map_view.dart';

class MapViewPage extends StatefulWidget {
  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final controller = WechatMiniProgramMapViewController();

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'MapView (WeChat)',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 300,
            color: Colors.grey.shade300,
            child: WechatMiniProgramMapView(
              latitude: 23.043462,
              longitude: 113.157667,
              markers: [
                WechatMiniProgramMapMarker(
                  id: 1,
                  latitude: 23.043462,
                  longitude: 113.157667,
                  title: '千灯湖环宇城',
                ),
                WechatMiniProgramMapMarker(
                  id: 2,
                  latitude: 23.099970,
                  longitude: 113.324511,
                  title: '微信总部',
                ),
              ],
              onTap: (details) {
                print(details);
              },
              onMarkerTap: (details) {
                print(details);
              },
              controller: controller,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              children: [
                _renderButton('moveToLocation', () {
                  controller.moveToLocation(
                    MoveToLocationOption()
                      ..setValues(
                        latitude: 23.099970,
                        longitude: 113.324511,
                      ),
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  GestureDetector _renderButton(String title, Function callback) {
    return GestureDetector(
      onTap: () {
        callback();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4.0),
        ),
        padding: EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 6),
        child: Text(
          title,
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }
}
