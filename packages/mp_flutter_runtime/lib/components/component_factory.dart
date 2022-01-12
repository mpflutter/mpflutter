part of '../mp_flutter_runtime.dart';

class _MPComponentFactory {
  static Widget create(Map? data) {
    if (data != null) {
      String? name = data['name'];
      if (name != null) {
        switch (name) {
          case 'absorb_pointer':
            return _AbsorbPointer(data: data);
          case 'clip_oval':
            return _ClipOval(data: data);
          case 'clip_r_rect':
            return _ClipRRect(data: data);
          case 'colored_box':
            return _ColoredBox(data: data);
          case 'gesture_detector':
            return _GestureDetector(data: data);
          case 'ignore_pointer':
            return _IgnorePointer(data: data);
          case 'opacity':
            return _Opacity(data: data);
          case 'offstage':
            return _Offstage(data: data);
          case 'transform':
            return _Transform(data: data);
          case 'visibility':
            return _Visibility(data: data);
          case 'mp_scaffold':
            return _MPScaffold(data: data);
          default:
            return ComponentView(data: data);
        }
      }
    }
    return Container();
  }
}
