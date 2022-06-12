part of '../mp_flutter_runtime.dart';

class _MPComponentFactory {
  final MPEngine engine;
  final List<Map> _textMeasureResults = [];
  final Map<int, ComponentViewState> _cacheViews = {};

  _MPComponentFactory({required this.engine});

  Widget create(Map? data, {Map? parentData}) {
    if (data != null) {
      String? name = data['name'];
      if (name != null) {
        switch (name) {
          case 'absorb_pointer':
            return _AbsorbPointer(
                data: data, parentData: parentData, componentFactory: this);
          case 'clip_oval':
            return _ClipOval(
                data: data, parentData: parentData, componentFactory: this);
          case 'clip_r_rect':
            return _ClipRRect(
                data: data, parentData: parentData, componentFactory: this);
          case 'colored_box':
            return _ColoredBox(
                data: data, parentData: parentData, componentFactory: this);
          case 'custom_paint':
            return _CustomPaint(
                data: data, parentData: parentData, componentFactory: this);
          case 'custom_scroll_view':
            return _CustomScrollView(
                data: data, parentData: parentData, componentFactory: this);
          case 'editable_text':
            return _EditableText(
                data: data, parentData: parentData, componentFactory: this);
          case 'decorated_box':
            return _DecoratedBox(
                data: data,
                parentData: parentData,
                componentFactory: this,
                isFront: false);
          case 'foreground_decorated_box':
            return _DecoratedBox(
                data: data,
                parentData: parentData,
                componentFactory: this,
                isFront: true);
          case 'sliver_list':
            return _SliverList(
                data: data, parentData: parentData, componentFactory: this);
          case 'sliver_grid':
            return _SliverGrid(
                data: data, parentData: parentData, componentFactory: this);
          case 'sliver_persistent_header':
            return _SliverPersistentHeader(
                data: data, parentData: parentData, componentFactory: this);
          case 'gesture_detector':
            return _GestureDetector(
                data: data, parentData: parentData, componentFactory: this);
          case 'grid_view':
            return _GridView(
                data: data, parentData: parentData, componentFactory: this);
          case 'ignore_pointer':
            return _IgnorePointer(
                data: data, parentData: parentData, componentFactory: this);
          case 'image':
            return _Image(
                data: data, parentData: parentData, componentFactory: this);
          case 'list_view':
            return _ListView(
                data: data, parentData: parentData, componentFactory: this);
          case 'opacity':
            return _Opacity(
                data: data, parentData: parentData, componentFactory: this);
          case 'overlay':
            return _Overlay(
                data: data, parentData: parentData, componentFactory: this);
          case 'rich_text':
            return _RichText(
                data: data, parentData: parentData, componentFactory: this);
          case 'offstage':
            return _Offstage(
                data: data, parentData: parentData, componentFactory: this);
          case 'transform':
            return _Transform(
                data: data, parentData: parentData, componentFactory: this);
          case 'visibility':
            return _Visibility(
                data: data, parentData: parentData, componentFactory: this);
          case 'mp_scaffold':
            return _MPScaffold(
                data: data, parentData: parentData, componentFactory: this);
          case 'mp_date_picker':
            return _MPDatePicker(
                data: data, parentData: parentData, componentFactory: this);
          case 'mp_picker':
            return _MPPicker(
                data: data, parentData: parentData, componentFactory: this);
          case 'mp_icon':
            return _MPIcon(
                data: data, parentData: parentData, componentFactory: this);
          case 'mp_page_view':
            return _MPPageView(
                data: data, parentData: parentData, componentFactory: this);
          case 'mp_switch':
            return _MPSwitch(
                data: data, parentData: parentData, componentFactory: this);
          case 'mp_slider':
            return _MPSlider(
                data: data, parentData: parentData, componentFactory: this);
          case 'mp_circular_progress_indicator':
            return _MPCircularProgressIndicator(
                data: data, parentData: parentData, componentFactory: this);
          default:
            if (MPPluginRegister.registedViews.containsKey(name)) {
              return MPPluginRegister.registedViews[name]!(
                null,
                data,
                parentData,
                this,
              );
            }
            return ComponentView(
                data: data, parentData: parentData, componentFactory: this);
        }
      }
    }
    return Container();
  }

  clear() {
    _textMeasureResults.clear();
    _cacheViews.clear();
  }

  void _callbackTextMeasureResult(dynamic measureId, Size size) {
    _textMeasureResults.add({
      'measureId': measureId,
      'size': {'width': size.width, 'height': size.height},
    });
  }

  void _callbackTextPainterMeasureResult(dynamic measureId, Size size) {
    engine._sendMessage({
      'type': 'rich_text',
      'message': {
        'event': 'onTextPainterMeasured',
        'data': {
          'seqId': measureId,
          'size': {'width': size.width, 'height': size.height},
        },
      },
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
