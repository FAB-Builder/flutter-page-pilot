class Config {
  final String applicationId;
  final String clientId;
  final String clientSecret;
  String version;

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
    this.version = "",
  });

  factory Config.fromJson(Map<String, String> json) {
    Config config = Config(
      applicationId: json['applicationId'] ?? "",
      clientId: json['clientId'] ?? "",
      clientSecret: json['clientSecret'] ?? "",
    );
    if (json["category"] != null) {
      config.category = json["category"];
    }
    return config;
  }
}
