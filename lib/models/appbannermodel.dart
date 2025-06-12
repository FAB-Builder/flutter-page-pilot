class AppBannerResponse {
  final List<AppBanner> rows;
  final int count;

  AppBannerResponse({required this.rows, required this.count});

  factory AppBannerResponse.fromJson(Map<String, dynamic> json) {
    return AppBannerResponse(
      rows: List<AppBanner>.from(json['rows'].map((x) => AppBanner.fromJson(x))),
      count: json['count'],
    );
  }
}

class AppBanner {
  final String id;
  final bool isActive;
  final String identifier;
  final int sequence;
  final BannerContent content;

  AppBanner({
    required this.id,
    required this.isActive,
    required this.identifier,
    required this.sequence,
    required this.content,
  });

  factory AppBanner.fromJson(Map<String, dynamic> json) {
    return AppBanner(
      id: json['_id'],
      isActive: json['isActive'],
      identifier: json['identifier'],
      sequence: json['sequence'],
      content: BannerContent.fromJson(json['content']),
    );
  }
}

class BannerContent {
  final String title;
  final List<BannerImage> image;
  final List<BannerVideo> video;
  final String description;

  BannerContent({
    required this.title,
    required this.image,
    required this.video,
    required this.description,
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
  final String publicUrl;
  final String name;

  BannerImage({
    required this.publicUrl,
    required this.name,
  });

  factory BannerImage.fromJson(Map<String, dynamic> json) {
    return BannerImage(
      publicUrl: json['publicUrl'],
      name: json['name'],
    );
  }
}

class BannerVideo {
  final String publicUrl;
  final String name;

  BannerVideo({
    required this.publicUrl,
    required this.name,
  });

  factory BannerVideo.fromJson(Map<String, dynamic> json) {
    return BannerVideo(
      publicUrl: json['publicUrl'],
      name: json['name'],
    );
  }
}
