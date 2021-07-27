library mpkit_encoder;

import 'package:mpcore/mpcore.dart';
import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/icon.dart';

part './web_view.dart';
part './scaffold.dart';
part './page_view.dart';
part './video_view.dart';
part './open_button.dart';
part './icon.dart';

class MPKitEncoder {
  static MPElement? fromFlutterElement(Element element) {
    if (element.widget is MPWebView) {
      return _encodeMPWebView(element);
    } else if (element.widget is MPScaffold) {
      return _encodeMPScaffold(element);
    } else if (element.widget is MPPageView) {
      return _encodeMPPageView(element);
    } else if (element.widget is MPVideoView) {
      return _encodeMPVideoView(element);
    } else if (element.widget is MPOpenButton) {
      return _encodeMPOpenButton(element);
    } else if (element.widget is MPIcon) {
      return _encodeMPIcon(element);
    } else {
      return null;
    }
  }
}
