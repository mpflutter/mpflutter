part of 'mpkit.dart';

const hostType = String.fromEnvironment('mpflutter.hostType', defaultValue: '');

enum MPEnvHostType {
  unknown,
  browser,
  wechatMiniProgram,
  ttMiniProgram,
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
    } else {
      return MPEnvHostType.unknown;
    }
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
