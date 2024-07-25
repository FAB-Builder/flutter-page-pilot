import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pagepilot_platform_interface.dart';

/// An implementation of [PagepilotPlatform] that uses method channels.
class MethodChannelPagepilot extends PagepilotPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pagepilot');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
