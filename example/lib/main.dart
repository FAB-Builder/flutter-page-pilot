import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/models/styles_model.dart';
import 'package:pagepilot/pagepilot.dart';
import 'package:pagepilot_example/app_theme.dart';

void main() {
  runApp(MyApp());
}

// TODO : Add your crdentials
const applicationId = "";
const clientId = "";
const clientSecret = "";
const version = "";
const userId = "58"; //1234

GlobalKey keyDialog = GlobalKey();
GlobalKey keyTooltip = GlobalKey();
GlobalKey keyBeacon = GlobalKey();

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
      '#beacon': keyBeacon
    };

    Config config = Config(
      applicationId: applicationId,
      clientId: clientId,
      clientSecret: clientSecret,
      userId: userId,
      version: version,
      keys: keys,
      styles:
          Styles(shadowColor: Colors.blue, shadowOpacity: 0.3, textSkip: "OK"),
    );
    try {
      await _pagepilotPlugin.init(config!); // initialize the library
    } on PlatformException {
      // Log exception and report studio@gameolive.com
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: App(
        platformVersion: _platformVersion,
        pagepilotPlugin: _pagepilotPlugin,
      ),
    );
  }
}

class App extends StatelessWidget {
  String platformVersion;
  Pagepilot pagepilotPlugin;

  App({
    super.key,
    required this.platformVersion,
    required this.pagepilotPlugin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('Running on: $platformVersion\n'),
          ),
          ElevatedButton(
            onPressed: () {
              pagepilotPlugin.show(context: context, screen: "home");
            },
            child: Text("Show"),
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
            child: Text(key: keyBeacon, 'Beacon'),
          ),
        ],
      ),
    );
  }
}
