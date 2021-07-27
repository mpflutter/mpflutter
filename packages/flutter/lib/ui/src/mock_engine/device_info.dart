import 'package:flutter/ui/ui.dart';

class DeviceInfo {
  static double physicalSizeWidth = 375.0 * 2.0;
  static double physicalSizeHeight = 667.0 * 2.0;
  static double devicePixelRatio = 2.0;
  static WindowPadding windowPadding = WindowPadding.zero;
  static Function? deviceSizeChangeCallback;
  static void listenDeviceSizeChanged(Function callback) {
    deviceSizeChangeCallback = callback;
  }
}
