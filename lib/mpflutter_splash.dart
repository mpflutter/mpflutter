import 'mpjs/mpjs.dart' as mpjs;

class MPFlutterSplashManager {
  static void displaySplash() {
    mpjs.JSObject self = mpjs.context["FlutterHostView"]["shared"]["self"];
    self.callMethod("setData", [
      {
        "readyToDisplay": false,
      }
    ]);
  }

  static void hideSplash() {
    mpjs.JSObject self = mpjs.context["FlutterHostView"]["shared"]["self"];
    self.callMethod("setData", [
      {
        "readyToDisplay": true,
      }
    ]);
  }
}
