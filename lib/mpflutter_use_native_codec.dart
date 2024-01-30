import 'package:mpflutter_core/mpflutter_core.dart';

String useNativeCodec(String url) {
  if (kIsMPFlutter && !kIsMPFlutterDevmode) {
    return url + "?use-native-codec=true";
  } else {
    return url;
  }
}
