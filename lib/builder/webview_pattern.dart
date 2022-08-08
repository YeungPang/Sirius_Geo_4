import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../builder/pattern.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class WebViewExpl extends StatefulWidget {
  final Map<String, dynamic> map;

  const WebViewExpl(this.map, {Key? key}) : super(key: key);
  @override
  _WebViewExplState createState() => _WebViewExplState();
}

class _WebViewExplState extends State<WebViewExpl> {
  final Completer<WebViewPlusController> _controller =
      Completer<WebViewPlusController>();

  @override
  void dispose() {
    widget.map["_mv"]["_wvController"] = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> _mv = widget.map["_mv"];
    String? url = widget.map["_url"];
    dynamic html = widget.map["_html"];

    return SafeArea(
        child: WebViewPlus(
      gestureRecognizers: Set()
        ..add(
          Factory<DragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(),
          ),
        ),
      //initialUrl: widget.map["_url"],
      //gestureRecognizers: gestureSet,
      javascriptMode: widget.map["_scriptMode"] ?? JavascriptMode.disabled,
      onWebViewCreated: (WebViewPlusController controller) {
        _controller.complete(controller);
        _mv["_wvController"] = controller;
        if (url != null) {
          controller.loadUrl(url);
        } else if (html is String) {
          controller.loadString(html);
        }
      },
    ));
  }
}

class WebViewPattern extends ProcessPattern {
  WebViewPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return WebViewExpl(map);
  }
}
