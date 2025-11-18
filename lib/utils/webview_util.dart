import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pagepilot/utils/tour_util.dart';
import 'package:pagepilot/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/step_model.dart';
import '../widgets/pointer_widget.dart';

class WebviewUtil {
  static WebViewController? controller;
  static ValueNotifier<Map<String, double>> sizeNotifier =
      ValueNotifier<Map<String, double>>({"height": 200, "width": 200});

  static const String bodyStartsWithHtmlString = "\u003C!DOCTYPE html";

  static String calculateHtmlDocDimensions = '''
(function() {
  try {
    const body = document.body;
    const html = document.documentElement;

    // Remove scrolling and set proper styles for both platforms
    html.style.margin = '0';
    html.style.padding = '0';
    html.style.overflow = 'hidden';
    html.style.height = '100%';
    
    body.style.margin = '0';
    body.style.padding = '0';
    body.style.overflow = 'hidden';
    body.style.height = '100%';

    // Ensure all images are loaded
    const imgs = document.images;
    for (let i = 0; i < imgs.length; i++) {
      if (!imgs[i].complete) return -1;
    }

    // Compute dimensions
    let height = Math.max(
      body.scrollHeight, body.offsetHeight,
      html.clientHeight, html.scrollHeight, html.offsetHeight
    );
    let width = Math.max(
      body.scrollWidth, body.offsetWidth,
      html.clientWidth, html.scrollWidth, html.offsetWidth
    );

    return JSON.stringify({ 
      height: height.toString(), 
      width: width.toString() 
    });
  } catch (e) {
    return JSON.stringify({ height: "400", width: "400" });
  }
})();
''';

  /// ✅ Initialize WebView with full auto-size and click-channel support
  static WebViewController init({required bool isTour}) {
    final c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false);

