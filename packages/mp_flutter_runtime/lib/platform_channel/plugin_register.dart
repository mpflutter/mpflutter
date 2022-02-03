part of '../mp_flutter_runtime.dart';

typedef MPPluginChannelBuilder = dynamic Function();
typedef MPPlatformViewBuilder = MPPlatformView Function(
  Key? key,
  Map? data,
  Map? parentData,
  dynamic componentFactory,
);

class MPPluginRegister {
  static final registedChannels = <String, MPPluginChannelBuilder>{};
  static final registedViews = <String, MPPlatformViewBuilder>{};

  static void registerChannel(
    String name,
    MPPluginChannelBuilder channelBuilder,
  ) {
    registedChannels[name] = channelBuilder;
  }

  static void registerPlatformView(String name, MPPlatformViewBuilder builder) {
    registedViews[name] = builder;
  }
}
