import 'package:flutter/material.dart';

abstract class ProcessPattern {
  final Map<String, dynamic> map;
  ProcessPattern(this.map);
  Widget getWidget({String name});
}

abstract class Agent {
  dynamic process(ProcessEvent event);
}

abstract class Mvc {
  Map<String, dynamic> map;
  Mvc(this.map);
  init();
  reset(bool startNew);
  retry();
  String doAction(String action, Map<String, dynamic> emap);
  ProcessPattern getPattern();
  dynamic getAnswer();
  double getBgHeight();
}

class ProcessEvent {
  final String name;
  Map<String, dynamic> map;

  ProcessEvent(this.name, {this.map});
}

abstract class AppActions {
  Function getFunction(String name);
  dynamic doFunction(String name, dynamic input, Map<String, dynamic> vars);
  Function getPattern(String name);
  Agent getAgent(String name);
  dynamic getResource(String res, String spec);
}

Widget getPatternWidget(dynamic e) {
  return (e is ProcessPattern)
      ? e.getWidget()
      : (e is Widget)
          ? e
          : null;
}

List<Widget> getPatternWidgetList(List<dynamic> ml) {
  List<Widget> lw = (ml is List<Widget>) ? ml : [];
  for (dynamic e in ml) {
    Widget w = (e is ProcessPattern)
        ? e.getWidget()
        : (e is Widget)
            ? e
            : null;
    if (w != null) {
      lw.add(w);
    }
  }
  return lw;
}
