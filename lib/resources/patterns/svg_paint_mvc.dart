import 'package:flutter/material.dart';
import '../../agent/config_agent.dart';
import '../../builder/get_pattern.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../basic_resources.dart';
import '../../builder/svg_paint_pattern.dart';

class SvgPaintMvc extends Mvc {
  SvgPaintMvc(Map<String, dynamic> map) : super(map);

  double bgHeight = 0.4926 * model.scaleHeight;
  late ProcessPattern view;
  ProcessPattern? proInd;
  ConfigAgent? configAgent;
  late Function mvcpf;
  late ValueNotifier<ProcessPattern> childNoti;
  late ValueNotifier<Offset> svgPaintNoti;
  Map<String, dynamic> imap = {};
  Map<String, dynamic> mvmap = {};
  List<int> excl = [];
  List<dynamic> options = [];
  int ans = 0;
  bool refresh = true;
  String ansLabel = "";
  List<int> rowList = [];

  @override
  double getBgHeight() {
    return bgHeight;
  }

  @override
  init() {
    configAgent ??= map["_configAgent"];
    options =
        configAgent!.getElement(map["_AnswerOptions"], map, rowList: rowList);
    if (options.isEmpty) {
      return;
    }
    if (refresh) {
      excl = [];
    }
    String answer = map["_Answer"];
    if (answer.contains("_ans")) {
      ans = getRandom(options.length, excl)!;
      excl.add(ans);
    }
    map["_ans"] = rowList.isNotEmpty ? rowList[ans] : ans;
    // String question = configAgent!.checkText("_Question", map);
    // map["_question"] = question;
    ansLabel = configAgent!.getElement(map["_Answer"], map);
    if (refresh) {
      imap = {
        "_height": 40.0 * sizeScale,
        "_width": 40.0 * sizeScale,
        "_child": const CircularProgressIndicator(),
      };
      Function pf = getPrimePattern["SizedBox"]!;
      ProcessPattern pp = pf(imap);
      imap = {
        "_margin":
            EdgeInsets.only(left: 160.0 * sizeScale, top: 215.0 * sizeScale),
        "_alignment": const Alignment(-1.0, -1.0),
        "_child": pp
      };
      pf = getPrimePattern["Container"]!;
      proInd = pf(imap);
      mvmap = {};
      map["_mv"] = mvmap;
      initSvgPainter(map);

      mvmap["_state"] = map["_state"];
      svgPaintNoti = ValueNotifier<Offset>(Offset.zero);
      mvmap["_svgPaintNoti"] = svgPaintNoti;

      childNoti = ValueNotifier<ProcessPattern>(proInd!);
      imap = {
        "_height": map["_painterHeight"],
        "_width": map["_painterWidth"],
        "_childNoti": childNoti
      };
      map["_childNoti"] = childNoti;
      pf = getPrimePattern["ValueChildContainer"]!;
      pp = pf(imap);
      imap = {"_child": pp};
      pf = getPrimePattern["InteractiveViewer"]!;
      pp = pf(imap);
      imap = {
        "_height": 0.66502463 * model.scaleHeight,
        "_width": 0.82666667 * model.scaleHeight,
        "_alignment": Alignment.center,
        "_decoration": shadowRCDecoration,
        "_child": pp
      };
      pf = getPrimePattern["Container"]!;
      map["_colElem"] = pf(imap);
      mvcpf = model.appActions.getPattern("MvcColumn")!;
      view = mvcpf(map);
      map["_func"] = "getSvgMap";
      loadData(map);
    } else {
      mvmap["_ansLabel"] = null;
      mvmap["_state"] = map["_state"];
      mvmap["_selIndex"] = null;
      mvmap["_selLabel"] = null;
      view = mvcpf(map);
      svgPaintNoti.value = Offset.zero;
    }
  }

  @override
  reset(bool startNew) {
    refresh = startNew;
    init();
  }

  @override
  String doAction(String action, Map<String, dynamic>? emap) {
    switch (action) {
      case "CheckAns":
        String r;
        map["_state"] = "confirmed";
        if (ansLabel == mvmap["_selLabel"]) {
          r = "correct";
          mvmap["_ansLabel"] = ansLabel;
          svgPaintNoti.value = Offset.zero;
        } else {
          r = "incorrect";
        }
        return r;
      case "ShowAnswer":
        mvmap["_ansLabel"] = ansLabel;
        svgPaintNoti.value = Offset.zero;
        break;
      default:
        break;
    }
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
  retry() {
    mvmap["_state"] = map["_state"];
    mvmap["_selIndex"] = null;
    mvmap["_selLabel"] = null;
    svgPaintNoti.value = Offset.zero;
  }

  @override
  int getHintIndex() {
    return ans;
  }
}
