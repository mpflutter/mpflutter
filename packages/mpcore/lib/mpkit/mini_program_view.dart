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

class MPMiniProgramView extends MPPlatformView {
  final String tag;
  final Map? style;
  final Map? attributes;
  final List<MPMiniProgramEvent>? eventListeners;

  MPMiniProgramView({
    required this.tag,
    this.style,
    this.attributes,
    this.eventListeners,
    Widget? child,
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
          onMethodCall: (method, arguments) {
            if (method.startsWith('on.')) {
              eventListeners?.forEach((element) {
                if (method == 'on.${element.event}') {
                  element.callback(arguments is Map ? arguments : null);
                }
              });
            }
          },
        );
}
