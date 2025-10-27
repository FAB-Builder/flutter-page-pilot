import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:pagepilot/widgets/utils.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewUtil {
  static WebViewController? controller;
  static ValueNotifier<double> heightNotifier = ValueNotifier<double>(200);
  static String bodyStartsWithHtmlString = "\u003C!DOCTYPE html";

  init() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // ✅ Transparent background
      ..enableZoom(false);

    controller!.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) async {
          try {
            // Wait for layout (especially images/fonts)
            await Future.delayed(const Duration(milliseconds: 400));

            // Inject JS to intercept clicks on buttons with
            //data-action="onNextStep"
            //data-action="onPrevStep"
            //data-action="link"
            //data-action="onCloseStep"
            await controller!.runJavaScript('''
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

            final jsResult = await controller!.runJavaScriptReturningResult('''
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

        return height.toString();
      })();
    ''');

            // if (jsResult.toString().contains('-1')) {
            //   await Future.delayed(const Duration(milliseconds: 300));
            //   return onPageFinished(url);
            // }

            final heightStr =
                jsResult.toString().replaceAll(RegExp(r'[^0-9.]'), '');
            final heightVal = double.tryParse(heightStr) ?? 0;

            final pixelRatioJs = await controller!
                .runJavaScriptReturningResult('window.devicePixelRatio');
            final pixelRatio = double.tryParse(pixelRatioJs.toString()) ?? 1.0;

            final adjustedHeight = (heightVal / pixelRatio) + 75;

            heightNotifier.value = adjustedHeight;
            print('WebView height set to: ${heightNotifier.value}');
          } catch (e) {
            print('Error getting height: $e');
            heightNotifier.value = 400;
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
  }

  static Widget getWebView() {
    return WebViewWidget(controller: controller!);
  }

  static Widget getWebViewWidget(
      String? body, String? textColor, String? contentHeight) {
    return body.toString().startsWith(WebviewUtil.bodyStartsWithHtmlString)
        ? contentHeight == null
            ? ValueListenableBuilder<double>(
                valueListenable: heightNotifier,
                builder: (context, height, child) {
                  return SizedBox(
                    height: height,
                    // width:
                    //     MediaQuery.of(context).size.width * 0.8,
                    child: WebViewWidget(controller: controller!),
                  );
                },
              )
            : SizedBox(
                height: double.tryParse(
                        contentHeight.toString().replaceAll("px", "replace")) ??
                    200,
                // width:
                //     MediaQuery.of(context).size.width * 0.8,
                child: WebViewWidget(controller: controller!),
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

  static load(String? url, String? body, TutorialCoachMark? tutorialCoachMark) {
    if (url != null) {
      WebviewUtil.loadUrl(url);
    }
    if (body.toString().startsWith(bodyStartsWithHtmlString)) {
      WebviewUtil.loadHtml(body);
      // adjustWebviewZoom(scale: scale ?? 2);
      controller!.addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final data = jsonDecode(message.message);
          switch (data['action']) {
            case 'openLink':
              final url = data['url'] as String;
              Util.launchInBrowser(url);
              break;
            case 'onCloseStepClicked':
              if (tutorialCoachMark != null) {
                tutorialCoachMark!.finish();
              }
              ;
              break;
          }
        },
      );
    }
  }

  static void loadUrl(String url) {
    controller!.loadRequest(Uri.parse(url));
  }

  static void loadHtml(String? body) {
    controller!.loadHtmlString(body.toString());
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
