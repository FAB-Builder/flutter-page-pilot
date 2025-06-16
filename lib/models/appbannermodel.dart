class AppBannerResponse {
  List<AppBanner>? rows;
  int? count;

  AppBannerResponse({this.rows, this.count});

  factory AppBannerResponse.fromJson(Map<String, dynamic> json) {
    return AppBannerResponse(
      rows:
          List<AppBanner>.from(json['rows'].map((x) => AppBanner.fromJson(x))),
      count: json['count'],
    );
  }
}

class AppBanner {
  String? id;
  bool? isActive;
  String? identifier;
  int? sequence;
  BannerContent? content;
  String? buttonTextColor;
  String? buttonColor;
  String? buttonText;
  String? type;
  String? link;

  AppBanner({
    this.buttonTextColor,
    this.buttonColor,
    this.buttonText,
    this.type,
    this.id,
    this.isActive,
    this.identifier,
    this.sequence,
    this.content,
    this.link,
  });

  factory AppBanner.fromJson(Map<String, dynamic> json) {
    return AppBanner(
      id: json['_id'],
      isActive: json['isActive'],
      identifier: json['identifier'],
      sequence: json['sequence'],
      content: BannerContent.fromJson(json['content']),
      buttonTextColor: json['buttonTextColor'],
      buttonColor: json['buttonColor'],
      buttonText: json['buttonText'],
      type: json['type'],
      link: json['link'],
    );
  }
}

class BannerContent {
  String? title;
  List<BannerImage>? image;
  List<BannerVideo>? video;
  String? description;

  BannerContent({
    this.title,
    this.image,
    this.video,
    this.description,
  });

  factory BannerContent.fromJson(Map<String, dynamic> json) {
    return BannerContent(
      description: json['content'] ?? "",
      title: json['title'] ?? '',
      image: List<BannerImage>.from(
          (json['image'] ?? []).map((x) => BannerImage.fromJson(x))),
      video: List<BannerVideo>.from(
          (json['video'] ?? []).map((x) => BannerVideo.fromJson(x))),
    );
  }
}

class BannerImage {
  String? publicUrl;
  String? name;

  BannerImage({
    this.publicUrl,
    this.name,
  });

  factory BannerImage.fromJson(Map<String, dynamic> json) {
    return BannerImage(
      publicUrl: json['publicUrl'],
      name: json['name'],
    );
  }
}

class BannerVideo {
  String? publicUrl;
  String? name;

  BannerVideo({
    this.publicUrl,
    this.name,
  });

  factory BannerVideo.fromJson(Map<String, dynamic> json) {
    return BannerVideo(
      publicUrl: json['publicUrl'],
      name: json['name'],
    );
  }
}
