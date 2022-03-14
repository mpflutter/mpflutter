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

class _MPPageState extends State<MPPage> with MPDataReceiver, RouteAware {
  bool firstSetted = false;
  ModalRoute? route;
  int? viewId;
  Map? scaffoldData;
  List? overlaysData;
  final containerKey = GlobalKey();

  @override
  void dispose() {
    super.dispose();
    if (route != null && !route!.isActive && viewId != null) {
      widget.engine._router._disposeRoute(viewId!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!firstSetted) {
      firstSetted = true;
      route = ModalRoute.of(context);
      Future.delayed(const Duration(milliseconds: 32)).then((_) {
        final renderBox = containerKey.currentContext?.findRenderObject();
        if (renderBox is RenderBox) {
          final size = renderBox.size;
          widget.engine._router.requestRoute(viewport: size).then((viewId) {
            this.viewId = viewId;
            widget.engine._addManageView(viewId, this);
          });
        } else {
          final size = Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height -
                (widget.engine.provider.uiProvider.appBarHeight() ?? 0) -
                (!widget.engine.provider.uiProvider.isFullScreen()
                    ? MediaQuery.of(context).padding.top
                    : 0) -
                (!widget.engine.provider.uiProvider.isFullScreen()
                    ? MediaQuery.of(context).padding.bottom
                    : 0),
          );
          widget.engine._router.requestRoute(viewport: size).then((viewId) {
            this.viewId = viewId;
            widget.engine._addManageView(viewId, this);
          });
        }
      });
    }
  }

  @override
  NavigatorState? getNavigator() {
    return Navigator.of(context);
  }

  @override
  BuildContext? getContext() {
    return context;
  }

  @override
  void didReceivedFrameData(Map message) {
    setState(() {
      if (!mounted) return;
      if (message['ignoreScaffold'] != true) {
        scaffoldData = message['scaffold'];
      }
      overlaysData = message['overlays'];
    });
  }

  void onReachBottom() {
    if (scaffoldData != null) {
      widget.engine._sendMessage({
        "type": "scaffold",
        "message": {
          "event": "onReachBottom",
          "target": scaffoldData!['hashCode'],
        },
      });
    }
  }

  void onPageScroll(double y) {
    if (scaffoldData != null) {
      widget.engine._sendMessage({
        "type": "scaffold",
        "message": {
          "event": "onPageScroll",
          "target": scaffoldData!['hashCode'],
          "scrollTop": y,
        },
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (viewId == null) {
      return Scaffold(
        appBar:
            widget.engine.provider.uiProvider.createAppBar(context: context),
        body: Container(key: containerKey, color: Colors.white),
      );
    }
    final widgets = <Widget>[];
    if (scaffoldData != null) {
      widgets.add(widget.engine._componentFactory.create(scaffoldData));
    }
    if (overlaysData != null) {
      for (final element in overlaysData!) {
        widgets.add(widget.engine._componentFactory.create(element));
      }
    }
    if (widgets.length == 1) {
      return widgets[0];
    } else {
      return Stack(
        children: widgets
            .map<Widget>(
              (it) => Positioned.fill(child: it),
            )
            .toList(),
      );
    }
  }
}
