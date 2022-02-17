package com.mpflutter.mp_flutter_runtime;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** MpFlutterRuntimePlugin */
public class MpFlutterRuntimePlugin implements FlutterPlugin {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MPFLTJSRuntime mpfltjsRuntime;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mpfltjsRuntime = new MPFLTJSRuntime();
    mpfltjsRuntime.onAttachedToEngine(flutterPluginBinding);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    if (mpfltjsRuntime != null) {
      mpfltjsRuntime.onDetachedFromEngine(flutterPluginBinding);
    }
  }
}
