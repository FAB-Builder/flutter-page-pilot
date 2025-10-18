import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/services/service.dart';

import 'pagepilot_platform_interface.dart';

// ignore: non_constant_identifier_names
Config? CONFIG;

/// An implementation of [PagepilotPlatform] that uses method channels.
class MethodChannelPagepilot extends PagepilotPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pagepilot');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> init(Config config) async {
    CONFIG = config;
  }

  @override
  void setUserIdentifier(
      {required String userId,
      required String tenantId,
      String? language = "en"}) {
    Config.setUserIdentifier(userId, tenantId: tenantId, language: language);
  }

  @override
  Future<void> show({
    required BuildContext context,
    required String screen,
    Config? config,
    String? type,
  }) async {
    config ??= CONFIG!;
    doShow(context: context, config: config, screen: screen, type: type);
  }
}
