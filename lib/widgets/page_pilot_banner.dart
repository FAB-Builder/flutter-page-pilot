import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:video_player/video_player.dart';

// Change the PagePilotBannerItem class and .fromJson() function definition to accomodate for more attributes and flexibility
class PagePilotBannerItem {
  final String mediaUrl;
  final int sequence;
  final String identifier;
  final String buttonText;
  final Color buttonColor;
  final Color buttonTextColor;
  final String link;
  final String type;

  PagePilotBannerItem({
    required this.mediaUrl,
    required this.identifier,
    required this.buttonText,
    required this.sequence,
    this.buttonColor = Colors.blue,
    this.buttonTextColor = Colors.white,
    required this.link,
    required this.type,
  });

  factory PagePilotBannerItem.fromJson(Map<String, dynamic> json) {
    return PagePilotBannerItem(
      mediaUrl: json['content']['image'][0]['publicUrl'] as String,
      identifier: json['identifier'] as String,
      buttonText: json['buttonText'] as String? ?? '',
      buttonColor: json['buttonColor'] != null ? Color(int.parse(json['buttonColor'].substring(1), radix: 16) + 0xFF000000) : Colors.blue,
      buttonTextColor: json['buttonTextColor'] != null ? Color(int.parse(json['buttonTextColor'].substring(1), radix: 16) + 0xFF000000) : Colors.white,
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
    _initVideoControllers();
  }

  void _initVideoControllers() {
    _videoControllers = List.generate(widget.items.length, (index) {
      final url = widget.items[index].mediaUrl;
      if (_isVideo(url)) {
        final controller = VideoPlayerController.networkUrl(Uri.parse(url))
          ..setLooping(true);

        controller.initialize().then((_) {
          if (mounted) {
            setState(() {});
            controller.play();
          }
        });

        return controller;
      }
      return null;
    });
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  bool _isVideo(String url) => url.toLowerCase().endsWith('.mp4');

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

    return SizedBox(
      height: 300,
      child: Swiper(
        autoplay: widget.items.length == 1 ? false : (widget.autoplay && !_autoplayPaused),
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
                children: [
                  Positioned.fill(
                    child: _isVideo(item.mediaUrl)
                        ? controller != null && controller.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: VideoPlayer(controller),
                              )
                            : const Center(child: CircularProgressIndicator())
                        : Image.network(
                            item.mediaUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.identifier,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.buttonColor,
                            foregroundColor: item.buttonTextColor,
                          ),
                          onPressed: () {
                            // You can implement navigation to `item.link` here.
                            debugPrint('Clicked: ${item.link}');
                          },
                          child: Text(item.buttonText),
                        )
                      ],
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
