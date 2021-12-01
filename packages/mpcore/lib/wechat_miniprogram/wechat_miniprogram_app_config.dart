class WechatMiniProgramAppConfig {
  Map<String, WechatMiniProgramPageConfig> pages = {};

  Map toJson() {
    return {
      'pages': pages,
    }..removeWhere((key, value) => value == null);
  }
}

class WechatMiniProgramPageConfig {
  final String? navigationBarBackgroundColor;
  final String? navigationBarTextStyle;
  final String? navigationBarTitleText;
  final String? navigationStyle;
  final String? backgroundColor;
  final String? backgroundTextStyle;
  final String? backgroundColorTop;
  final String? backgroundColorBottom;
  final bool? enablePullDownRefresh;
  final int? onReachBottomDistance;
  final String? pageOrientation;
  final bool? disableScroll;
  final String? initialRenderingCache;

  WechatMiniProgramPageConfig({
    this.navigationBarBackgroundColor,
    this.navigationBarTextStyle,
    this.navigationBarTitleText,
    this.navigationStyle,
    this.backgroundColor,
    this.backgroundTextStyle,
    this.backgroundColorTop,
    this.backgroundColorBottom,
    this.enablePullDownRefresh,
    this.onReachBottomDistance,
    this.pageOrientation,
    this.disableScroll,
    this.initialRenderingCache,
  });

  Map toJson() {
    return {
      'navigationBarBackgroundColor': navigationBarBackgroundColor,
      'navigationBarTextStyle': navigationBarTextStyle,
      'navigationBarTitleText': navigationBarTitleText,
      'navigationStyle': navigationStyle,
      'backgroundColor': backgroundColor,
      'backgroundTextStyle': backgroundTextStyle,
      'backgroundColorTop': backgroundColorTop,
      'backgroundColorBottom': backgroundColorBottom,
      'enablePullDownRefresh': enablePullDownRefresh,
      'onReachBottomDistance': onReachBottomDistance,
      'pageOrientation': pageOrientation,
      'disableScroll': disableScroll,
      'initialRenderingCache': initialRenderingCache,
    }..removeWhere((key, value) => value == null);
  }
}
