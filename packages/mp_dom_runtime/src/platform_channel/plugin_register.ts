import { MPMethodChannel } from "./mp_method_channel";

export class PluginRegister {
  static registedChannels: { [key: string]: typeof MPMethodChannel } = {};

  static registerChannel(name: string, clazz: typeof MPMethodChannel) {
    this.registedChannels[name] = clazz;
  }
}
