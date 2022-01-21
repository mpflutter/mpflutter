part of './mp_flutter_runtime.dart';

class _MPKReader {
  late Map fileIndex;
  late Uint8List fileDatas;

  _MPKReader(Uint8List data) {
    final decodedData = _inflateData(data);
    fileIndex = _decodeFileIndex(decodedData);
  }

  static Uint8List _inflateData(Uint8List data) {
    if (data.lengthInBytes < 4) throw 'invalid mpk data';
    Uint8List bufferData = data.buffer.asUint8List();
    final fileHeader = bufferData.sublist(0, 4);
    if (fileHeader[0] == 0 &&
        fileHeader[1] == 109 &&
        fileHeader[2] == 112 &&
        fileHeader[3] == 107) {
      return Uint8List.fromList(
        const archive.ZLibDecoder().decodeBytes(bufferData.sublist(4)),
      );
    } else {
      throw 'invalid mpk data';
    }
  }

  Map _decodeFileIndex(Uint8List data) {
    final fileIndexSizeData = data.sublist(4, 8);
    int fileIndexSize = fileIndexSizeData[0] * 255 * 255 * 255 +
        fileIndexSizeData[1] * 255 * 255 +
        fileIndexSizeData[2] * 255 +
        fileIndexSizeData[3];
    Uint8List fileIndexData = data.sublist(8, 8 + fileIndexSize);
    final jsonData = json.decode(utf8.decode(fileIndexData));
    if (jsonData is Map) {
      fileDatas = data.sublist(8 + fileIndexSize);
      return jsonData;
    } else {
      throw 'invalid mpk data, fileIndexData not found.';
    }
  }

  Uint8List? dataWithFilePath(String filePath) {
    final fileInfo = fileIndex[filePath];
    if (fileInfo == null) return null;
    int location = fileInfo['location'];
    int length = fileInfo['length'];
    return fileDatas.sublist(location, location + length);
  }
}
