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
          case 'decorated_box':
            return _DecoratedBox(data: data, isFront: false);
          case 'foreground_decorated_box':
            return _DecoratedBox(data: data, isFront: true);
          case 'sliver_list':
            return _SliverList(data: data);
          case 'sliver_grid':
            return _SliverGrid(data: data);
          case 'sliver_persistent_header':
            return _SliverPersistentHeader(data: data);
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
          case 'rich_text':
            return _RichText(data: data);
          case 'offstage':
            return _Offstage(data: data);
          case 'transform':
            return _Transform(data: data);
          case 'visibility':
            return _Visibility(data: data);
          case 'mp_scaffold':
            return _MPScaffold(data: data);
          case 'mp_icon':
            return _MPIcon(data: data);
          default:
            return ComponentView(data: data);
        }
      }
    }
    return Container();
  }

  MPEngine engine;
  List<Map> _textMeasureResults = [];

  _MPComponentFactory({required this.engine});

  void _callbackTextMeasureResult(int measureId, Size size) {
    _textMeasureResults.add({
      'measureId': measureId,
      'size': {'width': size.width, 'height': size.height},
    });
  }

  void _flushTextMeasureResult() {
    if (_textMeasureResults.isNotEmpty) {
      engine._sendMessage({
        'type': 'rich_text',
        'message': {
          'event': 'onMeasured',
          'data': _textMeasureResults,
        },
      });
      _textMeasureResults.clear();
    }
  }
}
