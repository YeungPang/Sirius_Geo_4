import 'package:flutter/material.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/ui/views/home_page.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

const homePageRoute = '/';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: _routes(),
    );
  }

  RouteFactory _routes() {
    return (settings) {
      final Map<String, dynamic> arguments = settings.arguments;
      Widget screen;
      if (settings.name == homePageRoute) {
        screen = HomePage();
      } else {
        Map<String, dynamic> map = arguments['map'];
        Agent a = model.appActions.getAgent("pattern");

        ProcessEvent event = ProcessEvent(settings.name, map: map);
        var p = a.process(event);

        if (p is ProcessPattern) {
          screen = p.getWidget();
        } else if (p is Widget) {
          screen = p;
        }
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}
