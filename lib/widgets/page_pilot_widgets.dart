import 'dart:ui';
import 'package:flutter/material.dart';
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
  static WebViewController? controller;
  static Styles styles = Styles(
    shadowColor: Colors.red,
    shadowOpacity: 0.5,
    textSkip: "SKIP",
    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
  );

  static void initStyles(Styles? s) {
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

  static void showSnackbar(BuildContext context,
      {String? title, String? body, String? url, int duration = 3000}) {
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
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                title != null && body != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            body,
                            style: TextStyle(color: Colors.white),
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
  }

  static void showBottomSheet(BuildContext context,
      {required String title,
      required String body,
      required Function() onOkPressed}) {
    var isDarkTheme = Theme.of(context).brightness == Brightness.dark;
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
              color: isDarkTheme ? Colors.black : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  body,
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
  }

  static void showOkDialog(
    BuildContext context, {
    required String shape,
    String? title,
    String? body,
    String? url,
    Function()? onOkPressed,
  }) {
    var isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDarkTheme ? Colors.black : Colors.white,
            title: title != null ? Text(title!) : null,
            content: SingleChildScrollView(
              child: body != null
                  ? Text(body)
                  : Container(
                      height: 200,
                      width: 200,
                      child: WebViewWidget(controller: controller!),
                    ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: onOkPressed == null
                    ? () {
                        Navigator.pop(context);
                      }
                    : () {
                        Navigator.pop(context);
                        controller!.clearCache();
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
    required String title,
    required String body,
  }) {
    var isDarkTheme = Theme.of(context).brightness == Brightness.dark;
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
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      body,
                      overflow: TextOverflow.clip,
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
  }

  static void showPip(
    BuildContext context, {
    required GlobalKey key,
  }) {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "keyPip",
        keyTarget: key,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Stack(
                  children: [
                    Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              borderRadius), // Image border
                          child: SizedBox.fromSize(
                            // size: Size.fromRadius(48), // Image radius
                            child: Image.network(
                              "https://picsum.photos/200/400",
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadius),
                            topRight: Radius.circular(borderRadius),
                          ),
                          color: Color.fromARGB(120, 0, 0, 0),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              child: Icon(Icons.fullscreen),
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              child: Icon(Icons.audiotrack_sharp),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                tutorialCoachMark.finish();
                              },
                              child: Icon(Icons.close),
                            ),
                          ],
                        ),
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
  }

  static void showBeacon(
    BuildContext context, {
    required String shape,
    required GlobalKey key,
    required String beaconPosition,
    required String title,
    required String body,
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
                        color: isDarkTheme ? Colors.black : Colors.white,
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
                              color: isDarkTheme ? Colors.white : Colors.black,
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
                              : Text(tours[i]["body"].toString()),
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
}
