import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/models/styles_model.dart';
import 'package:pagepilot/pagepilot.dart';
import 'package:pagepilot/widgets/page_pilot_widgets.dart';
import 'package:pagepilot/widgets/pagepilotpip.dart';
import 'app_theme.dart';
import 'package:pagepilot/widgets/page_pilot_banner.dart';

void main() {
  runApp(const MyApp());
}

// TODO : Add your credentials
const applicationId = "";
const userId = "ANNONYMOUS";
const tenantId = "656da5fce2d64e67b2b77e75";

GlobalKey keyDialog = GlobalKey();
GlobalKey keyTooltip = GlobalKey();
GlobalKey keyBeacon = GlobalKey();
GlobalKey keyappbanner = GlobalKey();
bool showpip = false;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _pagepilotPlugin = Pagepilot();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initPagePilot();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _pagepilotPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    } catch (e) {
      debugPrint(e.toString());
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  initPagePilot() async {
    Map keys = {
      '#dialog': keyDialog,
      '#tooltip': keyTooltip,
      '#beacon': keyBeacon,
      '#appbanner': keyappbanner,
    };

    Config config = Config(
      credentials: {
        "applicationId": applicationId,
      },
      keys: keys,
      styles:
          Styles(shadowColor: Colors.blue, shadowOpacity: 0.3, textSkip: "OK"),
    );
    try {
      _pagepilotPlugin.setUserIdentifier(userId: userId, tenantId: tenantId);
      await _pagepilotPlugin.init(config); // initialize the library
    } on PlatformException {
      // Log exception and report studio@gameolive.com
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: App(
        platformVersion: _platformVersion,
        pagepilotPlugin: _pagepilotPlugin,
      ),
    );
  }
}

class App extends StatefulWidget {
  final String platformVersion;
  final Pagepilot pagepilotPlugin;

  const App({
    super.key,
    required this.platformVersion,
    required this.pagepilotPlugin,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentpage = 0;

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Call your method that uses screenSize or Overlay.of(context)
      PagePilot.showFloatingWidget(
        context,
        isVisible: true,
        position: "bottomleft",
        isDraggable: true,
        onTap: () {
          print("ok");
        },
        customWidget: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF874DFF), Color(0xFF2885FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(87.61 * 3.1415927 / 180),
            ),
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(0),
              right: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image.asset(
              //   AssetUrl.verify,
              //   width: 16,
              //   height: 16,
              //   color: Colors.white,
              // ),
              SizedBox(width: 4),
              Text(
                "Hello",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_right_rounded,
                color: const Color(0xFF0069CA),
                size: 16,
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PagePilotPiP(
      pipContent: PagePilotBanner(
        autoplay: false,
        pipon: true,
        owncontroller: true,
        currentpage: _currentpage,
        pagecontroller: pageController,
        itemHeight: 400,
        itemWidth: double.infinity,
      ),
      pipHeight: 200,
      pipWidth: 300,
      showPiP: showpip,
      onClose: () {
        setState(() {
          showpip = false;
        });
      },
      mainContent: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: ${widget.platformVersion}\n'),
            ),
            ElevatedButton(
              key: keyBeacon,
              onPressed: () {
                widget.pagepilotPlugin.show(context: context, screen: "home");
              },
              child: const Text("Tap     Me!"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(key: keyDialog, 'Dialog'),
                Text(key: keyTooltip, 'Tooltip'),
              ],
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('tour'),
            ),
            const SizedBox(height: 20),
            PagePilotBanner(
              showpipfunction: (index) {
                setState(() {
                  showpip = !showpip;
                  _currentpage = index;

                  debugPrint("value $_currentpage");
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (pageController.hasClients) {
                    pageController.jumpToPage(index);
                  }
                });
              },
              key: keyappbanner,
              backgroundcolor: Colors.transparent,
              deepLinkPrefix: "",
              onDeeplinkTap: (String link) => debugPrint(link),
              titleStyle: const TextStyle(color: Colors.cyan),
              descriptionStyle: const TextStyle(color: Colors.black),
              itemHeight: 157,
              autoplay: true,
              itemWidth: double.infinity,
              radius: 10,
              autoplayDelay: 5000,
            ),
          ],
        ),
      ),
    );
  }
}
