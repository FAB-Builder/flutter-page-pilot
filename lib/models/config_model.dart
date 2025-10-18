import 'package:flutter/widgets.dart';
import 'package:pagepilot/models/styles_model.dart';

class Config {
  dynamic credentials;
  static String userId = "ANONYMOUS";
  static String tenantId = "";
  Map keys;
  Styles? styles;
  ScrollController? scrollController;

  static String language = "en";

  Config({
    required this.credentials,
    required this.keys,
    this.scrollController,
    this.styles,
  });

  static setUserIdentifier(String uId,
      {required String tenantId, String? language}) {
    userId = uId;
    Config.tenantId = tenantId;
    if (language != null) {
      Config.language = language;
    }
  }

  factory Config.fromJson(Map<String, String> json) {
    Config config = Config(
      credentials: json['keys'] as Map,
      keys: json['keys'] as Map,
    );
    userId = json['userId'] ?? "";
    tenantId = json['tenantId'] ?? "";
    if (json["credentials"] != null) {
      config.credentials = json["credentials"];
    }
    if (json["keys"] != null) {
      config.keys = json["keys"] as Map;
    }
    if (json["language"] != null) {
      language = json["language"] as String;
    }
    return config;
  }
}
