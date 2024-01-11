import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import './mpjs/mpjs.dart' as mpjs;

enum MPFlutterImageByteFormat {
  png,
  jpeg,
  webp,
}

class MPFlutterImageEncoder {
  static Future<ByteData?> encodeToBytes({
    required ui.Image image,
    MPFlutterImageByteFormat format = MPFlutterImageByteFormat.png,
    double compressQuality = 0.92,
  }) async {
    final rawRgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (rawRgba == null) return null;
    final completer = Completer<ByteData?>();
    (mpjs.context["encodeImage"] as mpjs.JSFunction).call([
      rawRgba.buffer.asUint8List(),
      image.width,
      image.height,
      "image/${format.name}",
      compressQuality,
      (String result) {
        try {
          final data = base64.decode(result.split("base64,")[1]);
          completer.complete(ByteData.view(data.buffer));
        } catch (e) {
          completer.complete(null);
        }
      }
    ]);
    return completer.future;
  }
}
