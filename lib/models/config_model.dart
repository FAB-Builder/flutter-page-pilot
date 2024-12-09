import 'package:pagepilot/models/styles_model.dart';

class Config {
  dynamic credentials;
  final String userId;
  Map keys;
  Styles? styles;

  Config({
    required this.credentials,
    this.userId = "ANONYMOUS",
    required this.keys,
    this.styles,
  });

  factory Config.fromJson(Map<String, String> json) {
    Config config = Config(
      credentials: json['keys'] as Map ?? {},
      userId: json['userId'] ?? "",
      keys: json['keys'] as Map ?? {},
    );
    if (json["credentials"] != null) {
      config.credentials = json["credentials"];
    }
    if (json["keys"] != null) {
      config.keys = json["keys"] as Map;
    }
    return config;
  }
}
