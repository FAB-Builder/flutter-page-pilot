import 'package:pagepilot/models/styles_model.dart';

class Config {
  final String applicationId;
  final String clientId;
  final String clientSecret;
  String version;
  Map keys;
  Styles? styles;

  String? server;
  String? static;
  String application = "android";

  String? token = "";
  String? orderBy = "";
  int limit = 10;
  int offset = 0;
  String? category;

  Config({
    required this.applicationId,
    required this.clientId,
    required this.clientSecret,
    required this.keys,
    this.version = "",
    this.styles,
  });

  factory Config.fromJson(Map<String, String> json) {
    Config config = Config(
      applicationId: json['applicationId'] ?? "",
      clientId: json['clientId'] ?? "",
      clientSecret: json['clientSecret'] ?? "",
      keys: json['keys'] as Map ?? {},
    );
    if (json["category"] != null) {
      config.category = json["category"];
    }
    if (json["keys"] != null) {
      config.keys = json["keys"] as Map;
    }
    return config;
  }
}
