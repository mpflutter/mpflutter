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

  Map toJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color.value.toString(),
    }..removeWhere((key, value) => value == null);
  }
}
