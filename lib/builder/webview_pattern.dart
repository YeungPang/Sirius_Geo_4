// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../builder/pattern.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewExpl extends StatefulWidget {
  final Map<String, dynamic> map;

  const WebViewExpl(this.map, {Key? key}) : super(key: key);
  @override
  _WebViewExplState createState() => _WebViewExplState();
}

class _WebViewExplState extends State<WebViewExpl> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    //Map<String, dynamic>? _mv = widget.map["_mv"];
    String? _url = widget.map["_url"];
    String? _html = widget.map["_html"];
    String? _file = widget.map["_file"];
    dynamic _scriptMode = widget.map["_scriptMode"] ?? JavaScriptMode.disabled;
    if (_scriptMode is String) {
      if (_scriptMode.toLowerCase() == "unrestricted") {
        _scriptMode = JavaScriptMode.unrestricted;
      } else {
        _scriptMode = JavaScriptMode.disabled;
      }
    }

    controller
      ..setJavaScriptMode(_scriptMode)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      );
    if (_url != null) {
      controller.loadRequest(Uri.parse(_url));
    } else if (_html != null) {
      controller.loadHtmlString(_html);
    } else if (_file != null) {
      controller.loadFile(_file);
    }

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  void dispose() {
    //widget.map["_mv"]["_wvController"] = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: WebViewWidget(controller: _controller));
  }
}

class WebViewPattern extends ProcessPattern {
  WebViewPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return WebViewExpl(map);
  }
}
