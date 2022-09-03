import 'package:flutter/material.dart';
import '../../agent/config_agent.dart';
import '../../builder/get_pattern.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../basic_resources.dart';
import '../patterns/vslider_pattern.dart';

class SliderMvc extends Mvc {
  SliderMvc(Map<String, dynamic> map) : super(map);

  double bgHeight = 0.4926 * model.scaleHeight;
  late ProcessPattern view;
  ConfigAgent? configAgent;
  late ValueNotifier<int> sliderNoti;
  Map<String, dynamic> imap = {};
  Map<String, dynamic> mvmap = {};
  List<int> excl = [];
  List<dynamic> options = [];
  int ans = 0;
  late bool isVert;
  bool refresh = true;
  List<int> rowList = [];
  String _scale1 = "_scale1";

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
    isVert = (map["_scale3"] == null) && (map["_scale"] == null);
    sliderNoti = ValueNotifier<int>(0);
    map["_sliderNoti"] = sliderNoti;
    String answer = map["_Answer"];
    if (answer.contains("_ans")) {
      ans = getRandom(options.length, excl)!;
      excl.add(ans);
    }
    map["_ans"] = rowList.isNotEmpty ? rowList[ans] : ans;
    // String question = configAgent!.checkText("_Question", map);
    // map["_question"] = question;
    setup();
  }

  setup() {
    Function pf;
    if (isVert) {
      double h = 0.591133 * model.scaleHeight;
      double w = 0.84 * model.scaleWidth;
      if (mvmap.isEmpty) {
        mvmap = {
          "_state": map["_state"],
          "_scaleNoti": ValueNotifier<double>(50.0),
          "_height": h,
          "_width": w
        };
        map["_mv"] = mvmap;
      } else {
        mvmap["_state"] = "start";
      }
      pf = model.appActions.getPattern("VertSlider")!;
      ProcessPattern pp = pf(map);
      imap = {
        "_margin": catIconPadding,
        "_height": mvmap["_height"],
        "_width": mvmap["_width"],
        "_alignment": Alignment.center,
        "_child": pp
      };
      pf = getPrimePattern["Container"]!;
      pp = pf(imap);
      imap = {
        "_height": mvmap["_height"],
        "_width": mvmap["_width"],
        "_color": Colors.white,
        "_alignment": Alignment.centerLeft,
        "_btnBRadius": 18.0 * sizeScale,
        "_child": pp
      };
      pf = getPrimePattern["ColorButton"]!;
      pp = pf(imap);
      imap = {
        "_height": 0.6157635 * model.scaleHeight,
        "_width": 0.88 * model.scaleWidth,
        "_beginColor": colorMap["btnBlue"],
        "_endColor": colorMap["btnBlueGradEnd"],
        "_alignment": Alignment.center,
        "_btnBRadius": size20,
        "_child": pp
      };
      map["_colElem"] = pf(imap);
    } else {
      if (mvmap.isEmpty) {
        mvmap = {"_state": map["_state"]};
        map["_mv"] = mvmap;
      }
      if (map["_scale"] == null) {
        pf = model.appActions.getPattern("ThreeSlider")!;
      } else {
        _scale1 = "_scale";
        pf = model.appActions.getPattern("Slider")!;
      }
      map["_colElem"] = pf(map);
    }
    pf = model.appActions.getPattern("MvcColumn")!;
    view = pf(map);
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
            ans1 = configAgent!.getElement(map["_Answer"], map);
            ans2 = ((ans1 - top1) * (bottom2 - top2) / (bottom1 - top1) + top2)
                .toInt();
            int in1 = mvmap["_in1"]!;
            des = ans1 - in1;
            per = (des * 100 ~/ (bottom1 - top1)).abs();
          } else {
            ans2 = configAgent!.getElement(map["_Answer"], map);
            ans1 = ((ans2 - top2) * (bottom1 - top1) / (bottom2 - top2) + top1)
                .toInt();
            int in2 = mvmap["_in2"]!;
            des = ans2 - in2;
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
          double ans1 = configAgent!.getElement(map[_scale1], map);
          mvmap["_ans1"] = ans1;
          if (_scale1 == "_scale1") {
            mvmap["_ans2"] = configAgent!.getElement(map["_scale2"], map);
            mvmap["_ans3"] = configAgent!.getElement(map["_scale3"], map);
          }
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
  }

  @override
  int getHintIndex() {
    return ans;
  }
}
