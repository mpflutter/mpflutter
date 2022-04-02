part of 'mpkit.dart';

class MPMiniProgramEvent {
  final String event;
  final List<String>? callbackParams;
  final Function(Map?) callback;

  MPMiniProgramEvent({
    required this.event,
    this.callbackParams,
    required this.callback,
  });
}

class MPMiniProgramController extends MPPlatformViewController {
  Future<mpjs.JsObject> getContext() async {
    if (targetHashCode == null) throw 'The MPMiniProgramView not ready yet.';
    final obj = await mpjs.context.callMethod(
      'mp_core_weChatComponentContextGetter',
      [targetHashCode],
    );
    return obj;
  }
}

class MPMiniProgramView extends MPPlatformView {
  final String tag;
  final Map? style;
  final Map? attributes;
  final List<MPMiniProgramEvent>? eventListeners;

  @override
  final MPMiniProgramController? controller;

  MPMiniProgramView({
    required this.tag,
    this.style,
    this.attributes,
    this.eventListeners,
    this.controller,
    Widget? child,
    List<Widget>? children,
  }) : super(
          viewType: 'mp_mini_program_view',
          viewAttributes: {
            'tag': tag,
            'style': style,
            ...(attributes ?? {}),
            ...(eventListeners?.asMap().map((key, value) {
                  return MapEntry(
                      'on.${value.event}', value.callbackParams ?? []);
                }) ??
                {})
          }..removeWhere((key, value) => value == null),
          child: child,
          children: children,
          onMethodCall: (method, arguments) {
            if (method.startsWith('on.')) {
              eventListeners?.forEach((element) {
                if (method == 'on.${element.event}') {
                  element.callback(arguments is Map ? arguments : null);
                }
              });
            }
          },
          controller: controller,
        );
}
