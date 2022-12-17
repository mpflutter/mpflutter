part of './mp_flutter_runtime.dart';

class MPPage extends StatefulWidget {
  final MPEngine engine;
  final String? initialRoute;
  final Map? initialParams;
  final Widget? splash;

  const MPPage({
    Key? key,
    required this.engine,
    this.initialRoute,
    this.initialParams,
    this.splash,
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
  void Function()? debuggerStateListener;

  @override
  void dispose() {
    super.dispose();
    final debugger = widget.engine.debugger;
    if (debugger != null && debuggerStateListener != null) {
      debugger.removeListener(debuggerStateListener!);
    }
    if (route != null && !route!.isActive && viewId != null) {
      widget.engine._router._disposeRoute(viewId!);
    }
  }

  @override
  void initState() {
    super.initState();
    _listenDebuggerState();
  }

  void _listenDebuggerState() {
    final debugger = widget.engine.debugger;
    if (debugger != null) {
      debuggerStateListener = () {
        if (debugger.connected) {
          firstSetted = false;
          _requestRoute();
        } else {
          if (!mounted) return;
          final currentRoute = ModalRoute.of(context);
          if (currentRoute != null && currentRoute.isActive) {
            Navigator.of(context).popUntil(
              (route) => route == ModalRoute.of(context),
            );
          }
          setState(() {
            viewId = null;
          });
        }
      };
      debugger.addListener(debuggerStateListener!);
    }
  }

  void _requestRoute() {
    if (!firstSetted) {
      firstSetted = true;
      route = ModalRoute.of(context);
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
                  : 0),
        );
        widget.engine._router.requestRoute(viewport: size).then((viewId) {
          this.viewId = viewId;
          widget.engine._addManageView(viewId, this);
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestRoute();
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
    if (!mounted) return;
    setState(() {
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
      return widget.splash ??
          Scaffold(
            appBar: widget.engine.provider.uiProvider
                .createAppBar(context: context),
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
