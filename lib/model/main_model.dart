import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../agent/version_agent.dart';
import '../builder/pattern.dart';
import '../instance_manager.dart';

class MainModel {
  final String mainModelName = "models/geo.json";

  double screenHeight = 812.0;
  double screenWidth = 375.0;
  late double appBarHeight;

  late double fontScale;
  late double sizeScale;
  late double scaleHeight;
  late double scaleWidth;
  late double size5;
  late double size10;
  late double size20;

  final apkVersion = "0.14";

  late AppActions appActions;

  BuildContext? context;

  Map<String, dynamic> stateData = {};
  Map<String, dynamic> map = {};

  List<List<dynamic>> stack = [];

  int _count = 0;

  int get count => _count;

  final VersionAgent versionAgent = VersionAgent();

  addCount() {
    _count++;
  }

  Future<String> getJson(BuildContext context) async {
    final httpAssetFuture = InstanceManager().assetRequest(mainModelName);
    // NB: We can't use response.body below because it uses response charset (which we don't return) defaulting to latin1.
    return httpAssetFuture
        .timeout(const Duration(seconds: 5))
        .then((response) => utf8.decode(response.bodyBytes))
        .then((String jsonStr) =>
            InstanceManager().decryptTransparentAsset(jsonStr));
  }

  Future<Map<String, dynamic>> getMap(BuildContext context) async {
    String jsonStr = "";
    try {
      jsonStr = await getJson(context);
    } on TimeoutException catch (_) {
      jsonStr = "";
    } catch (ex) {
      rethrow;
    }
    stateData["map"] = await versionAgent.getMap(jsonStr);
    map = stateData["map"];
    Map<String, dynamic> facts = map["patterns"]["facts"];
    facts["apkVersion"] = apkVersion;
    return map;
  }

  init(BuildContext context) {
    stateData.addAll({"cache": {}, "logical": {}, "user": {}});
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    double sr = screenWidth / screenHeight;
    scaleHeight = 683.42857;
    scaleWidth = 411.42857;
    double scr = scaleWidth / scaleHeight;
    double r = ((sr - scr) / scr).abs();
    if ((sr < scr) && (scaleHeight < screenHeight)) {
      sizeScale = screenWidth / scaleWidth;
      scaleHeight = screenHeight;
      scaleWidth = screenWidth;
    } else if (r <= 0.1) {
      sizeScale = screenHeight / scaleHeight;
      scaleHeight = screenHeight;
      scaleWidth = screenHeight * scr;
    } else {
      if (screenWidth >= scaleWidth) {
        if (screenHeight > scaleHeight) {
          sizeScale = screenHeight / scaleHeight;
          scaleWidth = screenHeight * scr;
          scaleHeight = screenHeight;
        } else {
          double sh = scaleHeight * 2.0 / 3.0;
          if (screenHeight >= sh) {
            sizeScale = 1.0;
          } else {
            sizeScale = screenHeight / scaleHeight;
            scaleHeight = screenHeight * 3.0 / 2.0;
            scaleWidth = scaleHeight * scr;
          }
        }
      } else {
        sizeScale = screenWidth / scaleWidth;
        scaleWidth = screenWidth;
        scaleHeight = scaleWidth / scr;
      }
    }
    fontScale = sizeScale;
    appBarHeight = scaleHeight * 0.9 / 10.6;
    debugPrint("Screen width: " + screenWidth.toString());
    debugPrint("Screen height: " + screenHeight.toString());
    debugPrint("Scale width: " + scaleWidth.toString());
    debugPrint("Scale height: " + scaleHeight.toString());

    size5 = 5.0 * sizeScale;
    size10 = 10.0 * sizeScale;
    size20 = 20.0 * sizeScale;
  }
}
