import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/model/main_model.dart';
import 'package:sirius_geo_4/agent/resx_controller.dart';

class HomePage extends StatelessWidget {
  final ResxController resxController = ResxController();
  HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    model.screenHeight = MediaQuery.of(context).size.height;
    model.screenWidth = MediaQuery.of(context).size.width;
    print("Screen width: " + model.screenWidth.toString());
    print("Screen height: " + model.screenHeight.toString());
/*     return BaseView<MainModel>(
        builder: (context, child, model) => BusyOverlay(
            show: model.state == ViewState.busy,
            child: _getWidget(context, model))); */
    return _getWidget(context);
  }

  Widget _getWidget(BuildContext context) {
    if (model.stateData["mainWidget"] == null) {
      return FutureBuilder<String>(
          future: model.getJson(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? _getBodyUi(model, snapshot.data)
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          });
    }
    model.addCount();
    print("Non-future call count: " + model.count.toString());
    return model.stateData["mainWidget"];
  }

  Widget _getBodyUi(MainModel model, String jsonStr) {
    print("Decoding jsonStr!!");
    var map = json.decode(jsonStr);
    model.stateData["map"] = map;
    model.addCount();
    model.init();
    Agent a = model.appActions.getAgent("pattern");

    ProcessEvent event = ProcessEvent("mainView");
    var p = a.process(event);

    print("Future call count: " + model.count.toString());
    Widget w = (p is ProcessPattern) ? p.getWidget() : p;
    model.stateData["mainWidget"] = w;
    return w;
  }
}
