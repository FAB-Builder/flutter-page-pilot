import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PagePilotBannerItem {
  final String mediaUrl;
  final int? sequence;
  final String identifier;
  final String buttonText;
  final Color buttonColor;
  final Color buttonTextColor;
  final String link;
  final String type;

  PagePilotBannerItem({
    required this.mediaUrl,
    required this.identifier,
    this.buttonText = '',
    this.sequence,
    this.buttonColor = Colors.blue,
    this.buttonTextColor = Colors.white,
    required this.link,
    required this.type,
  });

  factory PagePilotBannerItem.fromJson(Map<String, dynamic> json) {
    String mediaUrl = '';
    if (json['content']['image'] != null && json['content']['image'].isNotEmpty) {
      mediaUrl = json['content']['image'][0]['publicUrl'] as String;
    } else if (json['content']['video'] != null && json['content']['video'].isNotEmpty) {
      mediaUrl = json['content']['video'][0]['publicUrl'] as String;
    }
    return PagePilotBannerItem(
      mediaUrl: mediaUrl,
      identifier: json['identifier'] as String,
      buttonText: json['buttonText'] as String? ?? '',
      buttonColor: json['buttonColor'] != null
          ? Color(int.parse(json['buttonColor'].substring(1), radix: 16) +
              0xFF000000)
          : Colors.blue,
      buttonTextColor: json['buttonTextColor'] != null
          ? Color(int.parse(json['buttonTextColor'].substring(1), radix: 16) +
              0xFF000000)
          : Colors.white,
      link: json['link'] as String? ?? '',
      type: json['type'] as String? ?? '',
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
  List<VideoPlayerController?> _videoControllers = [];
  bool _autoplayPaused = false;

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      _initializeControllers();
    }
  }

  @override
  void didUpdateWidget(covariant PagePilotBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      for (var controller in _videoControllers) {
        controller?.dispose();
      }
      _videoControllers = [];

      if (widget.items.isNotEmpty) {
        _initializeControllers();
      }
    }
  }

  void _initializeControllers() {
    _videoControllers = List.generate(widget.items.length, (index) {
      final url = widget.items[index].mediaUrl;
      if (_isVideo(url)) {
        final controller = VideoPlayerController.networkUrl(Uri.parse(url))
          ..setLooping(true);

        controller.initialize().then((_) {
          if (mounted) setState(() {});
          controller.play();
        });

        return controller;
      }
      return null;
    });
  }

  void _disposeControllers() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    _videoControllers = [];
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
        child: Text(
          "No media to display",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    if (_videoControllers.length != widget.items.length) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: widget.itemHeight,
      child: Swiper(
        autoplay: widget.items.length == 1
            ? false
            : (widget.autoplay && !_autoplayPaused),
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
          final controller = index < _videoControllers.length
              ? _videoControllers[index]
              : null;

          return GestureDetector(
            onTap: () => widget.onTap?.call(index),
            onLongPress: () => setState(() => _autoplayPaused = true),
            onLongPressEnd: (_) => setState(() => _autoplayPaused = false),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _isVideo(item.mediaUrl)
                        ? controller != null && controller.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: VideoPlayer(controller),
                              )
                            : const Center(child: CircularProgressIndicator())
                        : _isSvg(item.mediaUrl)
                            ? SvgPicture.network(
                                item.mediaUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              )
                            : Image.network(
                                item.mediaUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                  ),
                  if (item.buttonText.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.buttonColor,
                          foregroundColor: item.buttonTextColor,
                        ),
                        onPressed: () {
                          debugPrint('Clicked: ${item.link}');
                        },
                        child: Text(item.buttonText),
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
