import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

/// 请参考文档 https://developers.weixin.qq.com/miniprogram/dev/component/button.html
class WechatMiniProgramButton extends MPMiniProgramView {
  WechatMiniProgramButton({
    required Widget child,
    String? openType,
    String? appParameter,
    String? sessionFrom,
    String? sendMessageTitle,
    String? sendMessagePath,
    String? sendMessageImg,
    bool? showMessageCard,
    Function(Map?)? onGetUserInfo,
    Function(Map?)? onContact,
    Function(Map?)? onGetPhoneNumber,
    Function(Map?)? onError,
    Function(Map?)? onOpenSetting,
    Function(Map?)? onLaunchApp,
  }) : super(
          tag: 'button',
          style: {
            'backgroundColor': 'unset',
            'fontWeight': 'unset',
          },
          attributes: {
            'open-type': openType,
            'app-parameter': appParameter,
            'session-from': sessionFrom,
            'send-message-title': sendMessageTitle,
            'send-message-path': sendMessagePath,
            'send-message-img': sendMessageImg,
            'show-message-card': showMessageCard,
          },
          eventListeners: (() {
            final eventListeners = <MPMiniProgramEvent>[];
            if (onGetUserInfo != null) {
              eventListeners.add(MPMiniProgramEvent(
                  event: 'getuserinfo', callback: onGetUserInfo));
            }
            if (onContact != null) {
              eventListeners.add(
                  MPMiniProgramEvent(event: 'contact', callback: onContact));
            }
            if (onGetPhoneNumber != null) {
              eventListeners.add(MPMiniProgramEvent(
                  event: 'getphonenumber', callback: onGetPhoneNumber));
            }
            if (onError != null) {
              eventListeners
                  .add(MPMiniProgramEvent(event: 'error', callback: onError));
            }
            if (onOpenSetting != null) {
              eventListeners.add(MPMiniProgramEvent(
                  event: 'opensetting', callback: onOpenSetting));
            }
            if (onLaunchApp != null) {
              eventListeners.add(MPMiniProgramEvent(
                  event: 'launchapp', callback: onLaunchApp));
            }
            return eventListeners;
          })(),
          child: child,
        );
}
