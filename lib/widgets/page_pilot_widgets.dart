import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/models/styles_model.dart';
import 'package:pagepilot/widgets/pulse_animation.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PagePilot {
  static OverlayEntry? _overlayEntry;
  static late TutorialCoachMark tutorialCoachMark;
  static double borderRadius = 20;
  static double padding = 16;
  static bool showConfetti = false;
  static late ConfettiController _confettiController;
  static bool isDarkMode = false;
  static String htmlBodyStart =
      "<!DOCTYPE html> <html lang=\"en\"> <head> <meta name=\"viewport\" content=\"width=device-width, height=device-height, initial-scale=1.0, user-scalable=no\" /> <style> html, body { background:#ffffff00;margin: 0; padding: 0; width: 100%; height: 100%; display: flex; justify-content: center; align-items: center; overflow: hidden; } img, iframe, video { max-width: 100%; max-height: 100%; object-fit: contain; } </style> </head> <body>";

  // static String htmlBodyStart =
  //     "<body style=\"margin: 0;padding: 0;width: 100vw;height: 100vh;overflow: hidden;display: flex;justify-content: center;align-items: center;\"><style>body img,body iframe,body video {max-width: 100%;max-height: 100%;object-fit: contain;}</style>";
  static String htmlBodyEnd = "</body></html>";

  // static double webViewHeight = 200;
  // static double webViewWidth = 200;
  static WebViewController? controller;
  static Styles styles = Styles(
    shadowColor: Colors.red,
    shadowOpacity: 0.5,
    textSkip: "SKIP",
    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
  );

  static void initStyles(Styles? s) {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    if (s != null) {
      styles = Styles(
        shadowColor: s.shadowColor,
        shadowOpacity: s.shadowOpacity,
        textSkip: s.textSkip,
        imageFilter: s.imageFilter,
      );
    }
    // else {
    //   styles = Styles(
    //     shadowColor: Colors.red,
    //     shadowOpacity: 0.5,
    //     textSkip: "SKIP",
    //     imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    //   );
    // }

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

  static void initTutorialCoachMark(List<TargetFocus> targets) {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: styles.shadowColor ?? Colors.red,
      textSkip: styles.textSkip ?? "SKIP",
      alignSkip: Alignment.bottomRight,
      paddingFocus: 5,
      opacityShadow: styles.shadowOpacity ?? 0.5,
      imageFilter: styles.imageFilter ?? ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
        return true;
      },
    );
  }

  static void showSnackbar(
    BuildContext context, {
    String? title,
    String? body,
    String? background,
    String? textColor,
    String? url,
    int duration = 3000,
    int? scale,
  }) {
    if (context == null) {
      print("No Overlay widget found in the current context.");
      return;
    }

    final overlay = Overlay.of(context);
    if (overlay == null) {
      print("No Overlay available in current context.");
      return;
    }

    // Prevent multiple snackbars from appearing at the same time
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 80,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: background != null
                  ? hexToColor(background)
                  : Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                body != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title != null
                              ? Text(
                                  title,
                                  style: TextStyle(
                                    color: textColor != null
                                        ? hexToColor(textColor)
                                        : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : SizedBox(),
                          body.toString().startsWith("<")
                              ? Container(
                                  height: 20,
                                  width: 340,
                                  child: WebViewWidget(
                                    controller: controller!,
                                  ),
                                )
                              : Text(
                                  body,
                                  style: TextStyle(
                                    color: textColor != null
                                        ? hexToColor(textColor)
                                        : Colors.white,
                                  ),
                                ),
                        ],
                      )
                    : Container(
                        height: 80,
                        width: 340,
                        child: WebViewWidget(
                          controller: controller!,
                        ),
                      ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    _overlayEntry?.remove();
                    _overlayEntry = null;

                    controller!.clearCache();
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlay.insert(_overlayEntry!);
    });

    // Automatically remove the snackbar after a delay
    Future.delayed(Duration(milliseconds: duration), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
      controller!.clearCache();
    });

    if (url != null) {
      controller!.loadRequest(Uri.parse(url));
    }
    if (body.toString().startsWith("<")) {
      controller!.loadHtmlString(body.toString());
      adjustWebviewZoom(scale: scale ?? 2);
    }
  }

  static void showBottomSheet(
    BuildContext context, {
    String? title,
    required String? body,
    String? background,
    String? textColor,
    String? url,
    int? scale,
    required Function() onOkPressed,
  }) {
    // var isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      // isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                top: padding,
                bottom: padding * 2,
                left: padding,
                right: padding),
            decoration: BoxDecoration(
              color: background != null
                  ? hexToColor(background)
                  : isDarkMode
                      ? Colors.black
                      : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title != null
                    ? Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              textColor != null ? hexToColor(textColor) : null,
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 16),
                body != null
                    ? body.toString().startsWith("<")
                        ? Container(
                            height: 200,
                            constraints: BoxConstraints(
                              minHeight: 200, // Minimum height
                              maxHeight: 500, // Maximum height
                            ),
                            // width: double.infinity,
                            child: WebViewWidget(controller: controller!),
                          )
                        : Text(
                            body,
                            style: TextStyle(
                              color: textColor != null
                                  ? hexToColor(textColor)
                                  : null,
                            ),
                          )
                    : Container(
                        height: 200,
                        width: 200,
                        child: WebViewWidget(controller: controller!),
                      ),
                Row(
                  children: [
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onOkPressed();
                      },
                      child: Text("OK"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );

    if (url != null) {
      controller!.loadRequest(Uri.parse(url!));
    }
    if (body.toString().startsWith("<")) {
      controller!.loadHtmlString(body.toString());
      adjustWebviewZoom(scale: scale ?? 4);
    }
  }

  static void showOkDialog(
    BuildContext context, {
    required String shape,
    String? title,
    String? body,
    String? background,
    String? textColor,
    String? url,
    int? scale,
    Function()? onOkPressed,
  }) {
    // var isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    if (showConfetti) {
      _confettiController =
          ConfettiController(duration: const Duration(seconds: 10));
      _confettiController.play();
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: background != null
                ? hexToColor(background)
                : isDarkMode
                    ? Colors.black
                    : Colors.white,
            title: title != null
                ? Text(
                    title,
                    style: TextStyle(
                      color: textColor != null ? hexToColor(textColor) : null,
                    ),
                  )
                : null,
            content: SingleChildScrollView(
              child: Stack(
                children: [
                  body != null
                      ? body.toString().startsWith("<")
                          ? Container(
                              height: 200,
                              width: 200,
                              child: WebViewWidget(controller: controller!),
                            )
                          : Text(
                              body,
                              style: TextStyle(
                                color: textColor != null
                                    ? hexToColor(textColor)
                                    : null,
                              ),
                            )
                      : Container(
                          height: 200,
                          width: 200,
                          child: WebViewWidget(controller: controller!),
                        ),
                  showConfetti
                      ? Container(
                          height: 250,
                          width: 250,
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            // don't specify a direction, blast randomly
                            shouldLoop: true,
                            // start again as soon as the animation is finished
                            colors: const [
                              Colors.green,
                              Colors.blue,
                              Colors.pink,
                              Colors.orange,
                              Colors.purple
                            ],
                            // manually specify the colors to be used
                            createParticlePath: drawStar,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: onOkPressed == null
                    ? () {
                        Navigator.pop(context);
                        if (showConfetti) {
                          _confettiController.stop();
                        }
                      }
                    : () {
                        Navigator.pop(context);
                        controller!.clearCache();
                        if (showConfetti) {
                          _confettiController.stop();
                        }
                        onOkPressed();
                      },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        });
    if (url != null) {
      controller!.loadRequest(Uri.parse(url!));
    }
    if (body.toString().startsWith("<")) {
      controller!.loadHtmlString(body.toString());
      adjustWebviewZoom(scale: scale ?? 4);
    }
  }

  static void showInfoDialog(BuildContext context,
      {required GlobalKey key,
      required String shape,
      required String title,
      required String body,
      Function()? onOkPressed}) {
    var isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        shape: shape.toString().toLowerCase() == "rect"
            ? ShapeLightFocus.RRect
            : ShapeLightFocus.Circle,
        identify: "keyDialog",
        keyTarget: key,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return AlertDialog(
                backgroundColor: isDarkTheme ? Colors.black : Colors.white,
                title: Text(
                  title,
                ),
                // backgroundColor: AppTheme.backgroundColor,
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(
                        body,
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  // TextButton(
                  //   onPressed: () => Navigator.pop(context),
                  //   child: const Text(
                  //     'Cancel',
                  //   ),
                  // ),
                  TextButton(
                    onPressed: onOkPressed == null
                        ? () {
                            tutorialCoachMark.finish();
                          }
                        : () {
                            tutorialCoachMark.finish();
                            onOkPressed();
                          },
                    child: const Text(
                      'OK',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    PagePilot.initTutorialCoachMark(targets);
    tutorialCoachMark.show(context: context);
  }

  static void showTooltip(
    BuildContext context, {
    required GlobalKey key,
    required String shape,
    String? title,
    required String body,
    String? background,
    String? textColor,
    int? scale,
  }) {
    // var isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        shape: shape.toString().toLowerCase() == "rect"
            ? ShapeLightFocus.RRect
            : ShapeLightFocus.Circle,
        identify: "keyTooltip",
        keyTarget: key,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, coachMarkController) {
              return Container(
                decoration: BoxDecoration(
                  color: background != null
                      ? hexToColor(background)
                      : isDarkMode
                          ? Colors.black
                          : Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    title != null
                        ? Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor != null
                                  ? hexToColor(textColor)
                                  : null,
                            ),
                          )
                        : SizedBox(),
                    SizedBox(height: 10),
                    body.toString().startsWith("<")
                        ? SizedBox(
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: WebViewWidget(controller: controller!),
                          )
                        : Text(
                            body,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              color: textColor != null
                                  ? hexToColor(textColor)
                                  : null,
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    PagePilot.initTutorialCoachMark(targets);
    tutorialCoachMark.show(context: context);
    if (body.toString().startsWith("<")) {
      controller!.loadHtmlString(body.toString());
      adjustWebviewZoom(scale: scale ?? 4);
    }
  }

  static void showFloatingWidget(
    BuildContext context, {
    String? title,
    String? body,
    String? background,
    String? textColor,
    String? url,
    String? position,
    int? scale,
    bool isDraggable = false,
  }) {
    // Use an OverlayEntry to display the pulse animation
    final overlay = Overlay.of(context);
    OverlayEntry? entry;
    double margin = 30;

    final screenSize = MediaQuery.of(context).size;
    Offset currentOffset = Offset(0, 0);
    switch (position.toString().toLowerCase()) {
      case "topleft":
        currentOffset = Offset(margin, margin);
        break;
      case "topcenter":
      case "top":
        currentOffset = Offset(
          (screenSize.width - margin * 6) / 2,
          margin,
        );
        break;
      case "topright":
        currentOffset = Offset(
          (screenSize.width + margin) / 2,
          margin,
        );
        break;
      case "bottomleft":
        currentOffset = Offset(
          margin,
          screenSize.height - margin * 6,
        );
        break;
      case "bottomcenter":
      case "bottom":
        currentOffset = Offset(
          (screenSize.width - margin * 6) / 2,
          screenSize.height - margin * 6,
        );
        break;
      case "bottomright":
        currentOffset = Offset(
          (screenSize.width + margin) / 2,
          screenSize.height - margin * 6,
        );
        break;
      case "center":
        currentOffset = Offset(
          (screenSize.width - margin * 6) / 2,
          (screenSize.height - margin * 5) / 2,
        ); // Center
        break;
      case "leftcenter":
      case "left":
        currentOffset =
            Offset(margin, (screenSize.height - margin * 5) / 2); // Left Center
        break;
      case "rightcenter":
      case "right":
        currentOffset = Offset(
          (screenSize.width + margin) / 2,
          (screenSize.height - margin * 5) / 2,
        ); // Right Center
        break;
    }

    entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // final screenSize = MediaQuery.of(context).size;
            // Offset currentOffset = Offset(0, 0);
            return Positioned(
              top: currentOffset.dy,
              left: currentOffset.dx,
              child: SafeArea(
                child: Material(
                  elevation: 4,
                  color: Colors.transparent,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (isDraggable) {
                        setState(() {
                          // Update position as the user drags
                          currentOffset += details.delta;
                          //entry?.markNeedsBuild();
                        });
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.40,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: background != null
                            ? hexToColor(background)
                            : isDarkMode
                                ? Colors.black
                                : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          title != null
                              ? Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor != null
                                        ? hexToColor(textColor)
                                        : null,
                                  ),
                                )
                              : SizedBox(),
                          body != null
                              ? body.toString().startsWith("<")
                                  ? Container(
                                      height: 200,
                                      width: 200,
                                      child: WebViewWidget(
                                          controller: controller!),
                                    )
                                  : Text(
                                      body,
                                      style: TextStyle(
                                        color: textColor != null
                                            ? hexToColor(textColor)
                                            : null,
                                      ),
                                    )
                              : Container(
                                  height: 200,
                                  width: 200,
                                  child: WebViewWidget(controller: controller!),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (url != null) {
      controller!.loadRequest(Uri.parse(url!));
    }
    if (body.toString().startsWith("<")) {
      controller!.loadHtmlString(htmlBodyStart + body.toString() + htmlBodyEnd);
      adjustWebviewZoom(scale: scale ?? 4);
    }

    overlay.insert(entry);
  }

  static void showBeacon(
    BuildContext context, {
    required String shape,
    required GlobalKey key,
    required String beaconPosition,
    String? title,
    required String body,
    String? background,
    String? textColor,
    required Color color,
    required Function() onBeaconClicked,
  }) {
    // Get the render box for the target widget
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    Offset beaconOffset =
        calculateBeaconPosition(beaconPosition, position, size);
    // Use an OverlayEntry to display the pulse animation
    final overlay = Overlay.of(context);
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: beaconOffset.dy, // Calculated top position
        left: beaconOffset.dx, // Calculated left position
        child: GestureDetector(
          child: PulseAnimation(
            color: color,
          ),
          onTap: () {
            entry!.remove();
            showTooltip(
              context,
              key: key,
              shape: shape,
              title: title,
              body: body,
              background: background,
              textColor: textColor,
            );
            onBeaconClicked();
          },
        ),
      ),
    );

    overlay.insert(entry);

    // Remove the overlay after a delay
    // Future.delayed(Duration(seconds: 3), () {
    //   entry.remove();
    // });
  }

  static void showTour(
    BuildContext context,
    Config config, {
    required List<dynamic> tours,
    // required Widget widget,
  }) {
    var isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    List<TargetFocus> targets = [];

    for (int i = 0; i < tours.length; i++) {
      String body = tours[i]["body"].toString();
      WebViewController webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
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
      targets.add(
        TargetFocus(
          identify: "",
          shape: tours[i]["shape"].toString().toLowerCase() == "rect"
              ? ShapeLightFocus.RRect
              : ShapeLightFocus.Circle,
          keyTarget: config.keys[tours[i]["element"].toString()],
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, TCMcontroller) {
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: tours[i]["background"] != null
                            ? hexToColor(tours[i]["background"])
                            : isDarkTheme
                                ? Colors.black
                                : Colors.white,
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      padding: EdgeInsets.all(borderRadius),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tours[i]["title"].toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: tours[i]["textColor"] != null
                                  ? hexToColor(tours[i]["textColor"])
                                  : isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                          // Text(tours[i]["description"].toString()),
                          body.startsWith("http")
                              ? Container(
                                  height: 200,
                                  width: 200,
                                  child: WebViewWidget(
                                      controller: webViewController),
                                )
                              : Text(
                                  tours[i]["body"].toString(),
                                  style: TextStyle(
                                    color: tours[i]["textColor"] != null
                                        ? hexToColor(tours[i]["textColor"])
                                        : isDarkTheme
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    previousAndNextButtons(i, tours.length - 1),
                  ],
                );
              },
            ),
          ],
        ),
      );
      if (body.startsWith("http")) {
        webViewController.loadRequest(Uri.parse(body));
      }
    }

    PagePilot.initTutorialCoachMark(targets);
    tutorialCoachMark.show(context: context);
  }

  static Offset calculateBeaconPosition(
      String position, Offset widgetPosition, Size widgetSize) {
    double val = 15; //30 should be half of raius of circle
    switch (position) {
      case "topleft":
        return widgetPosition - Offset(val, val); // Adjusted for padding
      case "topright":
        return Offset(widgetPosition.dx + widgetSize.width - val,
            widgetPosition.dy - val);
      case "bottomleft":
        return Offset(widgetPosition.dx - val,
            widgetPosition.dy + widgetSize.height - val);
      case "bottomright":
        return Offset(widgetPosition.dx + widgetSize.width - val,
            widgetPosition.dy + widgetSize.height - val);
      case "center":
        return Offset(widgetPosition.dx + widgetSize.width / 2 - val,
            widgetPosition.dy + widgetSize.height / 2 - val);
      case "topcenter":
      case "top":
        return Offset(widgetPosition.dx + widgetSize.width / 2 - val,
            widgetPosition.dy - val);
      case "bottomcenter":
      case "bottom":
        return Offset(widgetPosition.dx + widgetSize.width / 2 - val,
            widgetPosition.dy + widgetSize.height - val);
      case "leftcenter":
      case "left":
        return Offset(widgetPosition.dx - val,
            widgetPosition.dy + widgetSize.height / 2 - val);
      case "rightcenter":
      case "right":
        return Offset(widgetPosition.dx + widgetSize.width - val,
            widgetPosition.dy + widgetSize.height / 2 - val);
      default:
        return widgetPosition;
    }
  }

  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff'); // Adds 'ff' for opacity if alpha is missing
    }
    buffer.write(hexString.replaceFirst('#', '')); // Removes the # if present
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Widget previousAndNextButtons(int index, lastIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: index == 0 ? null : () => tutorialCoachMark.previous(),
          child: Text(index == 0 ? '' : 'Previous'),
        ),
        GestureDetector(
          onTap: index == lastIndex ? null : () => tutorialCoachMark.next(),
          child: Text(index == lastIndex ? '' : 'Next'),
        ),
      ],
    );
  }

  static void adjustWebviewZoom({int scale = 4}) {
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

//   static Widget AdjustedWebView(
//       WebViewController controller, String htmlString) {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         double webViewHeight = 1.0;
//         double webViewWidth = 1.0;

//         controller!.setNavigationDelegate(NavigationDelegate(
//           onPageFinished: (String url) async {
//             Object heightObj = await controller!.runJavaScriptReturningResult(
//                 "document.documentElement.scrollHeight");
//             Object widthObj = await controller!.runJavaScriptReturningResult(
//                 'document.documentElement.scrollHeight;');
//             double height = double.tryParse(heightObj.toString()) ?? 0.0;
//             double width = double.tryParse(widthObj.toString()) ?? 0.0;
//             debugPrint('parse : $height $width');
//             if (webViewHeight != height) {
//               setState(() {
//                 webViewHeight = height;
//                 webViewWidth = width;
//               });
//               print("INSIDE");
//               print(webViewHeight * 2);
//               print(webViewWidth * 2);
//             }
// //document.body.style.zoom = 5; NOT SUPPORTED
//             await controller.runJavaScript("""
//               document.body.style.transform = "scale(5)";
//               document.body.style.transformOrigin = "0 0";
//             """);
//           },
//         ));
//         print(webViewHeight * 2);
//         print(webViewWidth * 2);
//         return Container(
//           // height: webViewHeight * 9,
//           // width: webViewWidth / 60,
//           height: webViewHeight * 2,
//           width: webViewWidth * 2,
//           child: WebViewWidget(controller: controller!),
//         );
//       },
//     );
//   }

  /// A custom Path to paint stars.
  static Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
