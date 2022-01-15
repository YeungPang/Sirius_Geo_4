import 'package:flutter/material.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/builder/get_pattern.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/resources/patterns/app_pattern.dart';
import 'package:sirius_geo_4/resources/patterns/game_complete.dart';
import 'package:sirius_geo_4/resources/patterns/main_menu.dart';
import 'package:sirius_geo_4/resources/patterns/mc_mvc.dart';
import 'package:sirius_geo_4/resources/basic_resources.dart';
import 'package:sirius_geo_4/resources/fonts.dart';
import 'package:sirius_geo_4/agent/config_agent.dart';
import 'package:sirius_geo_4/resources/patterns/order_mvc.dart';
import 'package:sirius_geo_4/resources/patterns/sentence_mvc.dart';
import 'package:sirius_geo_4/resources/patterns/slider_3_pattern.dart';
import 'package:sirius_geo_4/resources/patterns/slider_mvc.dart';
import 'package:sirius_geo_4/resources/patterns/svg_paint_mvc.dart';
import 'package:sirius_geo_4/builder/svg_paint_pattern.dart';
import 'package:sirius_geo_4/resources/patterns/text_mvc.dart';
import 'package:sirius_geo_4/resources/patterns/vslider_pattern.dart';
import 'package:sirius_geo_4/resources/patterns/webview_mvc.dart';

ProcessPattern getTopicPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_height",
    "_width",
    "_decoration",
    "_topicSelection",
    "_knowYourWorld"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return TopicPattern(map);
}

ProcessPattern getGameCompletePattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_height",
    "_width",
    "_gameCompleteList",
    "_shareIcon",
    "_shareHeight"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return GameCompletePattern(map);
}

ProcessPattern getGameItemPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_name",
    "_height",
    "_width",
    "_text",
    "_points",
    "_color",
    "_alignment",
    "_shareIcon",
    "_shareHeight"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return GameItemPattern(map);
}

ProcessPattern getItemElemPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_item",
    "_index",
    "_eventMap",
    "_height",
    "_width",
    "_decoration",
    "_alignment",
    "_textStyle",
    "_beginColor",
    "_endColor",
    "_badgeContext"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  var item = map["_item"];
  int index = map["_index"];
  Map<String, dynamic> eventMap = map["_eventMap"];
  if (eventMap != null) {
    eventMap["_item"] = item;
    eventMap["_index"] = index;
  }
  if (item is String) {
    Function pf;
    if (item.contains("png") || item.contains("svg")) {
      map["_name"] = item;
      if (item.contains("svg")) {
        pf = getPrimePattern["SVGAsset"];
      } else {
        pf = getPrimePattern["ImageAsset"];
      }
    } else {
      pf = getPrimePattern["Text"];
      map["_text"] = item;
    }
    map["_child"] = pf(map);
  }
  Function cf = (map["_beginColor"] != null)
      ? getPrimePattern["ColorButton"]
      : getPrimePattern["Container"];
  ProcessPattern cp = cf(map);
  if (map["_badgeContext"] != null) {
    map["_child"] = cp;
    cf = getPrimePattern["Badge"];
    cp = cf(map);
  }
  return cp;
}

