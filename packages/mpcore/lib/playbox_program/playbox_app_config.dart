import 'package:flutter/material.dart';

class PlayboxAppConfig {
  String appId;
  PlayboxAppType appType;
  PlayboxCoverInfo coverInfo;

  PlayboxAppConfig({
    required this.appId,
    this.appType = PlayboxAppType.applet,
    required this.coverInfo,
  });

  static PlayboxAppConfig fromJSON(Map json) {
    return PlayboxAppConfig(
      appId: json['appId'],
      appType: (() {
        switch (json['appType']) {
          case 'applet':
            return PlayboxAppType.applet;
          default:
            return PlayboxAppType.applet;
        }
      })(),
      coverInfo: PlayboxCoverInfo.fromJSON(json['coverInfo']),
    );
  }

  Map toJson() {
    return {
      'appId': appId,
      'appType': appType.name,
      'coverInfo': coverInfo,
    }..removeWhere((key, value) => value == null);
  }
}

enum PlayboxAppType {
  applet,
}

class PlayboxCoverInfo {
  String name;
  String? description;
  String? icon;
  Color color;

  PlayboxCoverInfo({
    required this.name,
    this.description,
    this.icon,
    required this.color,
  });

  static PlayboxCoverInfo fromJSON(Map json) {
    return PlayboxCoverInfo(
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: Color(int.tryParse(json['color']) ?? 0),
    );
  }

  Map toJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color.value.toString(),
    }..removeWhere((key, value) => value == null);
  }
}
