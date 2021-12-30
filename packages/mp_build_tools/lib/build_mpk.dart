import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'i18n.dart';
import 'package:path/path.dart' as p;

main(List<String> args) {
  _checkPubspec();
  _createBuildDir();
  _buildDartJS();
  _buildMpk();
}

_checkPubspec() {
  if (!File('pubspec.yaml').existsSync()) {
    throw I18n.pubspecYamlNotExists();
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

void _buildDartJS() {
  Process.runSync(
      'dart2js',
      [
        p.join('lib', 'main.dart'),
        '-O4',
        '-Ddart.vm.product=true',
        '-o',
        p.join('build', 'main.dart.js'),
      ],
      runInShell: true);
  Process.runSync(
    'flutter',
    [
      'build',
      'bundle',
    ],
    runInShell: true,
    environment: {'PUB_HOSTED_URL': 'https://pub.mpflutter.com'},
  );
  if (Directory(p.join('build', 'flutter_assets')).existsSync()) {
    Directory(p.join('build', 'flutter_assets'))
        .renameSync(p.join('build', 'assets'));
  }
  _removeFiles([
    p.join('build', 'assets', 'isolate_snapshot_data'),
    p.join('build', 'assets', 'kernel_blob.bin'),
    p.join('build', 'assets', 'vm_snapshot_data'),
    p.join('build', 'assets', 'snapshot_blob.bin.d'),
  ]);
}

_buildMpk() {
  final allFiles = <String, File>{};
  Directory('build').listSync().forEach((element) {
    if (element.path.endsWith('.js')) {
      allFiles[element.path.replaceFirst('build/', '')] = File(element.path);
    }
  });
  void pushAsset(String prefix) {
    if (Directory(p.join('build', 'assets', prefix)).existsSync()) {
      Directory(p.join('build', 'assets', prefix))
          .listSync()
          .forEach((element) {
        final name = prefix + "/" + p.basename(element.path);
        if (element.statSync().type == FileSystemEntityType.directory) {
          pushAsset(name);
        } else {
          allFiles[name] = File(element.path);
        }
      });
    }
  }

  pushAsset('assets');
  print(allFiles);
  final mpkFile = MPKFile(allFiles);
  final data = mpkFile.encode();
  File(p.join('build', 'app.mpk')).writeAsBytesSync(data);
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
