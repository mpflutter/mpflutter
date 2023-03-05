import FlutterMacOS
import AppKit

public class MpFlutterRuntimePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    MPFLTJSRuntime.register(with: registrar)
    let channel = FlutterMethodChannel(name: "mp_flutter_runtime", binaryMessenger: registrar.messenger)
    let instance = MpFlutterRuntimePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("macOS")
  }
}
