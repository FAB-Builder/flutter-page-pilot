import 'dart:async';
import 'dart:convert';

import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:pagepilot/utils/tour_util.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:pagepilot/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/step_model.dart';

class WebviewUtil {
  static WebViewController? controller;
  static ValueNotifier<Map<String, double>> sizeNotifier =
      ValueNotifier<Map<String, double>>({"height": 200, "width": 200});

  static String bodyStartsWithHtmlString = "\u003C!DOCTYPE html";

  static String calculateHtmlDocDimensions = '''
      (function() {
        const body = document.body;
        const html = document.documentElement;

        html.style.margin = '0';
        html.style.padding = '0';
        html.style.overflow = 'hidden';
        body.style.margin = '0';
        body.style.padding = '0';
        body.style.overflow = 'hidden';

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
    ''';

  static WebViewController init({required bool isTour}) {
    WebViewController c;
    c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // ✅ Transparent background
      ..enableZoom(false);
    c.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) async {
          try {
            // Wait for layout (especially images/fonts)
            print("onPageFinished");
            await Future.delayed(const Duration(milliseconds: 400));

            // Inject JS to intercept clicks on buttons with
            //data-action="onNextStep"
            //data-action="onPrevStep"
            //data-action="link"
            //data-action="onCloseStep"
            await c!.runJavaScript('''
                document.querySelectorAll('button[data-action="onNextStep"]').forEach(btn => {
                  btn.addEventListener('click', () => {
                    FlutterChannel.postMessage(JSON.stringify({action: 'onNextStepClicked'}));
                  });
                });
                document.querySelectorAll('button[data-action="onPrevStep"]').forEach(btn => {
                  btn.addEventListener('click', () => {
                    FlutterChannel.postMessage(JSON.stringify({action: 'onPrevStepClicked'}));
                  });
                });
                document.querySelectorAll('button[data-action="link"]').forEach(btn => {
                  btn.addEventListener('click', (event) => {
                    event.preventDefault(); // Prevent navigation
                    const anchor = btn.closest('a');
                    if (anchor) {
                      // Send URL to Flutter
                      FlutterChannel.postMessage(JSON.stringify({action: 'openLink', url: anchor.href}));
                    }
                  });
                });
                document.querySelectorAll('button[data-action="onCloseStep"]').forEach(btn => {
                  btn.addEventListener('click', () => {
                    FlutterChannel.postMessage(JSON.stringify({action: 'onCloseStepClicked'}));
                  });
                });
              ''');

            final jsResult = await c!
                .runJavaScriptReturningResult(calculateHtmlDocDimensions);

            // if (jsResult.toString().contains('-1')) {
            //   await Future.delayed(const Duration(milliseconds: 300));
            //   return onPageFinished(url);
            // }

            // final jsonStr =
            //     jsResult.toString().replaceAll(RegExp(r'[^0-9.]'), '');
            final decoded = jsonDecode(jsResult.toString());

            final calculatedHeight = decoded['height'];
            final calculatedWidth = decoded['width'];

            final heightVal = double.tryParse(calculatedHeight) ?? 0;
            final widthVal = double.tryParse(calculatedWidth) ?? 0;

            final pixelRatioJs = await c!
                .runJavaScriptReturningResult('window.devicePixelRatio');
            final pixelRatio = double.tryParse(pixelRatioJs.toString()) ?? 1.0;

            final adjustedHeight = (heightVal / pixelRatio) + 40;
            final adjustedWidth = (widthVal / pixelRatio) + 75;

            sizeNotifier.value = {
              "height": adjustedHeight,
              "width": adjustedWidth
            };
            print('WebView size set to: ${sizeNotifier.value}');
          } catch (e) {
            print('Error getting size: $e');

            sizeNotifier.value = {
              "height": 400,
              "width": 400,
            };
          }
        },
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          // if (request.url.startsWith('https://www.youtube.com/')) {
          //   return NavigationDecision.prevent;
          // }
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

  static Widget getWebViewWidget(
      String? body, String? textColor, String? contentHeight,
      {WebViewController? tourWebViewController,
      StepModel? step,
      ElTooltipController? tooltip}) {
    GlobalKey key = GlobalKey();
    return body.toString().startsWith(WebviewUtil.bodyStartsWithHtmlString)
        ? contentHeight == null
            ? ValueListenableBuilder<Map<String, double>>(
                valueListenable: sizeNotifier,
                builder: (context, size, child) {
                  String position = (step?.position ?? "").toString();
                  try {
                    if (tooltip != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        await Future.delayed(const Duration(milliseconds: 300));
                        tooltip.show();
                      });
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                  return ElTooltip(
                      radius: Radius.zero,
                      position: position == "bottom"
                          ? ElTooltipPosition.bottomStart
                          : position == "top"
                              ? ElTooltipPosition.topCenter
                              : position == "left"
                                  ? ElTooltipPosition.leftCenter
                                  : position == "right"
                                      ? ElTooltipPosition.rightCenter
                                      : ElTooltipPosition.bottomCenter,
                      key: key,
                      distance: (size["height"] ?? 0) / 2,
                      showModal: false,
                      showChildAboveOverlay: false,
                      controller: tooltip,
                      padding: EdgeInsets.zero,
                      color:
                          Util.hexToColor(step?.backgroundColor ?? "#000000"),
                      content: SizedBox(
                        height: size["height"],
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: WebViewWidget(
                            controller: tourWebViewController ?? controller!),
                      ),
                      child: const SizedBox());
                },
              )
            : SizedBox(
                height: double.tryParse(
                        contentHeight.toString().replaceAll("px", "replace")) ??
                    200,
                // width:
                //     MediaQuery.of(context).size.width * 0.8,
                child: ElTooltip(
                  position: step?.position.toString() == "bottom"
                      ? ElTooltipPosition.bottomCenter
                      : step?.position.toString() == "top"
                          ? ElTooltipPosition.topCenter
                          : step?.position.toString() == "left"
                              ? ElTooltipPosition.leftCenter
                              : step?.position.toString() == "right"
                                  ? ElTooltipPosition.rightCenter
                                  : ElTooltipPosition.bottomCenter,
                  key: key,
                  showModal: false,
                  showChildAboveOverlay: false,
                  controller: tooltip,
                  padding: EdgeInsets.zero,
                  distance: (double.tryParse(contentHeight
                              .toString()
                              .replaceAll("px", "replace")) ??
                          200) /
                      2,
                  color: Util.hexToColor(step?.backgroundColor ?? "#000000"),
                  content: WebViewWidget(
                      controller: tourWebViewController ?? controller!),
                  child: const SizedBox(),
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
            case 'onNextStepClicked':
              print("NEXTTTT");
              TourUtil.next();
              break;
            case 'onPrevStepClicked':
              TourUtil.previous();
              break;
            case 'openLink':
              final url = data['url'] as String;
              Util.launchInBrowser(url);
              break;
            case 'onCloseStepClicked':
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
