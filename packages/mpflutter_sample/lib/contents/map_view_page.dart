import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class MapViewPage extends StatefulWidget {
  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final controller = MPMiniProgramController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5)).then((value) {
      getContext();
    });
  }

  void getContext() async {
    final ctx = await controller.getContext();
    ctx.callMethod('moveToLocation', [
      {
        'longitude': 112.157667,
        'latitude': 22.043462,
      }
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'MapView (WeChat)',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: Center(
        child: MPMiniProgramView(
          tag: 'map',
          attributes: {
            'longitude': 113.157667,
            'latitude': 23.043462,
          },
          controller: controller,
        ),
      ),
    );
  }
}
