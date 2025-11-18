import 'package:flutter/material.dart';
import 'package:pagepilot/pagepilot.dart';

class RR extends StatefulWidget {
  const RR({super.key});

  @override
  State<RR> createState() => _RRState();
}

class _RRState extends State<RR> {
  GlobalKey keyTooltip = GlobalKey();
  final Pagepilot pagepilotPlugin = Pagepilot();
  @override
  void initState() {
    pagepilotPlugin.show(
        keys: {"#tooltip": keyTooltip},
        context: context,
        screen: "/tts",
        showNextAndPreviousButtons: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(key: keyTooltip, "d"),
      ),
    );
  }
}
