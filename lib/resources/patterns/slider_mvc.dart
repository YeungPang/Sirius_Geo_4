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
  late Map<String, dynamic> smap;

  @override
  double getBgHeight() {
    double? r = map["_bgHeight"];
    return (r == null) ? bgHeight : r * model.scaleHeight;
  }

  @override
  init() {
    configAgent ??= map["_configAgent"];
    if (refresh) {
      excl = [];
    }
    isVert = (map["_scale3"] == null) && (map["_scale"] == null);
    sliderNoti = ValueNotifier<int>(0);
    map["_sliderNoti"] = sliderNoti;
    String answer = map["_Answer"].toString();
    if (answer.contains("_ans")) {
      options =
          configAgent!.getElement(map["_AnswerOptions"], map, rowList: rowList);
      List<dynamic>? addOptions =
          configAgent!.getElement(map["_AddOptions"], map);
      if ((addOptions != null) && (addOptions.isNotEmpty)) {
        options.addAll(addOptions);
      }
      if (options.isEmpty) {
        return;
      }
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
      smap = getSMap(map);
      ProcessPattern pp = pf(smap);
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
      smap = getSMap(map);
      map["_colElem"] = pf(smap);
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
          int top1 = smap["_scale1Top"];
          int bottom1 = smap["_scale1Bottom"];
          int top2 = smap["_scale2Top"];
          int bottom2 = smap["_scale2Bottom"];
          int des = 0;
          int per = 0;
          String ansType = smap["_ansType"];
          int ans1;
          int ans2;
          if (ansType == smap["_scale1"]) {
            ans1 = smap["_Answer"];
            //configAgent!.getElement(smap["_Answer"], map);
            ans2 = ((ans1 - top1) * (bottom2 - top2) / (bottom1 - top1) + top2)
                .toInt();
            int in1 = mvmap["_in1"]!;
            des = ans1 - in1;
            per = (des * 100 ~/ (bottom1 - top1)).abs();
          } else {
            ans2 = smap["_Answer"];
            //configAgent!.getElement(smap["_Answer"], map);
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
            buildSliderResult(smap);
            map["_addRes"] = mvmap["_res"];
          } else {
            map["_subTitle"] = subTitle.replaceFirst("#A%#", per.toString());
            if (per <= smap["_almostPer"]) {
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
          num n = smap[_scale1];
          double ans1 = n.toDouble();
          mvmap["_ans1"] = ans1;
          if (_scale1 == "_scale1") {
            mvmap["_ans2"] = smap["_scale2"];
            mvmap["_ans3"] = smap["_scale3"];
          }
          double per = ((ans1 - mvmap["_in1"]) / ans1 * 100.00).abs();
          n = smap["_corrPer"];
          double corrPer = n.toDouble();
          map["_subTitle"] =
              subTitle.replaceFirst("#A%#", per.toStringAsFixed(2));
          if (per <= corrPer) {
            r = "correct";
            mvmap["_resStatus"] = "g";
            sliderNoti.value = 1;
          } else if (per <= smap["_almostPer"]) {
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
          buildSliderResult(smap);
        }
        map["_addRes"] = mvmap["_res"];

        break;
      case "TryAgain":
        mvmap["_state"] = "start";
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

  Map<String, dynamic> getSMap(Map<String, dynamic> _map) {
    Map<String, dynamic> _smap = {};
    _map.forEach((key, value) {
      if ((value is String) &&
          ((value.contains('ℛ')) || (value.contains('#')))) {
        if (value.contains('#')) {
          _smap[key] = configAgent!.checkText(key, _map);
        } else {
          _smap[key] = configAgent!.getElement(key, _map);
        }
      } else {
        _smap[key] = value;
      }
    });
    return _smap;
  }
}
