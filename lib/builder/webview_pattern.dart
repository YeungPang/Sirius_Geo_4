import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewExpl extends StatefulWidget {
  final Map<String, dynamic> map;

  WebViewExpl(this.map);
  @override
  _WebViewExplState createState() => _WebViewExplState();
}

class _WebViewExplState extends State<WebViewExpl> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    var verticalGestures = Factory<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer());
    //var gestureSet = Set.from([verticalGestures]);
    Map<String, dynamic> _mv = widget.map["_mv"];
    return WebView(
      initialUrl: widget.map["_url"],
      //gestureRecognizers: gestureSet,
      javascriptMode: widget.map["_scriptMode"] ?? JavascriptMode.disabled,
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
        if (_mv != null) {
          _mv["_wvController"] = webViewController;
        }
      },
    );
  }
}

class WebViewPattern extends ProcessPattern {
  WebViewPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    return WebViewExpl(map);
  }
}