    c.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (_) {},
        onPageStarted: (_) {},
        onPageFinished: (String url) async {
          try {
            print("✅ onPageFinished: $url");
            await Future.delayed(const Duration(milliseconds: 500));

            // First, inject the channel setup for Android
            await c.runJavaScript('''
      // Setup Flutter channel for Android compatibility
      if (typeof window.FlutterChannel === 'undefined') {
        window.FlutterChannel = {
          postMessage: function(message) {
            // For Android
            if (typeof MyFlutterApp !== 'undefined') {
              MyFlutterApp.postMessage(message);
            }
            // For iOS
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.FlutterChannel) {
              window.webkit.messageHandlers.FlutterChannel.postMessage(message);
            }
            // Fallback
            console.log('FlutterChannel message:', message);
          }
        };
      }
    ''');

            // Enhanced button click handler with better Android support
            await c.runJavaScript('''
(function() {
  console.log("[JS] Setting up persistent button listener...");

  function attachListeners() {
    const buttons = document.querySelectorAll("button[data-action]");
    console.log("[JS] Found " + buttons.length + " buttons");

    buttons.forEach(btn => {
      if (btn._listenerAttached) return; // avoid duplicates
      btn._listenerAttached = true;

      const handleClick = function(event) {
        event.preventDefault();
        event.stopImmediatePropagation();

        const action = this.getAttribute("data-action");
        const anchor = this.closest("a");
        let payload = { action: action };
        if (action === "link" && anchor) payload.url = anchor.href;

        console.log("[JS] Message to Flutter:", payload);

        try {
          if (window.FlutterChannel) {
            window.FlutterChannel.postMessage(JSON.stringify(payload));
          }
          if (window.MyFlutterApp) {
            window.MyFlutterApp.postMessage(JSON.stringify(payload));
          }
          if (window.webkit?.messageHandlers?.FlutterChannel) {
            window.webkit.messageHandlers.FlutterChannel.postMessage(JSON.stringify(payload));
          }
        } catch (e) { console.error("[JS] Error sending:", e); }
      };

      btn.addEventListener("click", handleClick, true);
      btn.addEventListener("touchend", handleClick, true);
      btn.style.cursor = "pointer";
    });
  }

  // Initial attach
  attachListeners();

  // 🔥 Fix for Android: keep listening for DOM updates
  const observer = new MutationObserver(() => {
    console.log("[JS] DOM changed — reattaching listeners");
    attachListeners();
  });

  observer.observe(document.body, { childList: true, subtree: true });
})();
''');

            // Verify the setup worked
            final setupResult = await c.runJavaScriptReturningResult('''
      (function() {
        const buttons = document.querySelectorAll('button[data-action]');
        let activeButtons = 0;
        
        buttons.forEach(btn => {
          const hasClick = btn.onclick || btn.getAttribute('onclick');
          const listeners = btn._listeners || [];
          if (hasClick || listeners.length > 0) {
            activeButtons++;
          }
        });
        
        return {
          totalButtons: buttons.length,
          activeButtons: activeButtons,
          hasFlutterChannel: typeof window.FlutterChannel !== 'undefined',
          hasMyFlutterApp: typeof window.MyFlutterApp !== 'undefined',
          hasWebkitHandlers: !!(window.webkit && window.webkit.messageHandlers)
        };
      })();
    ''');

            print('🔧 Button setup verification: $setupResult');
          } catch (e, st) {
            print('❌ Error setting up button listeners: $e\n$st');
          }
        },
        onHttpError: (error) => print("HTTP Error: $error"),
        onWebResourceError: (error) => print("Web Resource Error: $error"),
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );

    if (!isTour) controller = c;
    return c;
  }

  static Widget getWebView() {
    return WebViewWidget(controller: controller!);
  }

  static Widget getWebViewWidget(String? body, String? textColor,
      {WebViewController? tourWebViewController,
      String? contentHeight,
      String? contentwidth,
      StepModel? step,
      GlobalKey? targetKey}) {
    return body.toString().startsWith(WebviewUtil.bodyStartsWithHtmlString)
        ? contentHeight == null || contentHeight == "0"
            ? ValueListenableBuilder<Map<String, double>>(
                valueListenable: sizeNotifier,
                builder: (context, size, child) {
                  return TooltipWithFlushArrow(
                    borderRadius: (step?.borderRadius ?? 0).toDouble(),
                    arrowSize: 60,
                    showArrow: step?.isCaret == true,
                    targetKey: targetKey ?? GlobalKey(),
                    pointerPosition: step?.position.toString() == "bottom"
                        ? PointerPosition.top
                        : step?.position.toString() == "bottom-left"
                            ? PointerPosition.topRight
                            : step?.position.toString() == "bottom-right"
                                ? PointerPosition.topLeft
                                : step?.position.toString() == "top"
                                    ? PointerPosition.bottom
                                    : step?.position.toString() == "top-left"
                                        ? PointerPosition.bottomLeft
                                        : step?.position.toString() ==
                                                "top-right"
                                            ? PointerPosition.bottomRight
                                            : step?.position.toString() ==
                                                    "left"
                                                ? PointerPosition.right
                                                : step?.position.toString() ==
                                                        "right"
                                                    ? PointerPosition.left
                                                    : PointerPosition.bottom,
                    color: Util.hexToColor(step?.backgroundColor ?? "#000000"),
                    height: size["height"] ?? 0,
                    width: size["width"] ?? 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Util.hexToColor(step?.backgroundColor ?? "#000000"),
                        borderRadius: BorderRadius.circular(
                            (step?.borderRadius ?? 0).toDouble()),
                      ),
                      height: size["height"],
                      // width: size["width"],
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: WebViewWidget(
                          gestureRecognizers: Platform.isIOS
                              ? <Factory<OneSequenceGestureRecognizer>>{
                                  Factory<VerticalDragGestureRecognizer>(
                                    () => VerticalDragGestureRecognizer(),
                                  ),
                                }.toSet()
                              : <Factory<OneSequenceGestureRecognizer>>{
                                  Factory<VerticalDragGestureRecognizer>(
                                    () => VerticalDragGestureRecognizer(),
                                  ),
                                }.toSet(),
                          controller: tourWebViewController ?? controller!),
                    ),
                  );
                },
              )
            : TooltipWithFlushArrow(
                borderRadius: (step?.borderRadius ?? 0).toDouble(),
                arrowSize: 60,
                showArrow: step?.isCaret == true,
                targetKey: targetKey ?? GlobalKey(),
                pointerPosition: step?.position.toString() == "bottom"
                    ? PointerPosition.top
                    : step?.position.toString() == "bottom-left"
                        ? PointerPosition.topRight
                        : step?.position.toString() == "bottom-right"
                            ? PointerPosition.topLeft
                            : step?.position.toString() == "top"
                                ? PointerPosition.bottom
                                : step?.position.toString() == "top-left"
                                    ? PointerPosition.bottomLeft
                                    : step?.position.toString() == "top-right"
                                        ? PointerPosition.bottomRight
                                        : step?.position.toString() == "left"
                                            ? PointerPosition.right
                                            : step?.position.toString() ==
                                                    "right"
                                                ? PointerPosition.left
                                                : PointerPosition.bottom,
                color: Util.hexToColor(step?.backgroundColor ?? "#000000"),
                height: double.tryParse(
                        contentHeight.toString().replaceAll("px", "")) ??
                    200,
                width: double.tryParse(
                        contentwidth.toString().replaceAll("px", "")) ??
                    200,
                child: Container(
                  height: double.tryParse(
                          contentHeight.toString().replaceAll("px", "")) ??
                      200,
                  width: double.tryParse(
                          contentwidth.toString().replaceAll("px", "")) ??
                      200,
                  decoration: BoxDecoration(
                    color: Util.hexToColor(step?.backgroundColor ?? "#000000"),
                    borderRadius: BorderRadius.circular(
                        (step?.borderRadius ?? 0).toDouble()),
                  ),
                  child: WebViewWidget(
                      gestureRecognizers: Platform.isIOS
                          ? <Factory<OneSequenceGestureRecognizer>>{
                              Factory<VerticalDragGestureRecognizer>(
                                () => VerticalDragGestureRecognizer(),
                              ),
                            }.toSet()
                          : <Factory<OneSequenceGestureRecognizer>>{
                              Factory<VerticalDragGestureRecognizer>(
                                () => VerticalDragGestureRecognizer(),
                              ),
                            }.toSet(),
                      controller: tourWebViewController ?? controller!),
                ),
              )
        : Text(
            body.toString(),
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: textColor != null ? Util.hexToColor(textColor) : null,
            ),
          );
  }

  static void clearCache() {
    controller!.clearCache();
  }

  static load(String? url, String? body,
      {WebViewController? tourWebViewController}) {
    if (url != null) {
      WebviewUtil.loadUrl(url);
    }
    if (body.toString().startsWith(bodyStartsWithHtmlString)) {
      WebviewUtil.loadHtml(body, tourWebViewController: tourWebViewController);
      // adjustWebviewZoom(scale: scale ?? 2);
      WebViewController? c;
      if (tourWebViewController != null) {
        c = tourWebViewController;
      } else {
        c = controller;
      }
      c!.addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final data = jsonDecode(message.message);
          switch (data['action']) {
            case 'onNextStep':
              print("NEXTTTT");
              TourUtil.next();
              break;
            case 'onPrevStep':
              TourUtil.previous();
              break;
            case 'openLink':
              final url = data['url'] as String;
              Util.launchInBrowser(url);
              break;
            case 'onCloseStep':
              TourUtil.finish();
              break;
          }
        },
      );
    }
  }

  static void loadUrl(String url) {
    controller!.loadRequest(Uri.parse(url));
  }

  static void loadHtml(String? body,
      {WebViewController? tourWebViewController}) {
    WebViewController? c;
    if (tourWebViewController != null) {
      c = tourWebViewController;
    } else {
      c = controller;
    }
    c!.loadHtmlString(body.toString());
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
}
