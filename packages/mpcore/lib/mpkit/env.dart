part of 'mpkit.dart';

const hostType = String.fromEnvironment('mpflutter.hostType', defaultValue: '');

enum MPEnvHostType {
  unknown,
  browser,
  wechatMiniProgram,
}

class MPEnv {
  static MPEnvHostType envHost() {
    if (hostType == 'wechatMiniProgram') {
      return MPEnvHostType.wechatMiniProgram;
    } else if (hostType == 'browser') {
      return MPEnvHostType.browser;
    } else {
      return MPEnvHostType.unknown;
    }
  }
}
