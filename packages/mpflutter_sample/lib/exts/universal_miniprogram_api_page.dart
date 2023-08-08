import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';
import 'package:mpcore/wechat_miniprogram/wechat_miniprogram_button.dart';
import 'package:universal_miniprogram_api/universal_miniprogram_api.dart';

class MiniProgramApiPage extends StatelessWidget {
  Widget _renderBlock(Widget child) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          child: child,
        ),
      ),
    );
  }

  Widget _renderHeader(String title, dynamic icon) {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            MPIcon(icon, color: Colors.grey),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _renderItem(
    String title, {
    BuildContext? context,
    Function? execBlock,
  }) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: 1.0,
          color: Colors.black.withOpacity(0.05),
        ),
        GestureDetector(
          onTap: () {
            if (execBlock != null) {
              execBlock();
            }
          },
          child: Container(
            height: 48,
            padding: EdgeInsets.only(left: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderWidgetItem(Widget widget) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: 1.0,
          color: Colors.black.withOpacity(0.05),
        ),
        widget,
      ],
    );
  }

  void alertResult(String value) {
    MPWebDialogs.alert(message: value);
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: '微信小程序 API',
      onWechatMiniProgramShareAppMessage: (request) async {
        return MPWechatMiniProgramShareInfo(title: '微信小程序 API');
      },
      onWechatMiniProgramShareTimeline: () {
        return MPWechatMiniProgramShareTimeline(
          title: "微信小程序 API Timeline",
          imageUrl:
              'https://www-jsdelivr-com.onrender.com/img/landing/built-for-production-icon@2x.png',
        );
      },
      onWechatMiniProgramAddToFavorites: () {
        return MPWechatMiniProgramAddToFavorites(
          title: '微信小程序 API Fav',
          imageUrl:
              'https://www-jsdelivr-com.onrender.com/img/landing/built-for-production-icon@2x.png',
        );
      },
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 22),
            child: Center(
              child: MPIcon(
                MaterialIcons.widgets,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 16, top: 12, right: 16),
            child: Text(
              '以下将展示 MPFlutter 调用微信小程序 API 能力，关于 API 的使用说明，请参考微信开放平台文档。',
              style: TextStyle(
                  fontSize: 14, color: Colors.black.withOpacity(0.60)),
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('基础', MaterialIcons.layers_outlined),
                _renderItem('canIUse(Image.src)', context: context,
                    execBlock: () async {
                  final value =
                      await UniversalMiniProgramApi.uni.canIUse('Image.src');
                  alertResult('result = ' + value.toString());
                }),
                _renderItem('getSystemInfoSync', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  final result = await wx.getSystemInfo();
                  alertResult('You device brand = ${await result.brand}.');
                }),
                _renderItem('getLaunchOptionsSync', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  final result = await wx.getEnterOptionsSync();
                  alertResult('Enter path = ${await result.path}.');
                }),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('跳转', MaterialIcons.layers_outlined),
                _renderItem('navigateToMiniProgram', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  final result = await wx.navigateToMiniProgram(
                    NavigateToMiniProgramOption()
                      ..setValues(appId: "wx82d43fee89cdc7df"),
                  );
                  print(await result.errMsg);
                }),
                _renderItem('exitMiniProgram', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.exitMiniProgram();
                }),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('网络', MaterialIcons.image),
                _renderItem('downloadFile', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  await wx.downloadFile(
                    DownloadFileOption()
                      ..setValues(
                          url:
                              'https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/PCQQ2021.exe',
                          success: (res) async {
                            print(await res.tempFilePath);
                          }),
                  );
                }),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('图片', MaterialIcons.image),
                _renderItem('chooseImage', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.chooseImage(ChooseImageOption()
                    ..setValues(
                      sizeType: ['compressed'],
                      sourceType: ['album'],
                      success: (res) async {
                        final x = await res.tempFiles;
                        if (x.isNotEmpty) {
                          final y = await x[0].path;
                          final z = await x[0].size;
                          print(y);
                          print(z);
                        }
                      },
                    ));
                }),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('位置', MaterialIcons.layers_outlined),
                _renderItem('openLocation', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.openLocation(OpenLocationOption()
                    ..setValues(
                      latitude: 23.105838,
                      longitude: 113.33104,
                    ));
                }),
                _renderItem('getLocation', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.getLocation(GetLocationOption()
                    ..setValues(success: (result) async {
                      alertResult('lat = ' +
                          (await result.latitude).toString() +
                          ', lon =' +
                          (await result.longitude).toString());
                    }));
                }),
                _renderItem('choosePoi', context: context, execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.choosePoi(ChoosePoiOption()
                    ..setValues(success: (result) async {
                      alertResult('name = ' + (await result.name));
                    }));
                }),
                _renderItem('chooseLocation', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.chooseLocation(ChooseLocationOption()
                    ..setValues(success: (result) async {
                      alertResult('name = ' + (await result.name));
                    }));
                }),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('开放接口', MaterialIcons.layers_outlined),
                _renderItem('login', context: context, execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.login(LoginOption()
                    ..setValues(success: (result) async {
                      alertResult('code = ' + (await result.code));
                    }));
                }),
                _renderItem('getAccountInfoSync', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  final result = await wx.getAccountInfoSync();
                  alertResult(
                      'appId = ' + await (await result.miniProgram).appId);
                }),
                _renderItem('getUserProfile', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.getUserProfile(GetUserProfileOption()
                    ..setValues(
                        desc: '获取用户信息 Test.',
                        success: (result) async {
                          alertResult('nickname = ' +
                              (await (await result.userInfo).nickName));
                        }));
                }),
                _renderItem('authorize', context: context, execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.authorize(AuthorizeOption()
                    ..setValues(scope: 'scope.userLocation'));
                }),
                _renderItem('openSetting', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.openSetting(OpenSettingOption());
                }),
                _renderItem('chooseAddress', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.chooseAddress(
                    ChooseAddressOption()
                      ..setValues(success: (result) async {
                        alertResult('cityname = ' + await result.cityName);
                      }),
                  );
                }),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('设备', MaterialIcons.layers_outlined),
                _renderItem('setClipboardData', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.setClipboardData(
                      SetClipboardDataOption()..setValues(data: 'Hello'));
                }),
                _renderItem('getClipboardData', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.getClipboardData(GetClipboardDataOption()
                    ..setValues(success: (result) async {
                      alertResult('getClipboardData = ' + await result.data);
                    }));
                }),
                _renderItem('getNetworkType', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.getNetworkType(GetNetworkTypeOption()
                    ..setValues(success: (result) async {
                      alertResult(
                          'getNetworkType = ' + await result.networkType);
                    }));
                }),
                _renderItem('setScreenBrightness', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.setScreenBrightness(
                      SetScreenBrightnessOption()..setValues(value: 1.0));
                }),
                _renderItem('setKeepScreenOn', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.setKeepScreenOn(
                      SetKeepScreenOnOption()..setValues(keepScreenOn: true));
                }),
                _renderItem('makePhoneCall', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.makePhoneCall(
                      MakePhoneCallOption()..setValues(phoneNumber: '10086'));
                }),
                _renderItem('scanCode', context: context, execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.scanCode(ScanCodeOption()
                    ..setValues(success: (result) async {
                      alertResult('code text = ' + await result.result);
                    }));
                }),
                _renderItem('vibrateShort', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.vibrateShort(
                      VibrateShortOption()..setValues(type: 'heavy'));
                }),
                _renderItem('vibrateLong', context: context,
                    execBlock: () async {
                  final wx = UniversalMiniProgramApi.uni;
                  wx.vibrateLong(VibrateLongOption());
                }),
              ],
            ),
          ),
          _renderBlock(
            Column(
              children: [
                _renderHeader('特殊组件', MaterialIcons.widgets),
                _renderWidgetItem(
                  WechatMiniProgramButton(
                    openType: 'share',
                    child: Container(
                      height: 48,
                      padding: EdgeInsets.only(left: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Show Share Dialog',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
                _renderWidgetItem(
                  WechatMiniProgramButton(
                    openType: 'getPhoneNumber',
                    onGetPhoneNumber: (value) {
                      print(value);
                    },
                    child: Container(
                      height: 48,
                      padding: EdgeInsets.only(left: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Get Phone Number',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
