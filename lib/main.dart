import 'package:flutter/material.dart';
import './/agent/resx_controller.dart';
import './/builder/pattern.dart';
import './/model/main_model.dart';
import './/ui/views/home_page.dart';
import 'package:get/get.dart';
import './/ui/views/login_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MyApp.initGoogleMobileAds();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    MainModel model = Get.put(MainModel());
    Get.put(ResxController());
    return GetMaterialApp(
      getPages: [
        GetPage(name: "/login", page: () => const LoginPage()),
        GetPage(name: "/home", page: () => HomePage()),
        GetPage(name: "/page", page: () => _getPage(model)),
      ],
      initialRoute: "/login",
      //onGenerateRoute: _routes(),
    );
  }

  Widget _getPage(MainModel model) {
    Widget screen;
    Map<String, dynamic>? map = Get.arguments;
    Agent a = model.appActions.getAgent("pattern");

    ProcessEvent event = ProcessEvent(Get.parameters["screen"]!, map: map);

    var itemRefMap = (event.map != null) ? event.map!["_itemRefMap"] : null;
    var p = ((model.jFiles.isNotEmpty) || (itemRefMap is String))
        ? null
        : a.process(event);

/*     if (itemRefMap is String) {
      return _repeatGetPage(model, a, event);
    } */

    if (p is ProcessPattern) {
      screen = p.getWidget();
    } else if (p is Widget) {
      screen = p;
    } else {
      screen = FutureBuilder<bool>(
          future: model.loadJFile(),
          builder: (context, snapshot) {
            if (snapshot.hasError) debugPrint(snapshot.error.toString());

            return snapshot.hasData
                ? (snapshot.data!
                    ? _repeatGetPage(model, a, event)
                    : model.stateData["mainWidget"])
                // : const Center(
                //     child: CircularProgressIndicator(),
                //   );
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          });
    }
    model.setCurrScreen(screen);
    return screen;
  }

  Widget _repeatGetPage(MainModel model, Agent a, ProcessEvent event) {
    var itemRefMap = (event.map != null) ? event.map!["_itemRefMap"] : null;
    if (itemRefMap is String) {
      itemRefMap = model.map["patterns"]["facts"][itemRefMap];
      if (itemRefMap != null) {
        event.map!["_itemRefMap"] = itemRefMap;
        var item = event.map!["_item"];
        var dataRefMap = event.map!["_dataRefMap"];
        event.map!["_itemRef"] =
            model.appActions.doFunction("dataList", [dataRefMap, item], null);
      }
    }
    var p = a.process(event);
    Widget screen;
    if (p is ProcessPattern) {
      screen = p.getWidget();
      model.setCurrScreen(screen);
    } else if (p is Widget) {
      screen = p;
      model.setCurrScreen(screen);
    } else {
      screen = model.currentScreen!;
    }
    return screen;
  }

  static Future<InitializationStatus> initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }
}
