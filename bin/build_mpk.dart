part of 'mpflutter.dart';

/**
 * The mpk file format:
 * File starts with 4 bytes, [0, 109, 112, 107] as mpk ACSII code.
 * The next 4 bytes descripts the file index bytes length -> $a.
 * The next $a bytes contains the file index data, save as utf-8, encoded as json string.
 * The next part of bytes are datas of the files.
 */

class MPKFileIndex {
  final int location;
  final int length;

  MPKFileIndex(this.location, this.length);

  Map toJson() {
    return {'location': location, 'length': length};
  }
}

class MPKFile {
  final Map<String, File> allFiles;

  MPKFile(this.allFiles);

  Uint8List encode() {
    final data = <int>[];
    data.addAll([0, 109, 112, 107]);
    final fileIndex = <String, MPKFileIndex>{};
    final blobData = <int>[];
    allFiles.forEach((key, value) {
      final fileData = value.readAsBytesSync().toList();
      final fileDataLength = fileData.length;
      fileIndex[key] = MPKFileIndex(blobData.length, fileDataLength);
      blobData.addAll(fileData);
    });
    final fileIndexData = utf8.encode(json.encode(fileIndex)).toList();
    data.addAll([
      fileIndexData.length >> 24 & 255,
      fileIndexData.length >> 16 & 255,
      fileIndexData.length >> 8 & 255,
      fileIndexData.length >> 0 & 255
    ]);
    data.addAll(fileIndexData);
    data.addAll(blobData);
    final encodedData = zlib.encode(data).toList();
    encodedData.insertAll(0, [0, 109, 112, 107]);
    return Uint8List.fromList(encodedData);
  }
}

_buildMpk() {
  _buildWeb();
  final allFiles = <String, File>{};
  allFiles['main.dart.js'] = (() {
    return File(Directory('build/web')
        .listSync()
        .firstWhere((element) => element.path.endsWith('.js'))
        .path);
  })();
  void pushAsset(String prefix) {
    Directory('build/web/assets/${prefix}').listSync().forEach((element) {
      final name = prefix + "/" + element.path.split('/').last;
      if (element.statSync().type == FileSystemEntityType.directory) {
        pushAsset(name);
      } else {
        allFiles[name] = File(element.path);
      }
    });
  }

  pushAsset('assets');
  final mpkFile = MPKFile(allFiles);
  final data = mpkFile.encode();
  File('build/app.mpk').writeAsBytesSync(data);
}
