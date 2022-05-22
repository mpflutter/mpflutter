part of dart.ui;

bool waitingForAnimation = false;
Map<String, bool> disabledChannels = {
  'flutter/navigation': true,
  'flutter/textinput': true,
  'flutter/keyevent': true,
  'flutter/lifecycle': true,
  'flutter/system': true,
  'flutter/platform_views': true,
  'flutter/skia': true,
  'flutter/mousecursor': true,
  'flutter/restoration': true,
  'flutter/assets': true,
};

Future<void> Function(String, ByteData?, PlatformMessageResponseCallback?)?
    pluginMessageCallHandler;

VoidCallback? scheduleFrameCallback = () {
  // We're asked to schedule a frame and call `frameHandler` when the frame
  // fires.
  if (!waitingForAnimation) {
    waitingForAnimation = true;
    requestAnimationFrame((num highResTime) {
      // Reset immediately, because `frameHandler` can schedule more frames.
      waitingForAnimation = false;

      // We have to convert high-resolution time to `int` so we can construct
      // a `Duration` out of it. However, high-res time is supplied in
      // milliseconds as a double value, with sub-millisecond information
      // hidden in the fraction. So we first multiply it by 1000 to uncover
      // microsecond precision, and only then convert to `int`.
      final int highResTimeMicroseconds = (1000 * highResTime).toInt();

      if (mockWindow.onBeginFrame != null) {
        mockWindow.onBeginFrame!
            .call(Duration(microseconds: highResTimeMicroseconds));
      }

      if (mockWindow.onDrawFrame != null) {
        // TODO(yjbanov): technically Flutter flushes microtasks between
        //                onBeginFrame and onDrawFrame. We don't, which hasn't
        //                been an issue yet, but eventually we'll have to
        //                implement it properly.
        mockWindow.onDrawFrame!.call();
      }
    });
  }
};

/// The Web implementation of [ui.Window].
class MockWindow extends Window {
  MockWindow() {
    DeviceInfo.listenDeviceInfoChanged(() {
      onMetricsChanged?.call();
      onPlatformBrightnessChanged?.call();
    });
  }

  double get devicePixelRatio => DeviceInfo.devicePixelRatio;

  Size get physicalSize => Size(
        DeviceInfo.physicalSizeWidth,
        DeviceInfo.physicalSizeHeight,
      );

  WindowPadding get viewInsets => WindowPadding.zero;

  WindowPadding get viewPadding => WindowPadding.zero;

  WindowPadding get systemGestureInsets => WindowPadding.zero;
  WindowPadding get padding => DeviceInfo.windowPadding;
  double get textScaleFactor => _textScaleFactor;
  double _textScaleFactor = 1.0;
  bool get alwaysUse24HourFormat => _alwaysUse24HourFormat;
  bool _alwaysUse24HourFormat = false;
  VoidCallback? get onTextScaleFactorChanged => null;
  set onTextScaleFactorChanged(VoidCallback? callback) {}

  Brightness get platformBrightness => DeviceInfo.platformBrightness;

  VoidCallback? _onPlatformBrightnessChanged;

  VoidCallback? get onPlatformBrightnessChanged => _onPlatformBrightnessChanged;

  set onPlatformBrightnessChanged(VoidCallback? callback) {
    _onPlatformBrightnessChanged = callback;
  }

  VoidCallback? _onMetricsChanged;

  VoidCallback? get onMetricsChanged => _onMetricsChanged;

  set onMetricsChanged(VoidCallback? callback) {
    _onMetricsChanged = callback;
  }

  Locale? get locale => null;

  List<Locale>? get locales => null;

  Locale? computePlatformResolvedLocale(List<Locale> supportedLocales) {
    return null;
  }

  VoidCallback? get onLocaleChanged => null;

  set onLocaleChanged(VoidCallback? callback) {}

  void scheduleFrame() {
    if (scheduleFrameCallback == null) {
      throw new Exception('scheduleFrameCallback must be initialized first.');
    }
    scheduleFrameCallback!();
  }

  FrameCallback? _onBeginFrame;

  FrameCallback? get onBeginFrame => _onBeginFrame;

  set onBeginFrame(FrameCallback? callback) {
    _onBeginFrame = callback;
  }

  TimingsCallback? get onReportTimings => null;
  set onReportTimings(TimingsCallback? callback) {}

  VoidCallback? _onDrawFrame;

  VoidCallback? get onDrawFrame => _onDrawFrame;

  set onDrawFrame(VoidCallback? callback) {
    _onDrawFrame = callback;
  }

  PointerDataPacketCallback? get onPointerDataPacket => null;
  set onPointerDataPacket(PointerDataPacketCallback? callback) {}
  String get defaultRouteName => '';
  bool get semanticsEnabled => false;
  VoidCallback? get onSemanticsEnabledChanged => null;
  set onSemanticsEnabledChanged(VoidCallback? callback) {}
  VoidCallback? get onAccessibilityFeaturesChanged => null;
  set onAccessibilityFeaturesChanged(VoidCallback? callback) {}

  PlatformMessageCallback? _onPlatformMessage;

  PlatformMessageCallback? get onPlatformMessage => _onPlatformMessage;

  set onPlatformMessage(PlatformMessageCallback? callback) {
    _onPlatformMessage = callback;
  }

  void sendPlatformMessage(
    String name,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) {
    if (disabledChannels[name] == true) {
      return;
    }
    if (pluginMessageCallHandler != null) {
      pluginMessageCallHandler!(name, data, callback);
      return;
    }
    Future<void>.delayed(Duration.zero).then((_) {
      if (callback != null) {
        callback(data);
      }
    });
  }

  AccessibilityFeatures get accessibilityFeatures => _accessibilityFeatures;
  AccessibilityFeatures _accessibilityFeatures = AccessibilityFeatures._(0);
  void render(Scene scene) {}

  String get initialLifecycleState => 'AppLifecycleState.resumed';

  void setIsolateDebugName(String name) {}

  ByteData? getPersistentIsolateData() => null;
}

/// The window singleton.
///
/// `dart:ui` window delegates to this value. However, this value has a wider
/// API surface, providing Web-specific functionality that the standard
/// `dart:ui` version does not.
final MockWindow mockWindow = MockWindow();

/// The Web implementation of [ui.WindowPadding].
class MockWindowPadding implements WindowPadding {
  const MockWindowPadding({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
}