ProcessPattern getMvcColumnPattern(Map<String, dynamic> map) {
  ConfigAgent configAgent = map["_configAgent"];
  List<dynamic> children = [];
  Function pf;
  Function cpf = getPrimePattern["Container"];
  ProcessPattern pp;
  Map<String, dynamic> iMap;
  String imgs = configAgent.getElement(map["_Q_Image"], map, null);
  if (imgs != null) {
    if (imgs.contains("svg")) {
      pf = getPrimePattern["SVGAsset"];
    } else {
      pf = getPrimePattern["ImageAsset"];
    }
    double height = 0.2685 * model.screenHeight;
    iMap = {
      "_name": imgs,
      "_height": height,
      "_boxFit": BoxFit.cover,
    };
    iMap["_child"] = pf(iMap);
    // iMap["_borderRadius"] = BorderRadius.circular(10);
    // pf = getPrimePattern["ClipRRect"];
    // iMap["_child"] = pf(iMap);
    // iMap["_alignment"] = Alignment.center;
    // iMap["_decoration"] = imageDecoration;
    // iMap["_boxConstraints"] =
    //     BoxConstraints.expand(width: double.infinity, height: height);
    pp = cpf(iMap);
    children.add(pp);
  }
  iMap = {
    "_text": map["_question"] ?? map["_Question"],
    "_textAlign": TextAlign.center,
    "_textStyle": questionTextStyle,
    "_alignment": Alignment.center,
  };
  pf = getPrimePattern["Text"];
  iMap["_child"] = pf(iMap);
  pp = cpf(iMap);
  children.add(pp);
  String instr = map["_Instruction"];
  if (instr != null) {
    iMap["_text"] = instr;
    iMap["_textStyle"] = resTxtStyle;
    iMap["_child"] = pf(iMap);
    pp = cpf(iMap);
    children.add(pp);
  }
  var colElem = map["_colElem"];
  if (colElem is List<dynamic>) {
    children.addAll(colElem);
  } else {
    children.add(colElem);
  }
  children.add(getConfirmPattern(map));
  iMap = {
    "_crossAxisAlignment": CrossAxisAlignment.center,
    "_mainAxisAlignment": MainAxisAlignment.spaceAround,
    "_mainAxisSize": MainAxisSize.max,
    "_children": children,
  };
  pf = getPrimePattern["Column"];
  iMap["_child"] = pf(iMap);
  pf = getPrimePattern["ScrollLayout"];
  return pf(iMap);
}

ProcessPattern getConfirmPattern(Map<String, dynamic> map) {
  Map<String, dynamic> text = model.map["text"];
  Map<String, dynamic> tapAction = {
    "_event": "confirm",
  };

  Map<String, dynamic> iMap = {
    "_item": text["confirm"],
    "_height": 0.07143 * model.screenHeight,
    "_width": 0.872 * model.screenWidth,
    "_alignment": Alignment.center,
    "_textStyle": controlButtonTextStyle,
    "_beginColor": colorMap["btnBlue"],
    "_endColor": colorMap["btnBlueGradEnd"],
    "_tapAction": tapAction,
  };
  iMap["_child"] = getItemElemPattern(iMap);
  Map<String, dynamic> eventMap = {"_item": text["confirm"]};
  ProcessEvent pe = ProcessEvent("fsm");
  pe.map = eventMap;
  iMap["_onTap"] = pe;
  Function pf = getPrimePattern["TapItem"];
  iMap["_child"] = pf(iMap);
  iMap["_notifier"] = createNotifier(0.5);
  map["_confirmNoti"] = iMap["_notifier"];
  pf = getPrimePattern["ValueOpacity"];
  return pf(iMap);
}

ProcessPattern getTapItemElemPattern(
    String event, double height, double width, var inspec) {
  Map<String, dynamic> tapAction = {
    "_event": event,
  };
  Map<String, dynamic> spec = (inspec is Map<String, dynamic>) ? inspec : {};
  tapAction.addAll(spec);
  if (inspec is String) {
    switch (inspec) {
      case "blue":
        spec = {
          "_textStyle": controlButtonTextStyle,
          "_beginColor": colorMap["btnBlue"],
          "_endColor": colorMap["btnBlueGradEnd"],
        };
        break;
      case "corr":
        spec = {
          "_textStyle": controlButtonTextStyle,
          "_beginColor": colorMap["correct"],
          "_endColor": colorMap["correctGradEnd"],
        };
        break;
      default:
        break;
    }
  }
  Map<String, dynamic> text = model.map["text"];
  Map<String, dynamic> iMap = {
    "_item": text[event],
    "_height": height,
    "_width": width,
    "_alignment": Alignment.center,
    "_tapAction": tapAction,
  };
  iMap.addAll(spec);
  iMap["_child"] = getItemElemPattern(iMap);
  Map<String, dynamic> eventMap = {"_item": text[event]};
  ProcessEvent pe = ProcessEvent("fsm");
  pe.map = eventMap;
  iMap["_onTap"] = pe;
  Function pf = getPrimePattern["TapItem"];
  return pf(iMap);
}

ProcessPattern getNotiElemPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_child",
    "_color",
    "_alignment",
    "_clipBehavior",
    "_boxConstraints",
    "_decoration",
    "_margin",
    "_padding",
    "_transform",
    "_width",
    "_height",
    "_progTotal",
    "_progId"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return NotiElemPattern(map);
}

