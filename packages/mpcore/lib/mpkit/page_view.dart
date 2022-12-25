part of 'mpkit.dart';

class MPPageController extends MPPlatformViewController with ChangeNotifier {
  MPPageController({this.initialPage = 0}) {
    _page = initialPage;
  }

  int initialPage;

  int _page = 0;

  int get page => _page;

  void animateToPage(
    int page, {
    Duration? duration,
    Curve? curve,
  }) {
    invokeMethod('animateToPage', params: {
      'page': page,
      'duration': duration?.inMilliseconds,
    });
  }

  void jumpToPage(int page) {
    invokeMethod('jumpToPage', params: {'page': page});
  }

  void nextPage({Duration? duration, Curve? curve}) {
    invokeMethod('nextPage', params: {
      'duration': duration?.inMilliseconds,
    });
  }

  void previousPage({Duration? duration, Curve? curve}) {
    invokeMethod('previousPage', params: {
      'duration': duration?.inMilliseconds,
    });
  }

  @override
  Future? onMethodCall(String method, Map? params) {
    if (method == 'onPageChanged') {
      _page = (params?['index'] as num).toInt();
      notifyListeners();
    }
    return null;
  }
}

class MPPageView extends MPPlatformView {
  @override
  final MPPageController? controller;
  @override
  final List<Widget> children;
  final Axis scrollDirection;
  final bool loop;
  final bool autoplay;

  const MPPageView({
    required this.children,
    this.scrollDirection = Axis.horizontal,
    this.loop = false,
    this.autoplay = false,
    this.controller,
  }) : super(
          viewType: 'mp_page_view',
          controller: controller,
          children: children,
        );
}
