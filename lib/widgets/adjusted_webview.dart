import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdjustedWebview extends StatefulWidget {
  WebViewController controller;
  AdjustedWebview({super.key, required this.controller});

  @override
  State<AdjustedWebview> createState() => _AdjustedWebviewState();
}

class _AdjustedWebviewState extends State<AdjustedWebview> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
