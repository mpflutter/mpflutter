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
}
