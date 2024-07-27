class TutorialModel {
  List<Tutorial>? tutorials;
  int? count;

  TutorialModel({
    this.tutorials,
    this.count,
  });

  factory TutorialModel.fromJson(Map<String, dynamic> json) => TutorialModel(
        tutorials: json["rows"] == null
            ? []
            : List<Tutorial>.from(
                json["rows"]!.map((x) => Tutorial.fromJson(x))),
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "rows": tutorials == null
            ? []
            : List<dynamic>.from(tutorials!.map((x) => x.toJson())),
        "count": count,
      };
}

class Tutorial {
  bool? isActive;
  String? id;
  String? selector;
  int? order;
  String? position;
  String? slug;
  String? name;
  String? device;
  Language? language;
  Content? content;
  String? tenant;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? rowId;

  Tutorial({
    this.isActive,
    this.id,
    this.selector,
    this.order,
    this.position,
    this.slug,
    this.name,
    this.device,
    this.language,
    this.content,
    this.tenant,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.rowId,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) => Tutorial(
        isActive: json["isActive"],
        id: json["_id"],
        selector: json["selector"],
        order: json["order"],
        position: json["position"],
        slug: json["slug"],
        name: json["name"],
        device: json["device"],
        language: json["language"] == null
            ? null
            : Language.fromJson(json["language"]),
        content:
            json["content"] == null ? null : Content.fromJson(json["content"]),
        tenant: json["tenant"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        rowId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "isActive": isActive,
        "_id": id,
        "selector": selector,
        "order": order,
        "position": position,
        "slug": slug,
        "name": name,
        "device": device,
        "language": language?.toJson(),
        "content": content?.toJson(),
        "tenant": tenant,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": rowId,
      };
}

class Content {
  bool? includeExpressions;
  bool? isActive;
  String? id;
  String? title;
  List<dynamic>? audio;
  List<dynamic>? animation;
  List<dynamic>? image;
  List<dynamic>? video;
  String? language;
  String? tenant;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? content;
  String? contentId;

  Content({
    this.includeExpressions,
    this.isActive,
    this.id,
    this.title,
    this.audio,
    this.animation,
    this.image,
    this.video,
    this.language,
    this.tenant,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.content,
    this.contentId,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        includeExpressions: json["includeExpressions"],
        isActive: json["isActive"],
        id: json["_id"],
        title: json["title"],
        audio: json["audio"] == null
            ? []
            : List<dynamic>.from(json["audio"]!.map((x) => x)),
        animation: json["animation"] == null
            ? []
            : List<dynamic>.from(json["animation"]!.map((x) => x)),
        image: json["image"] == null
            ? []
            : List<dynamic>.from(json["image"]!.map((x) => x)),
        video: json["video"] == null
            ? []
            : List<dynamic>.from(json["video"]!.map((x) => x)),
        language: json["language"],
        tenant: json["tenant"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        content: json["content"],
        contentId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "includeExpressions": includeExpressions,
        "isActive": isActive,
        "_id": id,
        "title": title,
        "audio": audio == null ? [] : List<dynamic>.from(audio!.map((x) => x)),
        "animation": animation == null
            ? []
            : List<dynamic>.from(animation!.map((x) => x)),
        "image": image == null ? [] : List<dynamic>.from(image!.map((x) => x)),
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "language": language,
        "tenant": tenant,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "content": content,
        "id": contentId,
      };
}

class Language {
  String? id;
  String? code;
  String? name;
  String? tenant;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? languageId;

  Language({
    this.id,
    this.code,
    this.name,
    this.tenant,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.languageId,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json["_id"],
        code: json["code"],
        name: json["name"],
        tenant: json["tenant"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        languageId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "code": code,
        "name": name,
        "tenant": tenant,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": languageId,
      };
}
