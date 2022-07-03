part of 'mpkit.dart';

const hostType = String.fromEnvironment('mpflutter.hostType', defaultValue: '');

enum MPEnvHostType {
  unknown,
  browser,
  wechatMiniProgram,
  ttMiniProgram,
  playboxProgram,
}

enum MPEnvHostOperationSystemType {
  unknown,
  ios,
  android,
  macos,
  windows,
  linux,
  web,
}

class MPEnv {
  static MPEnvHostType? debugEnvHost;

  static MPEnvHostType envHost() {
    if (debugEnvHost != null) {
      return debugEnvHost!;
    }
    if (hostType == 'wechatMiniProgram') {
      return MPEnvHostType.wechatMiniProgram;
    } else if (hostType == 'ttMiniProgram') {
      return MPEnvHostType.ttMiniProgram;
    } else if (hostType == 'browser') {
      return MPEnvHostType.browser;
    } else if (hostType == 'playboxProgram') {
      return MPEnvHostType.playboxProgram;
    } else {
      return MPEnvHostType.unknown;
    }
  }

  static Future<MPEnvHostOperationSystemType> envOperationSystem() async {
    if (envHost() == MPEnvHostType.wechatMiniProgram) {
      final value = await mpjs.context['wx'].callMethod('getSystemInfoSync');
      final platform = await value.getPropertyValue('platform') as String;
      switch (platform) {
        case 'windows':
          return MPEnvHostOperationSystemType.windows;
        case 'mac':
          return MPEnvHostOperationSystemType.macos;
        case 'ios':
          return MPEnvHostOperationSystemType.ios;
        case 'android':
          return MPEnvHostOperationSystemType.android;
      }
    } else if (envHost() == MPEnvHostType.playboxProgram) {
      final channel = MethodChannel('playbox/env');
      final platform = await channel.invokeMethod('osType');
      switch (platform) {
        case 'windows':
          return MPEnvHostOperationSystemType.windows;
        case 'mac':
          return MPEnvHostOperationSystemType.macos;
        case 'ios':
          return MPEnvHostOperationSystemType.ios;
        case 'android':
          return MPEnvHostOperationSystemType.android;
      }
    }
    return MPEnvHostOperationSystemType.unknown;
  }

  static Future<bool> isWechatMiniProgramOnPC() async {
    if (envHost() != MPEnvHostType.wechatMiniProgram) return false;
    try {
      final value = await mpjs.context['wx'].callMethod('getSystemInfoSync');
      final platform = await value.getPropertyValue('platform');
      return platform == 'mac' || platform == 'windows';
    } catch (e) {
      return false;
    }
  }

  static Future<String> envUserAgent() async {
    return await mpjs.context['navigator'].getPropertyValue('userAgent');
  }
}
