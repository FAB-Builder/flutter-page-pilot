import 'package:pagepilot/models/styles_model.dart';

class Config {
  dynamic credentials;
  static String userId = "ANONYMOUS";
  Map keys;
  Styles? styles;

  Config({
    required this.credentials,
    required this.keys,
    this.styles,
  });

  static setUserIdentifier(String uId) {
    userId = uId;
  }

  factory Config.fromJson(Map<String, String> json) {
    Config config = Config(
      credentials: json['keys'] as Map ?? {},
      keys: json['keys'] as Map ?? {},
    );
    userId = json['userId'] ?? "";
    if (json["credentials"] != null) {
      config.credentials = json["credentials"];
    }
    if (json["keys"] != null) {
      config.keys = json["keys"] as Map;
    }
    return config;
  }
}
