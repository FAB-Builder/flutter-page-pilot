import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pagepilot/pagepilot.dart';

import 'app.dart';
import 'app_theme.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/models/styles_model.dart';
import 'package:pagepilot_example/page_pilot_keys.dart';

const String applicationId = "app-id";
const String userId = "58";

void main() {
  runApp(const MyApp());
}

Future<void> initPagePilot(Pagepilot plugin) async {
  final keys = {
    '#dialog': PagePilotKeys.keyDialog,
    '#tooltip': PagePilotKeys.keyTooltip,
    '#beacon': PagePilotKeys.keyBeacon,
  };

  final config = Config(
    credentials: {"applicationId": applicationId},
    keys: keys,
    styles: Styles(
      shadowColor: Colors.blue,
      shadowOpacity: 0.3,
      textSkip: "OK",
    ),
  );

  try {
    await plugin.init(config);
    plugin.setUserIdentifier(userId: userId);
  } on PlatformException catch (e) {
    debugPrint("PagePilot init failed: ${e.message}");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _pagepilotPlugin = Pagepilot();

  @override
  void initState() {
    super.initState();
    _initPlatformVersion();
    initPagePilot(_pagepilotPlugin);
  }

  Future<void> _initPlatformVersion() async {
    try {
      final version = await _pagepilotPlugin.getPlatformVersion();
      setState(() {
        _platformVersion = version ?? 'Unknown platform version';
      });
    } on PlatformException catch (e) {
      debugPrint('Platform version error: ${e.message}');
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
