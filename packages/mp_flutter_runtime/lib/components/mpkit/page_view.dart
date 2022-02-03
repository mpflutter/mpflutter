part of '../../mp_flutter_runtime.dart';

// ignore: must_be_immutable
class _MPPageView extends MPPlatformView {
  BuildContext? context;

  _MPPageView({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  @override
  Future onMethodCall(String method, params) async {
    if (context == null) return;
    if (method == 'animateToPage' && params is Map) {
      int page = params['page'];
      int? duration = params['duration'];
      final state = ComponentViewState.getState(context!);
      if (state is! _MPPageViewState) return const SizedBox();
      state.pageController?.animateToPage(
        page,
        duration: Duration(milliseconds: _Utils.toInt(duration)),
        curve: Curves.ease,
      );
    } else if (method == 'jumpToPage' && params is Map) {
      int page = params['page'];
      final state = ComponentViewState.getState(context!);
      if (state is! _MPPageViewState) return const SizedBox();
      state.pageController?.jumpToPage(page);
    } else if (method == 'nextPage' && params is Map) {
      int? duration = params['duration'];
      final state = ComponentViewState.getState(context!);
      if (state is! _MPPageViewState) return const SizedBox();
      state.pageController?.nextPage(
        duration: Duration(milliseconds: _Utils.toInt(duration)),
        curve: Curves.ease,
      );
    } else if (method == 'previousPage' && params is Map) {
      int? duration = params['duration'];
      final state = ComponentViewState.getState(context!);
      if (state is! _MPPageViewState) return const SizedBox();
      state.pageController?.previousPage(
        duration: Duration(milliseconds: _Utils.toInt(duration)),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget builder(BuildContext context) {
    this.context = context;
    final children = getWidgetsFromChildren(context);
    final state = ComponentViewState.getState(context);
    if (state is! _MPPageViewState) return const SizedBox();
    state.init(initialPage: getIntFromAttributes(context, 'initialPage') ?? 0);
    return PageView.builder(
      scrollDirection:
          getStringFromAttributes(context, 'scrollDirection') == 'Axis.vertical'
              ? Axis.vertical
              : Axis.horizontal,
      itemBuilder: (context, index) {
        if (children == null || children.isEmpty) return const SizedBox();
        return children[index];
      },
      itemCount: (children?.length ?? 0),
      onPageChanged: (currentPage) {
        if (children == null || children.isEmpty) return;
        int index = currentPage;
        invokeMethod('onPageChanged', {'index': index});
      },
      controller: state.pageController,
    );
  }

  @override
  ComponentViewState createState() {
    return _MPPageViewState();
  }
}

class _MPPageViewState extends ComponentViewState {
  PageController? pageController;
  bool _initialized = false;

  void init({required int initialPage}) {
    if (!_initialized) {
      _initialized = true;
      pageController = PageController(initialPage: initialPage);
    }
  }
}
