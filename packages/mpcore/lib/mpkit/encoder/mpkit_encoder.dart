library mpkit_encoder;

import 'package:mpcore/mpcore.dart';
import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/icon.dart';
import 'package:mpcore/mpkit/platform_view.dart';

part './scaffold.dart';
part './page_view.dart';
part './open_button.dart';
part './icon.dart';
part './platform_view.dart';

class MPKitEncoder {
  static MPElement? fromFlutterElement(Element element) {
    if (element.widget is MPScaffold) {
      return _encodeMPScaffold(element);
    } else if (element.widget is MPPageView) {
      return _encodeMPPageView(element);
    } else if (element.widget is MPOpenButton) {
      return _encodeMPOpenButton(element);
    } else if (element.widget is MPIcon) {
      return _encodeMPIcon(element);
    } else if (element.widget is MPPlatformView) {
      return _encodeMPPlatformView(element);
    } else {
      return null;
    }
  }
}
