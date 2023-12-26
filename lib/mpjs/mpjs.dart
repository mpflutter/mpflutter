import './mpjs_dev_impl.dart' if (dart.library.js) './mpjs_js_impl.dart';
export './mpjs_dev_impl.dart' if (dart.library.js) './mpjs_js_impl.dart';

abstract class IContext {
  Function createFunctionArg0(Function dartFunction);
  Function createFunctionArg1(Function dartFunction);
  Function createFunctionArg2(Function dartFunction);
  Function createFunctionArg3(Function dartFunction);
  Function createFunctionArg4(Function dartFunction);
}

abstract class IJSObject {
  dynamic operator [](dynamic key);
  void operator []=(dynamic key, dynamic value);
  dynamic callMethod(String method, [List<dynamic>? arguments]);
  Map asMap();
}

abstract class IJSArray extends IJSObject {
  void add(dynamic value);
  void addAll(List<dynamic> value);
}

abstract class IJSFunction extends IJSObject {
  dynamic call([List<dynamic>? arguments]);
}

final context = Context();
