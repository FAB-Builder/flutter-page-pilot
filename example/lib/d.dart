import 'package:flutter/material.dart';
import 'package:pagepilot/pagepilot.dart';

import 'main.dart';

class RR extends StatefulWidget {
  const RR({super.key});

  @override
  State<RR> createState() => _RRState();
}

class _RRState extends State<RR> {
  final Pagepilot pagepilotPlugin = Pagepilot();
  @override
  void initState() {
    pagepilotPlugin.show(
        context: context, screen: "/tts", showNextAndPreviousButtons: true);
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
