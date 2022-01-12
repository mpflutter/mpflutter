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
          case 'custom_scroll_view':
            return _CustomScrollView(data: data);
          case 'sliver_list':
            return _SliverList(data: data);
          case 'sliver_grid':
            return _SliverGrid(data: data);
          case 'gesture_detector':
            return _GestureDetector(data: data);
          case 'grid_view':
            return _GridView(data: data);
          case 'ignore_pointer':
            return _IgnorePointer(data: data);
          case 'list_view':
            return _ListView(data: data);
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
