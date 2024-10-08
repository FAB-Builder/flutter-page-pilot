package com.fabbuilder.pagepilot;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** PagePilotPlugin */
 class PagePilotPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel


  // @Override
  // public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
  //   channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "pagepilot");
  //   channel.setMethodCallHandler(this);
  // }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pagepilot")
    channel.setMethodCallHandler(this)
  }

  // @Override
  // public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
  //   if (call.method.equals("getPlatformVersion")) {
  //     result.success("Android " + android.os.Build.VERSION.RELEASE);
  //   } else {
  //     result.notImplemented();
  //   }
  // }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  // @Override
  // public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  //   channel.setMethodCallHandler(null);
  // }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
