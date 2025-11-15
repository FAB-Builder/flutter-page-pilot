import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  static String calculateHtmlDocDimensions = Platform.isIOS
      ? '''
      (function() {
        const body = document.body;
        const html = document.documentElement;

        html.style.margin = '0';
        html.style.padding = '0';
        html.style.overflow = 'auto';
        body.style.margin = '0';
        body.style.padding = '0';
        body.style.overflow = 'auto';

        // Ensure all images loaded
        const imgs = document.images;
        for (let i = 0; i < imgs.length; i++) {
          if (!imgs[i].complete) return -1;
        }

        let height = Math.max(
          body.scrollHeight, body.offsetHeight,
          html.clientHeight, html.scrollHeight, html.offsetHeight
        );
        let width = Math.max(
          body.scrollWidth, body.offsetWidth,
          html.clientWidth, html.scrollWidth, html.offsetWidth
        );


        // Consider iframes
        const iframes = document.getElementsByTagName('iframe');
        for (let i = 0; i < iframes.length; i++) {
          const iframe = iframes[i];
          let iframeHeight = 0;
          let iframeWidth = 0;

          try {
            // Try reading internal body height (same-origin only)
            const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
            if (iframeDoc && iframeDoc.readyState === 'complete') {
              const ib = iframeDoc.body;
              if (ib) {
                iframeHeight = Math.max(ib.scrollHeight, ib.offsetHeight);
                iframeWidth = Math.max(ib.scrollWidth, ib.offsetWidth);
              }
            }
          } catch (e) {
            // Cross-origin: fallback to visible/computed height
            iframeHeight =
              parseInt(iframe.getAttribute('height')) ||
              iframe.offsetHeight ||
              parseInt(window.getComputedStyle(iframe).height) ||
              0;
            iframeWidth =
              parseInt(iframe.getAttribute('width')) ||
              iframe?.offsetWidth ||
              parseInt((window.getComputedStyle(iframe) || {}).width)  || 0;
          }

          // Add based on bottom edge position, not sum
          height=height+(iframeHeight);
          if(iframeWidth){
            width = iframeWidth;
          }
        }

        return JSON.stringify({ height: height.toString(), width: width.toString() });
      })();
    '''
      : '''
(function() {
  try {
    const body = document.body;
    const html = document.documentElement;

    html.style.margin = '0';
    html.style.padding = '0';
    body.style.margin = '0';
    body.style.padding = '0';
    html.style.overflow = 'visible';
    body.style.overflow = 'visible';

    // Wait until all images and iframes are fully loaded
    const imgs = document.images;
    for (let i = 0; i < imgs.length; i++) {
      if (!imgs[i].complete) return -1;
    }

    // Compute true rendered bounds
    const rect = body.getBoundingClientRect();
    const height = rect.bottom - rect.top;
    const width = rect.right - rect.left;

    // Include any absolutely positioned or floating elements outside normal flow
    const all = document.querySelectorAll('*');
    let maxBottom = height;
    let maxRight = width;
    all.forEach(el => {
      const r = el.getBoundingClientRect();
      if (r.bottom > maxBottom) maxBottom = r.bottom;
      if (r.right > maxRight) maxRight = r.right;
    });

    const finalHeight = Math.ceil(maxBottom);
    const finalWidth = Math.ceil(maxRight);

    return JSON.stringify({
      height: finalHeight.toString(),
      width: finalWidth.toString()
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
            await Future.delayed(const Duration(milliseconds: 400));

            // Inject button click listeners
            await c.runJavaScript('''
      document.querySelectorAll('button[data-action]').forEach(btn => {
        btn.addEventListener('click', (event) => {
          const action = btn.getAttribute('data-action');
          const anchor = btn.closest('a');
          let payload = { action };
          if (action === 'link' && anchor) {
            event.preventDefault();
            payload.url = anchor.href;
          }
          FlutterChannel.postMessage(JSON.stringify(payload));
        });
      });
    ''');

            // --- Safe JSON parser (no double decode) ---
            dynamic safeJsonParse(dynamic jsResult) {
              if (jsResult == null) return {};
              dynamic str = jsResult.toString().trim();

              // Unwrap quoted JSON like "\"{...}\""
              if (str.startsWith('"') && str.endsWith('"')) {
                str = str.substring(1, str.length - 1);
              }

              // Replace escaped quotes
              str = str.replaceAll(r'\"', '"');

              try {
                final json = jsonDecode(str);
                if (json is Map) return json;
              } catch (_) {}
              return {};
            }

            Map<String, double> newSize = {"height": 400, "width": 400};

            for (int attempt = 0; attempt < 3; attempt++) {
              final jsResult = await c
                  .runJavaScriptReturningResult(calculateHtmlDocDimensions);

              if (jsResult.toString().contains('-1')) {
                await Future.delayed(const Duration(milliseconds: 300));
                continue;
              }

              final decoded = safeJsonParse(jsResult);

              final heightVal =
                  double.tryParse(decoded['height']?.toString() ?? '0') ?? 0;
              final widthVal =
                  double.tryParse(decoded['width']?.toString() ?? '0') ?? 0;

              // Pixel ratio
              final pixelRatioJs = await c
                  .runJavaScriptReturningResult('window.devicePixelRatio');
              final pixelRatio =
                  double.tryParse(pixelRatioJs.toString()) ?? 1.0;

              final adjustedHeight = (heightVal / pixelRatio);
              final adjustedWidth = (widthVal / pixelRatio);

              // Sanity cap
              if (adjustedHeight > 3000 || adjustedHeight < 100) {
                print("⚠️ Height suspicious ($adjustedHeight), fallback used");
                newSize = {"height": 400, "width": 400};
              } else {
                newSize = {"height": adjustedHeight, "width": adjustedWidth};
              }
              break;
            }

            if (newSize["height"]! > 5000) newSize["height"] = 500;

            sizeNotifier.value = newSize;
            print('📏 Final WebView size (adjusted): $newSize');
          } catch (e, st) {
            print('❌ Error calculating WebView size: $e\n$st');
            sizeNotifier.value = {"height": 400, "width": 400};
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
                    borderRadius: 12,
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: size["height"],
                      // width: size["width"],
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: WebViewWidget(
                          controller: tourWebViewController ?? controller!),
                    ),
                  );
                },
              )
            : TooltipWithFlushArrow(
                borderRadius: 12,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: WebViewWidget(
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
