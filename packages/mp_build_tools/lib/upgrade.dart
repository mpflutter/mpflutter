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
    final masterBranch = json.decode((await get(Uri.parse(
            'https://api.github.com/repos/mpflutter/mpflutter/branches/master')))
        .body) as Map;
    print('Current master version >>> ' +
        (masterBranch['commit']['sha'] as String).substring(0, 7));
    print('Current release versions >>>');
    print(
      tags.sublist(0, min(10, tags.length)).map((e) => e['name']).join('\n'),
    );
    print(
      'Retry with version code to upgrade for example \n> dart scripts/upgrade.dart ' +
          tags.first['name'],
    );
  } else {
    final pubspecFile = File(p.join('pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      var pubspecContent = File(p.join('pubspec.yaml')).readAsStringSync();
      pubspecContent = pubspecContent.replaceAllMapped(
          RegExp(r'(mpflutter/mpflutter\n.*?\n.*?ref: ).*'), (match) {
        return '${match.group(1)}${versionCode}';
      });
      File(p.join('pubspec.yaml')).writeAsStringSync(pubspecContent);
      print('Successful upgrade pubspec.');
    }
    final webFile = File(p.join('web', 'index.html'));
    if (webFile.existsSync()) {
      var webIndexHtml = File(p.join('web', 'index.html')).readAsStringSync();
      webIndexHtml = webIndexHtml.replaceAll(
        RegExp(r'mpflutter/dist/.*?/'),
        'mpflutter/dist/${versionCode}/',
      );
      File(p.join('web', 'index.html')).writeAsStringSync(webIndexHtml);
      print('Successful upgrade web project.');
    }
    final weappFile = File(p.join('weapp', 'app.js'));
    if (weappFile.existsSync()) {
      final fileList = [
        'mpdom.min.js',
        'kbone/miniprogram-element/index-vhost.js',
        'kbone/miniprogram-element/index.wxml',
        'kbone/miniprogram-element/template/subtree.wxml',
        'kbone/miniprogram-element/template/inner-component.wxml',
        'kbone/miniprogram-element/template/subtree-cover.wxml',
        'kbone/miniprogram-element/index.js',
        'kbone/miniprogram-element/index.wxss',
        'kbone/miniprogram-element/index-vhost.json',
        'kbone/miniprogram-element/base.js',
        'kbone/miniprogram-element/custom-component/index.wxml',
        'kbone/miniprogram-element/custom-component/index.js',
        'kbone/miniprogram-element/custom-component/index.wxss',
        'kbone/miniprogram-element/custom-component/index.json',
        'kbone/miniprogram-element/index-vhost.wxss',
        'kbone/miniprogram-element/base.js.map',
        'kbone/miniprogram-element/index.json',
        'kbone/miniprogram-element/index-vhost.wxml',
        'kbone/miniprogram-render/index.js',
        'kbone/miniprogram-render/index.js.map'
      ];
      for (var item in fileList) {
        final response = await get(
          Uri.parse(
              'https://cdn.jsdelivr.net/gh/mpflutter/dist/$versionCode/dist_weapp/' +
                  item),
        );
        File(p.join('weapp', item)).writeAsStringSync(response.body);
        print('Successful upgrade weapp ' + item);
      }
    }
    final swanappFile = File(p.join('swanapp', 'app.js'));
    if (swanappFile.existsSync()) {
      final fileList = [
        'mpdom.min.js',
        'kbone/miniprogram-element/index-vhost.js',
        'kbone/miniprogram-element/index.swan',
        'kbone/miniprogram-element/template/subtree.swan',
        'kbone/miniprogram-element/template/inner-component.swan',
        'kbone/miniprogram-element/template/subtree-cover.swan',
        'kbone/miniprogram-element/index.js',
        'kbone/miniprogram-element/index.css',
        'kbone/miniprogram-element/index-vhost.json',
        'kbone/miniprogram-element/base.js',
        'kbone/miniprogram-element/custom-component/index.swan',
        'kbone/miniprogram-element/custom-component/index.js',
        'kbone/miniprogram-element/custom-component/index.css',
        'kbone/miniprogram-element/custom-component/index.json',
        'kbone/miniprogram-element/index-vhost.css',
        'kbone/miniprogram-element/base.js.map',
        'kbone/miniprogram-element/index.json',
        'kbone/miniprogram-element/index-vhost.swan',
        'kbone/miniprogram-render/index.js',
        'kbone/miniprogram-render/index.js.map'
      ];
      for (var item in fileList) {
        final response = await get(
          Uri.parse(
              'https://cdn.jsdelivr.net/gh/mpflutter/dist/$versionCode/dist_swan/' +
                  item),
        );
        File(p.join('swanapp', item)).writeAsStringSync(response.body);
        print('Successful upgrade swanapp ' + item);
      }
    }
  }
}
