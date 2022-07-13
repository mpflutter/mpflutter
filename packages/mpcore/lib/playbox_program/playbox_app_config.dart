import 'package:flutter/material.dart';

class PlayBoxAppConfig {
  String appId;
  PlayBoxAppType appType;
  PlayBoxCoverInfo coverInfo;
  PlayBoxCategoryInfo? categoryInfo;

  PlayBoxAppConfig({
    required this.appId,
    this.appType = PlayBoxAppType.applet,
    required this.coverInfo,
    this.categoryInfo,
  });

  static PlayBoxAppConfig fromJSON(Map json) {
    return PlayBoxAppConfig(
      appId: json['appId'],
      appType: (() {
        switch (json['appType']) {
          case 'applet':
            return PlayBoxAppType.applet;
          default:
            return PlayBoxAppType.applet;
        }
      })(),
      coverInfo: PlayBoxCoverInfo.fromJSON(json['coverInfo']),
    );
  }

  Map toJson() {
    return {
      'appId': appId,
      'appType': appType.toString().replaceAll('PlayBoxAppType.', ''),
      'coverInfo': coverInfo,
      'categoryInfo': categoryInfo,
    }..removeWhere((key, value) => value == null);
  }
}

enum PlayBoxAppType {
  applet,
}

class PlayBoxCoverInfo {
  String name;
  String? description;
  String? icon;
  Color color;

  PlayBoxCoverInfo({
    required this.name,
    this.description,
    this.icon,
    required this.color,
  });

  static PlayBoxCoverInfo fromJSON(Map json) {
    return PlayBoxCoverInfo(
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

class PlayBoxCategoryInfo {
  String name;

  PlayBoxCategoryInfo({required this.name});

  Map toJson() {
    return {
      'name': name,
    }..removeWhere((key, value) => value == null);
  }
}
