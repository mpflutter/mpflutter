import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;

import 'package:http/http.dart';

main(List<String> args) async {
  final versionCode = args.isNotEmpty ? args[0] : null;
  if (versionCode == null) {
    final tags = json.decode((await get(
            Uri.parse('https://api.github.com/repos/mpflutter/mpflutter/tags')))
        .body) as List;
    print('Current available versions:');
    print(
      tags.sublist(0, min(10, tags.length)).map((e) => e['name']).join('\n'),
    );
    print(
      'Please retry with version code to upgrade like \n> dart scripts/upgrade.dart ' +
          tags.first['name'],
    );
  } else {
    final pubspecFile = File(p.join('pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      var pubspecContent = File(p.join('pubspec.yaml')).readAsStringSync();
      pubspecContent = pubspecContent.replaceAllMapped(
          RegExp(r'(mpflutter/mpflutter\n.*?\n.*?ref: ).*'), (match) {
        return "${match.group(1)}${versionCode}";
      });
      File(p.join('pubspec.yaml')).writeAsStringSync(pubspecContent);
      print('Successful upgrade pubspec.');
    }
    final webFile = File(p.join('web', 'index.html'));
    if (webFile.existsSync()) {
      var webIndexHtml = File(p.join('web', 'index.html')).readAsStringSync();
      webIndexHtml = webIndexHtml.replaceAll(
        RegExp(r'mpflutter@.*?/'),
        'mpflutter@${versionCode}/',
      );
      File(p.join('web', 'index.html')).writeAsStringSync(webIndexHtml);
      print('Successful upgrade web project.');
    }
    final weappFile = File(p.join('weapp', 'app.js'));
    if (weappFile.existsSync()) {
      final fileList = [
        'mpdom.min.js',
        'miniprogram_npm/miniprogram_dom/index.js',
        'miniprogram_npm/miniprogram_dom/index.js.map',
        'miniprogram_npm/miniprogram_dom/index.json',
        'miniprogram_npm/miniprogram_dom/index.wxml',
        'miniprogram_npm/miniprogram_dom/index.wxss',
        'miniprogram_npm/miniprogram_dom/lib.js',
        'miniprogram_npm/miniprogram_dom/lib.js.map',
        'miniprogram_npm/miniprogram_dom/renderer.js',
        'miniprogram_npm/miniprogram_dom/renderer.js.map',
        'miniprogram_npm/miniprogram_dom/renderer.json',
        'miniprogram_npm/miniprogram_dom/renderer.wxml',
        'miniprogram_npm/miniprogram_dom/renderer.wxss',
      ];
      for (var item in fileList) {
        final response = await get(
          Uri.parse(
              'https://cdn.jsdelivr.net/gh/mpflutter/mpflutter@0.3.0/packages/mp_dom_runtime/dist_weapp/' +
                  item),
        );
        File(p.join('weapp', item)).writeAsStringSync(response.body);
        print('Successful upgrade weapp ' + item);
      }
    }
  }
}
