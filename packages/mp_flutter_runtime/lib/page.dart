part of './mp_flutter_runtime.dart';

class MPPage extends StatefulWidget {
  final MPEngine engine;
  final String? initialRoute;
  final Map? initialParams;

  const MPPage({
    Key? key,
    required this.engine,
    this.initialRoute,
    this.initialParams,
  }) : super(key: key);

  @override
  State<MPPage> createState() => _MPPageState();
}

class _MPPageState extends State<MPPage> with MPDataReceiver {
  int? viewId;
  Map? scaffoldData;

  @override
  void initState() {
    super.initState();
    widget.engine._router.requestRoute().then((viewId) {
      this.viewId = viewId;
      widget.engine._addManageView(viewId, this);
    });
  }

  @override
  void didReceivedFrameData(Map message) {
    setState(() {
      scaffoldData = message['scaffold'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (scaffoldData != null) {
      return _MPComponentFactory.create(
        scaffoldData,
      );
    }
    return Container();
  }
}
