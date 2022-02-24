import 'package:flutter/material.dart';
import 'package:sirius_geo_4/agent/config_agent.dart';
import 'package:sirius_geo_4/builder/get_pattern.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/resources/basic_resources.dart';
import 'package:sirius_geo_4/resources/patterns/vslider_pattern.dart';

class SliderMvc extends Mvc {
  SliderMvc(Map<String, dynamic> map) : super(map);

  double bgHeight = 0.4926 * model.screenHeight;
  ProcessPattern view;
  ConfigAgent configAgent;
  ValueNotifier<int> sliderNoti;
  Map<String, dynamic> imap;
  Map<String, dynamic> mvmap;
  List<int> excl = [];
  List<dynamic> options;
  int ans;
  bool isVert;
  bool refresh = true;
  List<int> rowList = [];

  @override
  double getBgHeight() {
    return bgHeight;
  }

  @override
  init() {
    configAgent ??= map["_configAgent"];
    options =
        configAgent.getElement(map["_AnswerOptions"], map, rowList: rowList);
    if ((options == null) || (options.isEmpty)) {
      return;
    }
    if (refresh) {
      excl = [];
    }
    isVert = map["_scale3"] == null;
    sliderNoti = ValueNotifier<int>(0);
    map["_sliderNoti"] = sliderNoti;
    String answer = map["_Answer"];
    if (answer.contains("_ans")) {
      ans = getRandom(options.length, excl);
      excl.add(ans);
    }
    map["_ans"] = rowList.isNotEmpty ? rowList[ans] : ans;
    // String question = configAgent.checkText("_Question", map);
    // map["_question"] = question;
    setup();
  }

  setup() {
    Function pf;
    if (isVert) {
      double h = 0.591133 * model.screenHeight;
      double w = 0.84 * model.screenWidth;
      mvmap = {
        "_state": map["_state"],
        "_scaleNoti": ValueNotifier<double>(50.0),
        "_height": h,
        "_width": w
      };
      map["_mv"] = mvmap;
      pf = model.appActions.getPattern("VertSlider");
      ProcessPattern pp = pf(map);
      imap = {
        "_margin": catIconPadding,
        "_height": mvmap["_height"],
        "_width": mvmap["_width"],
        "_alignment": Alignment.center,
        "_child": pp
      };
      pf = getPrimePattern["Container"];
      pp = pf(imap);
      imap = {
        "_height": mvmap["_height"],
        "_width": mvmap["_width"],
        "_color": Colors.white,
        "_alignment": Alignment.centerLeft,
        "_btnBRadius": 18.0,
        "_child": pp
      };
      pf = getPrimePattern["ColorButton"];
      pp = pf(imap);
      imap = {
        "_height": 0.6157635 * model.screenHeight,
        "_width": 0.88 * model.screenWidth,
        "_beginColor": colorMap["btnBlue"],
        "_endColor": colorMap["btnBlueGradEnd"],
        "_alignment": Alignment.center,
        "_btnBRadius": 20.0,
        "_child": pp
      };
      map["_colElem"] = pf(imap);
    } else {
      mvmap = {"_state": map["_state"]};
      map["_mv"] = mvmap;
      pf = model.appActions.getPattern("ThreeSlider");
      map["_colElem"] = pf(map);
    }
    pf = model.appActions.getPattern("MvcColumn");
    view = pf(map);
  }

  @override
  reset(bool startNew) {
    refresh = startNew;
    init();
  }

  @override
  String doAction(String action, Map<String, dynamic> emap) {
    switch (action) {
      case "CheckAns":
        String r;
        map["_state"] = "confirmed";
        String subTitle = model.map["text"]["accuracy"];
        if (isVert) {
          int top1 = map["_scale1Top"];
          int bottom1 = map["_scale1Bottom"];
          int top2 = map["_scale2Top"];
          int bottom2 = map["_scale2Bottom"];
          int des = 0;
          int per = 0;
          String ansType = map["_ansType"];
          int ans1;
          int ans2;
          if (ansType == map["_scale1"]) {
            ans1 = configAgent.getElement(map["_Answer"], map);
            ans2 = ((ans1 - top1) * (bottom2 - top2) / (bottom1 - top1) + top2)
                .toInt();
            des = ans1 - mvmap["_in1"];
            per = (des * 100 ~/ (bottom1 - top1)).abs();
          } else {
            ans2 = configAgent.getElement(map["_Answer"], map);
            ans1 = ((ans2 - top2) * (bottom1 - top1) / (bottom2 - top2) + top1)
                .toInt();
            des = ans2 - mvmap["_in2"];
            per = (des * 100 ~/ (bottom2 - top2)).abs();
          }
          mvmap["_ans1"] = ans1;
          mvmap["_ans2"] = ans2;
          if (des == 0) {
            mvmap["_resStatus"] = "g";
            sliderNoti.value = 1;
            r = "correct";
            buildSliderResult(map);
            map["_addRes"] = mvmap["_res"];
          } else {
            map["_subTitle"] = subTitle.replaceFirst("#A%#", per.toString());
            if (per <= map["_almostPer"]) {
              mvmap["_resStatus"] = "o";
              sliderNoti.value = 2;
              r = "almost";
            } else {
              r = "incorrect";
              mvmap["_resStatus"] = "r";
              sliderNoti.value = 2;
            }
          }
        } else {
          double ans1 = configAgent.getElement(map["_scale1"], map);
          mvmap["_ans1"] = ans1;
          mvmap["_ans2"] = configAgent.getElement(map["_scale2"], map);
          mvmap["_ans3"] = configAgent.getElement(map["_scale3"], map);
          double per = ((ans1 - mvmap["_in1"]) / ans1 * 100.00).abs();
          double corrPer = map["_corrPer"];
          map["_subTitle"] =
              subTitle.replaceFirst("#A%#", per.toStringAsFixed(2));
          if (per <= corrPer) {
            r = "correct";
            mvmap["_resStatus"] = "g";
            sliderNoti.value = 1;
          } else if (per <= map["_almostPer"]) {
            r = "almost";
            mvmap["_resStatus"] = "o";
            sliderNoti.value = 2;
          } else {
            r = "incorrect";
            mvmap["_resStatus"] = "r";
            sliderNoti.value = 2;
          }
        }
        return r;
      case "ShowAnswer":
        sliderNoti.value = 1;
        if (isVert) {
          buildSliderResult(map);
        }
        map["_addRes"] = mvmap["_res"];

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
    ProcessPattern v = view;
    sliderNoti.value = 0;
    setup();
    ValueNotifier<List<dynamic>> stackNoti = map["_stackNoti"];
    List<dynamic> stackList = stackNoti.value;
    for (int i = 0; i < stackList.length; i++) {
      if (stackList[i] == v) {
        stackList[i] = view;
        break;
      }
    }
  }

  @override
  int getHintIndex() {
    return ans;
  }
}
