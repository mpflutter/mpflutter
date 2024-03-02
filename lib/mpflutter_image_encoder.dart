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
  /// 不建议使用该方法，该方法使用 base64.decode 会导致严重卡顿。
  /// 建议使用 encodeToFilePath 或 encodeToBase64
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

  /// 保存 Image 成 Base64 字符串
  static Future<String?> encodeToBase64({
    required ui.Image image,
    MPFlutterImageByteFormat format = MPFlutterImageByteFormat.png,
    double compressQuality = 0.92,
  }) async {
    final rawRgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (rawRgba == null) return null;
    final completer = Completer<String?>();
    (mpjs.context["encodeImage"] as mpjs.JSFunction).call([
      rawRgba.buffer.asUint8List(),
      image.width,
      image.height,
      "image/${format.name}",
      compressQuality,
      (String result) {
        try {
          completer.complete(result.split("base64,")[1]);
        } catch (e) {
          completer.complete(null);
        }
      }
    ]);
    return completer.future;
  }

  /// 直接将 Image 保存成小程序文件，然后你可以使用 WX API 上传到服务器，或使用 WX API 保存到用户相册。
  static Future<String> encodeToFilePath({
    required ui.Image image,
    required String filePath,
    MPFlutterImageByteFormat format = MPFlutterImageByteFormat.png,
    double compressQuality = 0.92,
  }) async {
    final rawRgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (rawRgba == null) {
      throw "no raw rgba data";
    }
    final completer = Completer<String>();
    (mpjs.context["encodeImageToFilePath"] as mpjs.JSFunction).call([
      rawRgba.buffer.asUint8List(),
      image.width,
      image.height,
      "image/${format.name}",
      compressQuality,
      filePath,
      (String filePath) {
        if (filePath.isEmpty) {
          throw "save file failed";
        }
        completer.complete(filePath);
      }
    ]);
    return completer.future;
  }
}
