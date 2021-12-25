import { ComponentFactory } from "../components/component_factory";
import { MPPlatformView } from "../components/mpkit/platform_view";
import { MPMethodChannel } from "./mp_method_channel";

export class PluginRegister {
  static registedChannels: { [key: string]: typeof MPMethodChannel } = {};

  static registerChannel(name: string, clazz: typeof MPMethodChannel) {
    this.registedChannels[name] = clazz;
  }

  static registerPlatformView(name: string, clazz: typeof MPPlatformView) {
    ComponentFactory.components[name] = clazz;
  }
}
