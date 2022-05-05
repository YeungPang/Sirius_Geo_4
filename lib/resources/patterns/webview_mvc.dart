import 'package:flutter/material.dart';
import '../../agent/config_agent.dart';
import '../../builder/get_pattern.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../app_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewMvc extends Mvc {
  WebViewMvc(Map<String, dynamic> map) : super(map);

  double bgHeight = 0.4926 * model.scaleHeight;
  late ProcessPattern view;
  //ProcessPattern proInd;
  ConfigAgent? configAgent;
  Map<String, dynamic> imap = {};
  Map<String, dynamic> mvmap = {};

  @override
  double getBgHeight() {
    return bgHeight;
  }

  @override
  init() {
    configAgent ??= map["_configAgent"];
    String url = map["_url"];
    mvmap = {};
    imap = {"_url": url, "_mv": mvmap};
    if (map["_scriptEnable"]) {
      imap["_scriptMode"] = JavascriptMode.unrestricted;
    }
    Function pf = getPrimePattern["WebView"]!;
    ProcessPattern pp = pf(imap);
    imap = {
      "_height": 0.7 * model.scaleHeight,
      "_width": model.scaleWidth,
      "_child": pp
    };
    pf = getPrimePattern["SizedBox"]!;
    pp = pf(imap);
    double bh = 0.04926 * model.scaleHeight;
    double bw = 0.32 * model.scaleWidth;
    List<dynamic> sl = [pp, getTapItemElemPattern("gameDone", bh, bw, "blue")];
    imap = {
      "_crossAxisAlignment": CrossAxisAlignment.center,
      "_mainAxisAlignment": MainAxisAlignment.spaceAround,
      "_mainAxisSize": MainAxisSize.max,
      "_children": sl,
    };
    pf = getPrimePattern["Column"]!;
    imap["_child"] = pf(imap);
    pf = getPrimePattern["ScrollLayout"]!;
    view = pf(imap);
  }

  @override
  reset(bool startNew) {}

  @override
  String doAction(String action, Map<String, dynamic>? emap) {
/*     switch (action) {
      case "GameDone":
        map["_scoreMark"] = true;
        break;
      default:
        break;
    } */
    return action;
  }

  @override
  ProcessPattern getPattern() {
    return view;
    //return map["_colElem"];
  }

  @override
  dynamic getAnswer() {
    return null;
  }

  @override
  retry() {}

  @override
  int getHintIndex() {
    return 0;
  }
}
