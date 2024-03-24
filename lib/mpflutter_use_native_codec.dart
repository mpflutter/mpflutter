import 'package:mpflutter_core/mpflutter_core.dart';

String useNativeCodec(String url) {
  if (kIsMPFlutter && !kIsMPFlutterDevmode) {
    if (url.contains("?use-native-codec=true")) return url;
    return url + "?use-native-codec=true";
  } else {
    return url;
  }
}
