import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import '../../agent/control_agent.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../../model/main_model.dart';
import '../../agent/resx_controller.dart';

class HomePage extends StatelessWidget {
  final ResxController resxController = ResxController();
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    model.init(context);
    return _getWidget(context);
  }

  Widget _getWidget(BuildContext context) {
    if (model.stateData["mainWidget"] == null) {
      return FutureBuilder<String>(
          future: model.getJson(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) debugPrint(snapshot.error.toString());

            return snapshot.hasData
                ? _getBodyUi(model, snapshot.data!)
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          });
    }
    model.addCount();
    debugPrint("Non-future call count: " + model.count.toString());
    return model.stateData["mainWidget"];
  }

  Widget _getBodyUi(MainModel model, String jsonStr) {
    debugPrint("Decoding jsonStr!!");
    var map = json.decode(jsonStr);
    model.stateData["map"] = map;
    model.addCount();
    model.appActions = AgentActions();
    Agent a = model.appActions.getAgent("pattern");

    ProcessEvent event = ProcessEvent("mainView");
    var p = a.process(event);

    debugPrint("Future call count: " + model.count.toString());
    Widget w = (p is ProcessPattern) ? p.getWidget() : p;
    model.stateData["mainWidget"] = w;
    return w;
  }
}
