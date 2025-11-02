// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:flutter/material.dart';
import 'package:pagepilot/models/config_model.dart';

import 'pagepilot_platform_interface.dart';

class Pagepilot {
  Future<String?> getPlatformVersion() {
    return PagepilotPlatform.instance.getPlatformVersion();
  }

  Future<void> init(Config config) async {
    return PagepilotPlatform.instance.init(config);
  }

  void setUserIdentifier(
      {required String userId,
      required String tenantId,
      String? language = "en"}) {
    return PagepilotPlatform.instance.setUserIdentifier(
        userId: userId, tenantId: tenantId, language: language);
  }

  Future<void> show({
    required BuildContext context,
    required String screen,
    Config? config,
    String? type,
    bool showNextAndPreviousButtons = false,
  }) async {
    return PagepilotPlatform.instance.show(
      context: context,
      screen: screen,
      type: type,
      showNextAndPreviousButtons: showNextAndPreviousButtons,
    );
  }

  Future<void> resetAllTour(userId) async {
    return PagepilotPlatform.instance.resetAllTour(userId);
  }

  Future<void> resetTourById(id, userId) async {
    return PagepilotPlatform.instance.resetTourById(id, userId);
  }
}
