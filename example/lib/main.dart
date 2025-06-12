import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/models/styles_model.dart';
import 'package:pagepilot/pagepilot.dart';
import 'package:pagepilot/widgets/pagepilotpip.dart';
import 'app_theme.dart';
import 'package:pagepilot/widgets/page_pilot_banner.dart';

void main() {
  runApp(MyApp());
}

// TODO : Add your credentials
const applicationId = "";
const userId = "58"; 

GlobalKey keyDialog = GlobalKey();
GlobalKey keyTooltip = GlobalKey();
GlobalKey keyBeacon = GlobalKey();
GlobalKey keyappbanner = GlobalKey();
bool showpip=false;

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
      print(e.toString());
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
      '#appbanner':keyappbanner,
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
      await _pagepilotPlugin.init(config!); // initialize the library
      _pagepilotPlugin.setUserIdentifier(userId: userId);
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
  String platformVersion;
  Pagepilot pagepilotPlugin;

  App({
    super.key,
    required this.platformVersion,
    required this.pagepilotPlugin,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentpage=0;

  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PagePilotPiP(
       pipContent: PagePilotBanner(autoplay: false,pipon: true,owncontroller: true,currentpage: _currentpage,pagecontroller: pageController,itemHeight:400 ,itemWidth: double.infinity, ),
        pipHeight: 200,
        pipWidth: 300,
        showPiP: showpip,
        onClose: () {
          setState(() {
            showpip=false;
          });
        },
      mainContent: 
       Scaffold(
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
              child: Text("Tap     Me!"),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(key: keyDialog, 'Dialog'),
                Text(key: keyTooltip, 'Tooltip'),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Text('tour'),
            ),
            SizedBox(height: 20),
          PagePilotBanner(
                
                    showpipfunction: (index) {
                      setState(() {
                        showpip=!showpip;
                        _currentpage=index;
              
                      print("value ${_currentpage}");
                      });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
              if (pageController.hasClients) {
                pageController.jumpToPage(index);
              }
            });
                    
                    },
                    key: keyappbanner,
                    backgroundcolor: Colors.transparent,
                    
                    titlestyle: TextStyle(color: Colors.cyan),
                    descriptionstyle: TextStyle(color: Colors.black),
                    
                    // descriptionbackground: Colors.white,
                    // descriptionstyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    
                    itemHeight: 400,
                    autoplay: false,
                    
                    itemWidth: double.infinity,
                    radius: 10,
                  ),
                  
          ],
        ),
      ),
    );
  }
}
