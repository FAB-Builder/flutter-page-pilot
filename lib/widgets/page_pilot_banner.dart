import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pagepilot/models/appbannermodel.dart';
import 'package:pip_view/pip_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class PagePilotBanner extends StatefulWidget {
  final bool autoplay;
  final double itemWidth, itemHeight;
  final double radius;
  final int duration;
  final bool indicator;
  final Color? backgroundcolor;
  final TextStyle? descriptionstyle;
  final TextStyle? titlestyle;
  final bool? pipon;
  final Color? titlebackground;
  final Color? descriptionbackground;
  final bool? owncontroller;
  final PageController? pagecontroller;
  int? currentpage;
  final ValueChanged<int>? onPageChanged;
  static bool showpip = false;
  final ValueChanged<int>? showpipfunction;

  PagePilotBanner({
    super.key,
    this.descriptionstyle,
    this.onPageChanged,
    this.currentpage,
    this.showpipfunction,
    this.pagecontroller,
    this.owncontroller = false,
    this.titlestyle,
    this.descriptionbackground,
    this.titlebackground,
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
List<String> _fetchedcontent = [];
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
        final bannerResponse = AppBannerResponse.fromJson(jsonBody);

        setState(() {
          // _mediaUrls = bannerResponse.rows.map((item) {
          //   if (item.content.video.isNotEmpty) {
          //     return item.content.video.first.publicUrl;
          //   } else if (item.content.image.isNotEmpty) {
          //     return item.content.image.first.publicUrl;
          //   }
          //   return ''; // Fallback
          // }).toList();
          _mediaUrls = bannerResponse.rows
              .map((item) {
                if (item.content.video.isNotEmpty) {
                  return item.content.video.first.publicUrl;
                } else if (item.content.image.isNotEmpty) {
                  return item.content.image.first.publicUrl;
                }
                return null;
              })
              .whereType<String>()
              .toList(); // filters out nulls

          _fetchedTitles = bannerResponse.rows
              .map((item) => item.content.title ?? "")
              .toList();

          _fetchedcontent = bannerResponse.rows
              .map((item) => item.content.description ?? "")
              .toList();

          _isLoading = false;
        });
        return bannerResponse;
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

  late WebViewController controller;
  void adjustWebviewZoom({int scale = 4}) {
    controller!.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (String url) async {
//document.body.style.zoom = 5; NOT SUPPORTED
        await controller!.runJavaScript("""
              document.body.style.transform = "scale(${scale.toString()})";
              document.body.style.transformOrigin = "0 0";
            """);
      },
    ));
  }

  void setWebViewTextStyle(TextStyle? style) {
    if (style == null) return;
    final color = style.color != null
        ? '#${style.color!.value.toRadixString(16).substring(2)}'
        : null;
    final fontSize = style.fontSize != null ? '${style.fontSize}px' : null;
    final fontWeight =
        style.fontWeight != null ? '${style.fontWeight!.index * 100}' : null;
    final fontFamily = style.fontFamily ?? null;

    final css = '''
    ${color != null ? 'color: $color;' : ''}
    ${fontSize != null ? 'font-size: $fontSize;' : ''}
    ${fontWeight != null ? 'font-weight: $fontWeight;' : ''}
    ${fontFamily != null ? 'font-family: $fontFamily;' : ''}
  ''';

    controller.runJavaScript("""
    document.body.style.cssText += `$css`;
    document.documentElement.style.cssText += `$css`;
  """);
  }

  void setWebViewBackgroundColor(Color? color) {
    if (color == null) return;
    final hexColor = '#${color.value.toRadixString(16).substring(2)}';
    controller.runJavaScript("""
    document.body.style.background = '$hexColor';
    document.documentElement.style.background = '$hexColor';
  """);
  }

  @override
  void initState() {
    super.initState();

    fetchAppBanners().then((_) {
      if (widget.autoplay && widget.pipon == false) _startAutoPlay();
      _initializeVideoControllers();
    });
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            var x = await controller!.runJavaScriptReturningResult(
                "document.documentElement.scrollHeight");
            double? y = double.tryParse(x.toString());
            debugPrint('parse : $y');
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  void _initializeVideoControllers() {
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
      setState(() {}); // update _currentPage for texts
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Media Stack with PageView and Indicator
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: height.toDouble(),
                    width: width.toDouble(),
                    child: PageView.builder(
                      
                      physics: widget.pipon!
                          ? NeverScrollableScrollPhysics()
                          : BouncingScrollPhysics(),
                      controller: widget.owncontroller == true
                          ? widget.pagecontroller ?? pageController
                          : pageController,
                      itemCount: _mediaUrls.length,
                      // onPageChanged: (page) {
                      //   setState(() {
                      //     _currentPage = page;
                      //     widget.currentpage=page;
                      //     print("object");
                      //     print(widget.currentpage);
                      //   });
                      //   widget.onPageChanged!(page);
                      // },
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                          // widget.currentpage = page;
                          // print("object");
                          print(widget.currentpage);
                        });
                        if (widget.onPageChanged != null) {
                          widget.onPageChanged!(page);
                        }
                      },
                      itemBuilder: (context, index) {
                        final isCurrentVideo = isVideo(_mediaUrls[index]);
                        final videoController = _videoControllers[index];
                        // controller.loadHtmlString(_fetchedcontent[index]);
                        //     adjustWebviewZoom(scale: 4 ?? 4);
                        //     setWebViewBackgroundColor(widget.descriptionbackground);
                        //     setWebViewTextStyle(widget.descriptionstyle);

                        return Padding(
                          padding:EdgeInsets.symmetric(horizontal: widget.pipon!
                                                  ? 0: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(widget.radius),
                              color: widget.backgroundcolor ??
                                  Colors.grey.shade300,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ClipRRect(
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
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        videoController
                                                                .value.isPlaying
                                                            ? Icons.pause
                                                            : Icons.play_arrow,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          videoController.value
                                                                  .isPlaying
                                                              ? videoController
                                                                  .pause()
                                                              : videoController
                                                                  .play();
                                                        });
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        videoController.value
                                                                    .volume ==
                                                                1
                                                            ? Icons.volume_up
                                                            : Icons
                                                                .volume_off_outlined,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          final currentVolume =
                                                              videoController
                                                                  .value.volume;
                                                          videoController
                                                              .setVolume(
                                                                  currentVolume ==
                                                                          1
                                                                      ? 0
                                                                      : 1);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              widget.pipon!
                                                  ? SizedBox.shrink()
                                                  : Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              PagePilotBanner
                                                                      .showpip =
                                                                  !PagePilotBanner
                                                                      .showpip;
                                                             
                                                              if (widget
                                                                      .showpipfunction !=
                                                                  null) {
                                                                widget
                                                                    .showpipfunction!(index);
                                                              }
                                                              
                                                            });
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              color: Colors
                                                                  .black26,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Text(
                                                              "Showpip",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        )
                                      : const Center(
                                          child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                  : Image.network(
                                      _mediaUrls[index],
                                      fit: BoxFit.fill,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                                  child: Icon(
                                        Icons.broken_image,
                                        size: 40,
                                      )),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (widget.indicator &&
                      !_isLoading &&
                      _fetchedTitles.isNotEmpty)
                    widget.pipon!
                        ? SizedBox.shrink()
                        : Positioned(
                            bottom: 6,
                            child: SmoothPageIndicator(
                              controller: pageController,
                              count: _fetchedTitles.length,
                              effect:
                                  const SwapEffect(dotHeight: 6, dotWidth: 6),
                            ),
                          ),
                ],
              ),
            ),

            // Title below media
            if (_fetchedTitles.length > _currentPage &&
                _fetchedTitles[_currentPage].isNotEmpty)
              widget.pipon!
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        color: widget.titlebackground,
                        child: Text(
                          _fetchedTitles[_currentPage],
                          textAlign: TextAlign.center,
                          style: widget.titlestyle ??
                              TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black),
                        ),
                      ),
                    ),

            // Description below title

            if (_fetchedcontent.length > _currentPage &&
                _fetchedcontent[_currentPage].isNotEmpty)
              widget.pipon!
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6),
                      child: Container(
                        color: widget.descriptionbackground,
                        height: 100,
                        width: widget.itemWidth,
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(maxHeight: 100, maxWidth: 50),
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: Text(
                                _fetchedcontent[_currentPage]
                                    .replaceAll(RegExp(r'<[^>]*>'), ''),
                                style: widget.descriptionstyle,
                                textAlign: TextAlign.center,
                              ),
                              // child: WebViewWidget(
                              //   controller:controller,
                              // )
                            ),
                          ),
                        ),
                      ),
                    )
          ],
        ),
      );
    });
  }
}
