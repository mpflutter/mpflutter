import './mpjs/mpjs.dart';

class WechatCallbacks {
  static final shared = WechatCallbacks();

  final mpcbObject = JSObject("Object");

  WechatCallbacks() {
    context["wx"]["mpcb"] = mpcbObject;
  }

  set onShow(Function value) {
    mpcbObject["onShow"] = value;
  }

  set onHide(Function value) {
    mpcbObject["onHide"] = value;
  }

  set onAppShareMessage(Function value) {
    mpcbObject["onShareAppMessage"] = value;
  }
}
