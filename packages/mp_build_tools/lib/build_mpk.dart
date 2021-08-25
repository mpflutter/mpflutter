import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

main(List<String> args) {
  _checkPubspec();
  _createBuildDir();
  _buildDartJS();
  _buildMpk();
}

_checkPubspec() {
  if (!File('pubspec.yaml').existsSync()) {
    throw '''
    The pubspec.yaml not exists, confirm you are in the mpflutter project root dir. [EN]
    pubspec.yaml 文件不存在，请确认您当前处于 mpflutter 工程根目录。[ZH]
    ''';
  }
}

_createBuildDir() {
  if (!Directory('build').existsSync()) {
    Directory('build').createSync();
  } else {
    Directory('build').deleteSync(recursive: true);
    Directory('build').createSync();
  }
}

String _buildDartJS() {
  Process.runSync(
      'dart2js',
      [
        'lib/main.dart',
        '-O4',
        '-Ddart.vm.product=true',
        '-o',
        'build/main.dart.js'
      ],
      runInShell: true);
  Process.runSync(
    'flutter',
    [
      'build',
      'bundle',
    ],
    runInShell: true,
  );
  if (Directory('./build/flutter_assets').existsSync()) {
    Directory('./build/flutter_assets').renameSync('./build/assets');
  }
  _removeFiles([
    './build/assets/isolate_snapshot_data',
    './build/assets/kernel_blob.bin',
    './build/assets/vm_snapshot_data',
    './build/snapshot_blob.bin.d'
  ]);
  return File('./build/assets/.last_build_id')
      .readAsStringSync()
      .substring(0, 6);
}

_buildMpk() {
  final allFiles = <String, File>{};
  allFiles['main.dart.js'] = (() {
    return File(Directory('build')
        .listSync()
        .firstWhere((element) => element.path.endsWith('.js'))
        .path);
  })();
  void pushAsset(String prefix) {
    if (Directory('build/assets/$prefix').existsSync()) {
      Directory('build/assets/$prefix').listSync().forEach((element) {
        final name = prefix + "/" + element.path.split('/').last;
        if (element.statSync().type == FileSystemEntityType.directory) {
          pushAsset(name);
        } else {
          allFiles[name] = File(element.path);
        }
      });
    }
  }

  pushAsset('assets');
  final mpkFile = MPKFile(allFiles);
  final data = mpkFile.encode();
  File('build/app.mpk').writeAsBytesSync(data);
}

_removeFiles(List<String> files) {
  files.forEach((element) {
    try {
      File(element).deleteSync();
    } catch (e) {}
  });
}

/// The mpk file format:
/// File starts with 4 bytes, [0, 109, 112, 107] as mpk ACSII code.
/// The next 4 bytes descripts the file index bytes length -> $a.
/// The next $a bytes contains the file index data, save as utf-8, encoded as json string.
/// The next part of bytes are datas of the files.
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
