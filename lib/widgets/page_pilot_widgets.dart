import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/models/styles_model.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class PagePilot {
  static OverlayEntry? _overlayEntry;
  static late TutorialCoachMark tutorialCoachMark;
  static double borderRadius = 20;
  static double padding = 16;
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
  }

  static void initTutorialCoachMark(List<TargetFocus> targets) {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: styles.shadowColor ?? Colors.red,
      textSkip: styles.textSkip ?? "SKIP",
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
      {required String title, required String body, int duration = 3000}) {
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
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Column(
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
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    _overlayEntry?.remove();
                    _overlayEntry = null;
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
    });
  }

  static void showBottomSheet(BuildContext context,
      {required String title,
      required String body,
      required Function() onOkPressed}) {
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
              color: Colors.white,
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

  static void showOkDialog(BuildContext context,
      {required GlobalKey key,
      required String shape,
      required String title,
      required String description,
      Function()? onOkPressed}) {
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
                title: Text(
                  title,
                ),
                // backgroundColor: AppTheme.backgroundColor,
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(
                        description,
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

    // showDialog(
    //   context: context,
    //   barrierDismissible: false, // user must tap button!
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text(
    //         title,
    //       ),
    //       // backgroundColor: AppTheme.backgroundColor,
    //       content: SingleChildScrollView(
    //         child: ListBody(
    //           children: <Widget>[
    //             Text(
    //               description,
    //             ),
    //           ],
    //         ),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: const Text(
    //             'Cancel',
    //           ),
    //         ),
    //         TextButton(
    //           onPressed: onOkPressed,
    //           child: const Text(
    //             'OK',
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  static void showTooltip(
    BuildContext context, {
    required GlobalKey key,
    required String shape,
    required String title,
    required String description,
  }) {
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
                  color: Colors.white,
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
                      description,
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
  }) {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        shape: shape.toString().toLowerCase() == "rect"
            ? ShapeLightFocus.RRect
            : ShapeLightFocus.Circle,
        identify: "keyBeacon",
        keyTarget: key,
        alignSkip: Alignment.topRight,
        enableOverlayTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  // border: Border.all(color: Colors.black),
                  // borderRadius: BorderRadius.circular(50),
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

  static void showTour(
    BuildContext context,
    Config config, {
    required List<dynamic> tours,
    // required Widget widget,
  }) {
    List<TargetFocus> targets = [];

    for (int i = 0; i < tours.length; i++) {
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
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        ),
                      ),
                      Text(tours[i]["description"].toString()),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    PagePilot.initTutorialCoachMark(targets);
    tutorialCoachMark.show(context: context);
  }
}
