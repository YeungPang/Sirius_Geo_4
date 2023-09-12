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
        GetPage(name: "/login", page: () => LoginPage()),
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
    var p = a.process(event);

    if (p is ProcessPattern) {
      screen = p.getWidget();
    } else {
      screen = p as Widget;
    }
    return screen;
  }

  static Future<InitializationStatus> initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }
}
