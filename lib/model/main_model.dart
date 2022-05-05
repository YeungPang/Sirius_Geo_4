import 'package:flutter/material.dart';
import '../builder/pattern.dart';

class MainModel {
  final String mainModelName = "assets/models/geo.json";

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

  late AppActions appActions;

  BuildContext? context;

  Map<String, dynamic> stateData = {};
  Map<String, dynamic> get map => stateData["map"];

  List<List<dynamic>> stack = [];

  int _count = 0;

  int get count => _count;

  addCount() {
    _count++;
  }

  Future<String> getJson(BuildContext context) {
    return DefaultAssetBundle.of(context).loadString(mainModelName);
  }

  init() {
    stateData.addAll({"cache": {}, "logical": {}, "user": {}});
    //appActions = AgentActions();
    size5 = 5.0 * sizeScale;
    size10 = 10.0 * sizeScale;
    size20 = 20.0 * sizeScale;
  }
}
