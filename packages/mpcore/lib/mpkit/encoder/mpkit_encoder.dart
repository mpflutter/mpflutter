library mpkit_encoder;

import 'package:mpcore/mpcore.dart';
import 'package:flutter/widgets.dart';
import '../mpkit.dart';

part './scaffold.dart';
part './page_view.dart';
part './icon.dart';
part './platform_view.dart';

class MPKitEncoder {
  static Map<Type, MPElement Function(Element)> fromFlutterElementMethodCache =
      {
    MPScaffold: _encodeMPScaffold,
    MPPageView: _encodeMPPageView,
    MPIcon: _encodeMPIcon,
    MPPlatformView: _encodeMPPlatformView,
  };
}
