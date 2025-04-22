import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

class PagePilotBannerItem {
  final String mediaUrl;
  final String? title;
  final String? content;
  final int? sequence;
  final String identifier;
  final String? buttonText;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color backgroundColor;
  final String link;
  final String type;

  PagePilotBannerItem({
    required this.mediaUrl,
    required this.identifier,
    this.buttonText,
    this.title,
    this.content,
    this.sequence,
    Color? buttonColor,
    Color? buttonTextColor,
    Color? backgroundColor,
    required this.link,
    required this.type,
  })  : buttonColor = buttonColor ?? Colors.blue,
        buttonTextColor = buttonTextColor ?? Colors.white,
        backgroundColor = backgroundColor ?? Colors.black.withOpacity(0.5);

  factory PagePilotBannerItem.fromJson(Map<String, dynamic> json) {
    String mediaUrl = '';
    if (json['content']?['image'] != null &&
        json['content']['image'].isNotEmpty) {
      mediaUrl = json['content']['image'][0]['publicUrl'] as String;
    } else if (json['content']?['video'] != null &&
        json['content']['video'].isNotEmpty) {
      mediaUrl = json['content']['video'][0]['publicUrl'] as String;
    }
    return PagePilotBannerItem(
      mediaUrl: mediaUrl,
      title: json['content']?['title'],
      content: json['content']?['content'],
      identifier: json['identifier'],
      buttonText: json['buttonText'] ?? '',
      buttonColor: json['buttonColor'] != null
          ? Color(int.parse(json['buttonColor'].substring(1), radix: 16) +
              0xFF000000)
          : Colors.blue,
      buttonTextColor: json['buttonTextColor'] != null
          ? Color(int.parse(json['buttonTextColor'].substring(1), radix: 16) +
              0xFF000000)
          : Colors.white,
      link: json['link'] ?? '',
      type: json['type'] ?? '',
      sequence: json['sequence'],
    );
  }
}

class PagePilotBanner extends StatefulWidget {
  final List<PagePilotBannerItem> items;
  final bool autoplay;
  final double itemWidth, itemHeight;
  final double borderRadius;
  final int autoplayDelay;
  final void Function(int index)? onTap;

  const PagePilotBanner({
    super.key,
    required this.items,
    this.autoplay = true,
    this.itemWidth = 350,
    this.itemHeight = 150,
    this.borderRadius = 10,
    this.autoplayDelay = 5000,
    this.onTap,
  });

  @override
  State<PagePilotBanner> createState() => _PagePilotBannerState();
}

class _PagePilotBannerState extends State<PagePilotBanner> {
  late List<VideoPlayerController?> _videoControllers;
  bool _autoplayPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant PagePilotBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _disposeControllers();
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _videoControllers = widget.items.map((item) {
      if (_isVideo(item.mediaUrl)) {
        final controller =
            VideoPlayerController.networkUrl(Uri.parse(item.mediaUrl))
              ..setLooping(true);
        controller.initialize().then((_) {
          if (mounted) setState(() {});
          controller.play();
        });
        return controller;
      }
      return null;
    }).toList();
  }

  void _disposeControllers() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  bool _isVideo(String url) => url.toLowerCase().endsWith('.mp4');
  bool _isSvg(String url) => url.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
          child: Text("No media to display",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)));
    }

    if (_videoControllers.length != widget.items.length) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: widget.itemHeight,
      child: Swiper(
        autoplay:
            widget.items.length > 1 && widget.autoplay && !_autoplayPaused,
        autoplayDisableOnInteraction: true,
        autoplayDelay: widget.autoplayDelay,
        duration: 1000,
        itemCount: widget.items.length,
        layout: SwiperLayout.STACK,
        itemWidth: widget.itemWidth,
        axisDirection: AxisDirection.right,
        pagination: const SwiperPagination(builder: SwiperPagination.rect),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final controller = _videoControllers[index];

          return GestureDetector(
            onTap: () => widget.onTap?.call(index),
            onLongPress: () => setState(() => _autoplayPaused = true),
            onLongPressEnd: (_) => setState(() => _autoplayPaused = false),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.mediaUrl.isNotEmpty) ...[
                    _isVideo(item.mediaUrl)
                        ? (controller != null && controller.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: VideoPlayer(controller),
                              )
                            : const Center(child: CircularProgressIndicator()))
                        : _isSvg(item.mediaUrl)
                            ? SvgPicture.network(
                                item.mediaUrl,
                                fit: BoxFit.cover,
                                placeholderBuilder: (_) => const Center(
                                    child: CircularProgressIndicator()),
                                errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image)),
                              )
                            : Image.network(
                                item.mediaUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image)),
                              )
                  ] else
                    Container(color: item.backgroundColor),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.title != null && item.title!.isNotEmpty)
                          Text(
                            item.title!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (item.content != null && item.content!.isNotEmpty)
                          if (item.content?.startsWith('<') ?? false)
                            Html(
                              data: item.content,
                              style: {
                                "body": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  color: Colors.white,
                                  fontSize: FontSize.small,
                                ),
                              },
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                item.content!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                      ],
                    ),
                  ),
                  if (item.buttonText != null && item.buttonText!.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      left: 20,
                      child: GestureDetector(
                        onTap: () async {
                          final uri = Uri.tryParse(item.link);
                          if (uri != null && await canLaunchUrl(uri)) {
                            launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.buttonColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            item.buttonText!,
                            style: TextStyle(
                              color: item.buttonTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
