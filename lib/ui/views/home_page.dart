import 'dart:core';
import 'package:flutter/material.dart';
import '../../agent/control_agent.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../../model/main_model.dart';
import '../../agent/resx_controller.dart';
import '../../resources/basic_resources.dart';

class HomePage extends StatelessWidget {
  final ResxController resxController = ResxController();
  HomePage({Key? key}) : super(key: key);
  late Widget splashW;

  @override
  Widget build(BuildContext context) {
    if (model.stateData["mainWidget"] != null) {
      return _getWidget(context);
    }
    model.init(context);
    splashW = SingleChildScrollView(
        child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/SCircles.png"),
                  fit: BoxFit.cover,
                ),
                gradient: blueGradient),
            height: model.screenHeight,
            width: model.screenWidth,
            alignment: Alignment.center,
            child: SizedBox(
              height: 0.7 * model.screenHeight,
              width: 0.7 * model.screenWidth,
              child: Column(
                children: [
                  Image.asset("assets/images/LogoGlobe.png"),
                  Image.asset("assets/images/SiriusGeoText.png"),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            )));
    return _getWidget(context);
  }

  Widget _getWidget(BuildContext context) {
    if (model.stateData["mainWidget"] != null) {
      model.addCount();
      debugPrint("Non-future call count: " + model.count.toString());
      return model.stateData["mainWidget"];
    }
    return FutureBuilder<Map<String, dynamic>>(
        future: model.getMap(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) debugPrint(snapshot.error.toString());

          return snapshot.hasData
              ? _getBodyUi(model, snapshot.data!)
              // : const Center(
              //     child: CircularProgressIndicator(),
              //   );
              : splashW;
        });
  }

  Widget _getBodyUi(MainModel model, Map<String, dynamic> map) {
    model.addCount();
    model.appActions = AgentActions();
    Agent a = model.appActions.getAgent("pattern");

    ProcessEvent event = ProcessEvent("mainView");
    var p = a.process(event);

    debugPrint("Future call count: " + model.count.toString());
    Widget w = (p is ProcessPattern) ? p.getWidget() : p;
    model.stateData["mainWidget"] = w;
    model.setCurrScreen(w);
    return w;
  }
}
