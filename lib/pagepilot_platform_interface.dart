import 'package:flutter/material.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pagepilot_method_channel.dart';

abstract class PagepilotPlatform extends PlatformInterface {
  /// Constructs a PagepilotPlatform.
  PagepilotPlatform() : super(token: _token);

  static final Object _token = Object();

  static PagepilotPlatform _instance = MethodChannelPagepilot();

  /// The default instance of [PagepilotPlatform] to use.
  ///
  /// Defaults to [MethodChannelPagepilot].
  static PagepilotPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PagepilotPlatform] when
  /// they register themselves.
  static set instance(PagepilotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> init(Config config) async {
    throw UnimplementedError('init() has not been implemented.');
  }

  void setUserIdentifier({required String userId, required String tenantId}) {
    throw UnimplementedError('setUserIdentifier() has not been implemented.');
  }

  Future<void> show({
    required BuildContext context,
    required String screen,
    Config? config,
    String? type,
  }) async {
    throw UnimplementedError('show() has not been implemented.');
  }
}
