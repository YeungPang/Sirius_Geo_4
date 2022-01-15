import 'package:flutter/material.dart';
import 'package:sirius_geo_4/agent/control_agent.dart';
import 'package:sirius_geo_4/builder/pattern.dart';

class MainModel {
  final String mainModelName = "assets/models/geo.json";

  double screenHeight = 812.0;
  double screenWidth = 375.0;

  AppActions appActions;

  BuildContext context;
  Map<String, dynamic> stateData = {};
  Map<String, dynamic> get map => stateData["map"];

  ValueNotifier<String> progNoti = ValueNotifier<String>("Ø");
  ValueNotifier<List<String>> groupNoti = ValueNotifier<List<String>>([]);
  ValueNotifier<List<Widget>> mvcStackNoti;

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
    // Map<String, dynamic> map = stateData["map"];
    // List<dynamic> ld = map["userProfile"]["progress"];
    // List<int> li = (ld == null) ? null : ld.map<int>((e) => e as int).toList();
    // progNoti = ValueNotifier<List<int>>(li);
    // stateData["progNoti"] = progNoti;
    appActions = AgentActions();
  }
}
