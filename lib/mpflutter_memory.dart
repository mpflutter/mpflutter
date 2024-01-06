import 'package:flutter/widgets.dart';
import 'mpjs/mpjs.dart' as mpjs;

void setupMemoryManager() {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 30 << 20;
  (mpjs.context["wx"] as mpjs.JSObject).callMethod("onMemoryWarning", [
    (res) {
      PaintingBinding.instance.imageCache.clear();
    }
  ]);
}
