import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pagepilot/models/appbannermodel.dart';
import 'package:pip_view/pip_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class PagePilotBanner extends StatefulWidget {
  final bool autoplay;
  final double itemWidth, itemHeight;
  final double radius;
  final int duration;
  final bool indicator;
  final Color? backgroundcolor;
  final bool? pipon;

  const PagePilotBanner({
    super.key,
    this.duration = 500,
    this.pipon = false,
    this.indicator = true,
    this.autoplay = true,
    this.itemWidth = 350,
    this.radius = 0,
    this.itemHeight = 150,
    this.backgroundcolor,
  });

  @override
  State<PagePilotBanner> createState() => _PagePilotBannerState();
}

String appid = "68249417461de050210452b2";

List<String> _fetchedTitles = [];
List<String> _mediaUrls = [];
bool _isLoading = true;

class _PagePilotBannerState extends State<PagePilotBanner> {
  Future<AppBannerResponse?> fetchAppBanners() async {
    final url = Uri.parse(
      "https://pagepilot.fabbuilder.com/api/tenant/64d2b934c6cfdc96aa3734c5/client/app-banners?filter[isActive]=true",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        print(jsonBody);
        final bannerResponse = AppBannerResponse.fromJson(jsonBody);

        setState(() {

            _mediaUrls = bannerResponse.rows.map((item) {
    if (item.content.video.isNotEmpty) {
      return item.content.video.first.publicUrl;
    } else if (item.content.image.isNotEmpty) {
      return item.content.image.first.publicUrl;
    }
    return ''; // Fallback
  }).toList();
   
          _fetchedTitles = bannerResponse.rows
              .map((item) => item.content.title ?? "")
              .toList();
          print("Required data,${_fetchedTitles}");
          print(_mediaUrls);
       
          _isLoading = false;
        });
        return AppBannerResponse.fromJson(jsonBody);
      } else {
        print('Failed to load banners. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching banners: $e');
    }

    return null;
  }

  final PageController pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};

  bool isVideo(String filePath) {
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'];
    final extension = filePath.split('.').last.toLowerCase();
    return videoExtensions.contains(extension);
  }

  @override
  void initState() {
    super.initState();
   
    if (widget.autoplay) _startAutoPlay();

    for (int i = 0; i < _mediaUrls.length; i++) {
      if (isVideo(_mediaUrls[i])) {
        final controller =
            VideoPlayerController.networkUrl(Uri.parse(_mediaUrls[i]));
        controller.setLooping(true);
        controller.initialize().then((_) {
          if (mounted) {
            setState(() {});
            controller.play();
          }
        });
        _videoControllers[i] = controller;
      }
    }
    fetchAppBanners().then((_) {
    if (widget.autoplay && widget.pipon == false) _startAutoPlay();
    _initializeVideoControllers();
  });
  }
void _initializeVideoControllers() {
  for (int i = 0; i < _mediaUrls.length; i++) {
    if (isVideo(_mediaUrls[i])) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(_mediaUrls[i]));
      controller.setLooping(true);
      controller.initialize().then((_) {
        if (mounted) {
          setState(() {});
          controller.play();
        }
      });
      _videoControllers[i] = controller;
    }
  }
}

  @override
  void didUpdateWidget(covariant PagePilotBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoplay != oldWidget.autoplay) {
      widget.autoplay ? _startAutoPlay() : _stopAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _mediaUrls.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: widget.duration),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = widget.itemWidth.clamp(0, constraints.maxWidth);
      final height = widget.itemHeight.clamp(0, constraints.maxHeight);

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: height.toDouble(),
          maxWidth: width.toDouble(),
        ),
        child: PIPView(
          builder: (context, pip) {
            return Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: _mediaUrls.length,
                  onPageChanged: (page) => _currentPage = page,
                  itemBuilder: (context, index) {
                    final isCurrentVideo = isVideo(_mediaUrls[index]);
                    final videoController = _videoControllers[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.radius),
                          color: widget.backgroundcolor ?? Colors.black,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(widget.radius),
                              child: isCurrentVideo && videoController != null
                                  ? videoController.value.isInitialized
                                      ? AspectRatio(
                                          aspectRatio:
                                              videoController.value.aspectRatio,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              VideoPlayer(videoController),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: IconButton(
                                                  icon: Icon(
                                                    videoController
                                                            .value.isPlaying
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 36,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      videoController
                                                              .value.isPlaying
                                                          ? videoController
                                                              .pause()
                                                          : videoController
                                                              .play();
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const Center(
                                          child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                  : Image.network(
                                      _mediaUrls[index],
                                      fit: BoxFit.fill,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 40)),
                                    ),
                            ),
                            if (_fetchedTitles.length > index &&
                                _fetchedTitles[index].isNotEmpty)
                              Positioned(
                                  bottom: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 18),
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: 300, maxHeight: 100),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(
                                                widget.radius),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SingleChildScrollView(
                                              child: Text(
                                                softWrap: true,
                                                textAlign: TextAlign.center,
                                                _fetchedTitles.length > index
                                                    ? _fetchedTitles[index]
                                                    : "",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                /// Page indicator
                if (widget.indicator &&
                    !_isLoading &&
                    _fetchedTitles.isNotEmpty)
                  Positioned(
                    bottom: 6,
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: _fetchedTitles.length ?? 0,
                      effect: const SwapEffect(dotHeight: 6, dotWidth: 6),
                    ),
                  ),

                /// PIP button
              widget.pipon!?const SizedBox(): Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: pip
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.fullscreen_exit_rounded,
                                color: Colors.white),
                            onPressed: () {

                              setState(() {
                                widget.pipon!=!widget.pipon!;
                              });
                              //for below screen
                              PIPView.of(context)?.presentBelow(
                                  PagePilotBanner(pipon: true,
                                  autoplay: widget.autoplay,
                                  backgroundcolor: widget.backgroundcolor,
                                  itemHeight: widget.itemHeight,
                                  itemWidth: widget.itemWidth,
                                  radius: widget.radius,
                                  indicator: widget.indicator,

                                  ) ?? const SizedBox());
                            },
                          ),
                  ),
                )
              ],
            );
          },
        ),
      );
    });
  }
}