buildBadgedElement(String type, List<dynamic> children,
    ValueNotifier<List<dynamic>> gvNoti, bool isImg, Map<String, dynamic> map) {
  BoxDecoration decoration;
  Color dc;
  bool incorr = type == "incorrect";
  String icon;
  switch (type) {
    case "correct":
      dc = colorMap["correct"];
      icon = "correct";
      break;
    case "incorrect":
      dc = colorMap["incorrect"];
      icon = "incorrect";
      break;
    case "answer":
      dc = colorMap["btnBlue"];
      icon = "correct";
      break;
    default:
      return null;
  }
  if (isImg || incorr) {
    decoration = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: dc, width: 2),
      borderRadius: BorderRadius.circular(10),
    );
  } else {
    decoration = BoxDecoration(
      color: dc,
      borderRadius: BorderRadius.circular(10),
    );
  }
  Map<String, dynamic> imap = {"_icon": icon, "_iconColor": dc};
  Function pf = getPrimePattern["Icon"];
  ProcessPattern pp = pf(imap);
  Map<String, dynamic> childMap = {
    "_alignment": Alignment.center,
    "_decoration": decoration,
    "_textStyle": incorr ? incorrTxtStyle : selButnTxtStyle,
    "_badgeContext": pp,
    "_badgeColor": Colors.white,
  };
  childMap.addAll(map);
  Function iepf = model.appActions.getPattern("ItemElem");
  pp = iepf(childMap);
  int ci = map["_childInx"];
  children[ci] = pp;
  if (gvNoti != null) {
    List<dynamic> c = [];
    c.addAll(children);
    gvNoti.value = c;
  }
}

ProcessPattern getThreeSliderPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_text1",
    "_text2",
    "_text3",
    "_suffix1",
    "_suffix2",
    "_suffix3",
    "_start1",
    "_start2",
    "_start3",
    "_end1",
    "_end2",
    "_end3",
    "_ratio12",
    "_ratio13",
    "_sliderNoti",
    "_mv"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ThreeSliderPattern(map);
}

ProcessPattern getVertSliderPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_scale1",
    "_scale2",
    "_largest",
    "_smallest",
    "_div",
    "_scale1Top",
    "_scale1Bottom",
    "_scale2Top",
    "_scale2Bottom",
    "_sliderNoti",
    "_stackNoti",
    "_mv"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return VertSliderPattern(map);
}

ProcessPattern getSvgPaintPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_boxWidth",
    "_boxHeight",
    "_ansColor",
    "_selColor",
    "_backgroundColor",
    "_borderColor",
    "_borderStroke",
    "_offsetWidth",
    "_offsetHeight",
    "_painterHeight",
    "_painterWidth",
    "_shapeColor",
    "_matchKey",
    "_shapes",
    "_mv"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return SvgPaintPattern(map);
}

const Map<String, Function> appPatterns = {
  "Topic": getTopicPattern,
  "ItemElem": getItemElemPattern,
  "TapItemElem": getTapItemElemPattern,
  "MvcColumn": getMvcColumnPattern,
  "Confirm": getConfirmPattern,
  "GameComplete": getGameCompletePattern,
  "GameItemPattern": getGameItemPattern,
  "NotiElem": getNotiElemPattern,
  "ThreeSlider": getThreeSliderPattern,
  "VertSlider": getVertSliderPattern,
};

Mvc getMcMvc(Map<String, dynamic> pmap) {
  return McMvc(pmap);
}

Mvc getTextMvc(Map<String, dynamic> pmap) {
  return TextMvc(pmap);
}

Mvc getSentenceMvc(Map<String, dynamic> pmap) {
  return SentenceMvc(pmap);
}

Mvc getOrderMvc(Map<String, dynamic> pmap) {
  return OrderMvc(pmap);
}

Mvc getSliderMvc(Map<String, dynamic> pmap) {
  return SliderMvc(pmap);
}

Mvc getSvgMapMvc(Map<String, dynamic> pmap) {
  return SvgPaintMvc(pmap);
}

Mvc getWebViewMvc(Map<String, dynamic> pmap) {
  return WebViewMvc(pmap);
}

const Map<String, Function> appMvc = {
  "MC": getMcMvc,
  "Text": getTextMvc,
  "Sentence": getSentenceMvc,
  "Order": getOrderMvc,
  "Slider": getSliderMvc,
  "SvgMap": getSvgMapMvc,
  "WebView": getWebViewMvc,
};

const Map<String, Function> appFunc = {"getSvgMap": getSvgMap};
