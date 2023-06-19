import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './patterns/slider_pattern.dart';
import '../util/util.dart';
import '../../builder/item_search.dart';
import '../../model/locator.dart';
import '../../builder/get_pattern.dart';
import '../../builder/pattern.dart';
import './patterns/app_pattern.dart';
import './patterns/game_complete.dart';
import './patterns/main_menu.dart';
import './patterns/mc_mvc.dart';
import './basic_resources.dart';
import './fonts.dart';
import '../../agent/config_agent.dart';
import './patterns/order_mvc.dart';
import './patterns/sentence_mvc.dart';
import './patterns/slider_3_pattern.dart';
import './patterns/slider_mvc.dart';
import './patterns/svg_paint_mvc.dart';
import '../../builder/svg_paint_pattern.dart';
import './patterns/text_mvc.dart';
import './patterns/vslider_pattern.dart';
import './patterns/webview_mvc.dart';

initApp() {
  int lives = model.map["userProfile"]["lives"];
  resxController.addToResxMap("lives", lives.toString());
  resxController.addToResxMap("progNoti", -1);
  model.appActions.addPatterns(appPatterns);
  model.appActions.addFunctions(appFunc);
  setLocale();
  // List<String> gn = [""];
  // resxController.addToResxMap("groupNoti", gn);
}

ProcessPattern getTopicPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_height",
    "_width",
    "_decoration",
    "_topicSelection",
    "_smallTitle",
    "_img",
    "_subtitle"
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
    "_shareHeight",
    "_screenName",
    "_sharedScreenText",
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
    "_textAlign",
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
  if ((item != null) && (item is! ProcessPattern)) {
    item = item.toString();
  }
  int? index = map["_index"];
  Map<String, dynamic>? eventMap = map["_eventMap"];
  if (eventMap != null) {
    eventMap["_item"] = item;
    eventMap["_index"] = index;
  }
  if (item is String) {
    Function pf;
    List<String> co = item.split(".");
    int to = co.length - 1;
    bool isImg = (to > 0) ? imgSuff.contains(co[to].toLowerCase()) : false;
    if (isImg) {
      map["_name"] = item;
      if (item.contains("svg")) {
        pf = getPrimePattern["SVGAsset"]!;
      } else {
        pf = getPrimePattern["ImageAsset"]!;
      }
    } else {
      pf = getPrimePattern["Text"]!;
      map["_text"] = item;
    }
    map["_child"] = pf(map);
  } else if (item is ProcessPattern) {
    map["_child"] = item;
  }
  Function cf = (map["_beginColor"] != null)
      ? getPrimePattern["ColorButton"]!
      : getPrimePattern["Container"]!;
  ProcessPattern cp = cf(map);
  if (map["_badgeContext"] != null) {
    map["_child"] = cp;
    cf = getPrimePattern["Badge"]!;
    cp = cf(map);
  }
  return cp;
}

ProcessPattern _getImage(String imgs, Map<String, dynamic> map, double height) {
  Function pf;
  if (imgs.contains("svg")) {
    pf = getPrimePattern["SVGAsset"]!;
  } else {
    pf = getPrimePattern["ImageAsset"]!;
  }
  dynamic _bf = map["_fit"];
  BoxFit bf = BoxFit.cover;
  if (_bf != null) {
    switch (_bf) {
      case "width":
        bf = BoxFit.fitWidth;
        break;
      case "height":
        bf = BoxFit.fitHeight;
        break;
      case "fill":
        bf = BoxFit.fill;
        break;
      default:
        break;
    }
  }
  Map<String, dynamic> iMap = {
    "_name": imgs,
    "_height": height,
    "_boxFit": bf,
  };
  return pf(iMap);
}

ProcessPattern getMvcColumnPattern(Map<String, dynamic> map) {
  ConfigAgent configAgent = map["_configAgent"];
  List<dynamic> children = [];
  Function pf;
  Function cpf = getPrimePattern["Container"]!;
  ProcessPattern pp;
  Map<String, dynamic> iMap;
  dynamic qImg = configAgent.getElement(map["_Q_Image"], map);
  double height = 0.2685 * model.scaleHeight;
  if (qImg is List<dynamic>) {
    bool isStack = map["_image_stack"] ?? false;
    if (isStack) {
      List<ProcessPattern> ppList = [];
      for (dynamic d in qImg) {
        if (d is String) {
          pp = _getImage(d, map, height);
          ppList.add(pp);
        }
      }
      iMap = {
        "_children": ppList,
      };
      pf = getPrimePattern["Stack"]!;
      pp = pf(iMap);
      iMap = {
        "_child": pp,
        "_height": height,
        "_decoration": shadowDecoration2,
      };
      pp = cpf(iMap);
      children.add(pp);
      qImg = null;
    } else {
      int ri = getRandom(qImg.length, [])!;
      qImg = qImg[ri];
    }
  }
  String? imgs = qImg;
  if ((imgs != null) && (imgs.isNotEmpty)) {
    iMap = {
      "_child": _getImage(imgs, map, height),
      "_height": height,
      "_decoration": shadowDecoration2,
    };
    // iMap["_borderRadius"] = BorderRadius.circular(size10);
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
    "_text": configAgent.checkText("_Question", map),
    "_textAlign": TextAlign.center,
    "_textStyle": questionTextStyle,
    "_alignment": Alignment.center,
  };
  pf = getPrimePattern["Text"]!;
  iMap["_child"] = pf(iMap);
  pp = cpf(iMap);
  children.add(pp);
  String? instr = configAgent.checkText("_Instruction", map);
  if (instr != null) {
    instr = iMap["_text"] = instr;
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
  pf = getPrimePattern["Column"]!;
  iMap["_child"] = pf(iMap);
  pf = getPrimePattern["ScrollLayout"]!;
  return pf(iMap);
}

ProcessPattern getConfirmPattern(Map<String, dynamic> map) {
  Map<String, dynamic> text = model.map["text"];
  Map<String, dynamic> tapAction = {
    "_event": "confirm",
  };

  Map<String, dynamic> iMap = {
    "_item": text["confirm"],
    "_height": 0.07143 * model.scaleHeight,
    "_width": 0.872 * model.scaleWidth,
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
  Function pf = getPrimePattern["TapItem"]!;
  iMap["_child"] = pf(iMap);
/*   iMap["_notifier"] = createNotifier(0.5);
  map["_confirmNoti"] = iMap["_notifier"];
  pf = getPrimePattern["ValueOpacity"]; */

  pf = getPrimePattern["Opacity"]!;
  iMap = {"_child": pf(iMap), "_valueName": "confirm", "_valueKey": "_opacity"};
  pf = getPrimePattern["Obx"]!;
  return pf(iMap);
}

ProcessPattern getTapItemElemPattern(
    String event, double height, double width, var inspec) {
  Map<String, dynamic> tapAction = {
    "_event": event,
  };
  Map<String, dynamic> spec = (inspec is Map<String, dynamic>) ? inspec : {};
  tapAction.addAll(spec);
  dynamic btnType = (inspec is String) ? inspec : spec["_btnType"];
  if (btnType is String) {
    switch (btnType) {
      case "blue":
        spec = {
          "_textStyle": controlButtonTextStyle,
          "_textAlign": TextAlign.center,
          "_beginColor": colorMap["btnBlue"],
          "_endColor": colorMap["btnBlueGradEnd"],
        };
        break;
      case "corr":
        spec = {
          "_textStyle": controlButtonTextStyle,
          "_textAlign": TextAlign.center,
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
  if (tapAction["_onTap"] == null) {
    Map<String, dynamic> eventMap = {"_item": text[event]};
    ProcessEvent pe = ProcessEvent("fsm");
    pe.map = eventMap;
    iMap["_onTap"] = pe;
  } else {
    iMap["_onTap"] = tapAction["_onTap"];
    iMap["_tapAction"] = tapAction["_tapAction"];
  }
  Function pf = getPrimePattern["TapItem"]!;
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
    Rx<List<dynamic>>? gvNoti, bool isImg, Map<String, dynamic> map) {
  BoxDecoration decoration;
  Color dc;
  bool incorr = type == "incorrect";
  String icon;
  switch (type) {
    case "correct":
      dc = colorMap["correct"]!;
      icon = "correct";
      break;
    case "incorrect":
      dc = colorMap["incorrect"]!;
      icon = "incorrect";
      break;
    case "answer":
      dc = colorMap["btnBlue"]!;
      icon = "correct";
      break;
    default:
      return null;
  }
  if (isImg || incorr) {
    decoration = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: dc, width: 2 * sizeScale),
      borderRadius: BorderRadius.circular(size10),
    );
  } else {
    decoration = BoxDecoration(
      color: dc,
      borderRadius: BorderRadius.circular(size10),
    );
  }
  Map<String, dynamic> imap = {"_icon": icon, "_iconColor": dc};
  Function pf = getPrimePattern["Icon"]!;
  ProcessPattern pp = pf(imap);
  Map<String, dynamic> childMap = {
    "_alignment": Alignment.center,
    "_decoration": decoration,
    "_textStyle": incorr ? incorrTxtStyle : selButnTxtStyle,
    "_textAlign": TextAlign.center,
    "_badgeContext": pp,
    "_badgeColor": Colors.white,
  };
  childMap.addAll(map);
  Function iepf = model.appActions.getPattern("ItemElem")!;
  pp = iepf(childMap);
  int ci = map["_childInx"];
  children[ci] = pp;
  if (gvNoti != null) {
    List<dynamic> c = [];
    List<dynamic> cc = gvNoti.value;
    cc[ci] = pp;
    c.addAll(cc);
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
    "_scale1Dec",
    "_scale2Dec",
    "_scale3Dec",
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

ProcessPattern getSliderPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_text",
    "_suffix",
    "_start",
    "_end",
    "_sliderNoti",
    "_scaleDec",
    "_mv"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return SliderPattern(map);
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
    "_mv",
    "_totalNotches",
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
    "_selId",
    "_shapes",
    "_scale",
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

ProcessPattern getDialogPattern(Map<String, dynamic> map) {
  Function pf = getPrimePattern["Text"]!;
  Map<String, dynamic> imap = {
    "_text": map["_title"],
    "_textStyle": bannerTxtStyle,
  };
  ProcessPattern pp = pf(imap);
  String? subTitle = map["_subTitle"];
  if (subTitle != null) {
    pp = addSubtitle(pp, subTitle);
  }
  String? bi = map["_bannerImage"];
  String style = map["_diaStyle"];
  BoxDecoration bd = map["_bannerBD"] ??
      ((bi != null) ? getDecoration(bi) : getStyleBoxDecoration(style));
  double w = map["_width"];
  List<dynamic>? brow = map["_bannerRow"];
  //double bw = w;
  if (brow != null) {
    imap = {"_child": pp};
    pf = getPrimePattern["Expanded"]!;
    brow.insert(0, pf(imap));
    imap = {"_width": size20};
    pf = getPrimePattern["SizedBox"]!;
    pp = pf(imap);
    brow.insert(0, pp);
    imap = {
      "_children": brow,
      "_mainAxisAlignment": MainAxisAlignment.spaceEvenly
    };
    pf = getPrimePattern["Row"]!;
    pp = pf(imap);
    // imap = {"_width": w * 0.4, "_child": pp};
    // pf = getPrimePattern["Container"];
    // pp = pf(imap);
  } else {
    imap = {"_child": pp, "_alignment": const Alignment(-0.8, 0.0)};
    pf = getPrimePattern["Align"]!;
    pp = pf(imap);
  }
  imap = {
    "_child": pp,
    "_height": 0.07266 * model.scaleHeight,
    "_width": w,
    "_decoration": bd,
  };
  pf = getPrimePattern["Container"]!;
  ProcessPattern banner = pf(imap);
  pf = getPrimePattern["SizedBox"]!;
  imap = {"_height": 5.0};
  ProcessPattern sizedPat = pf(imap);
  double btnHeight = map["_buttonHeight"] ?? 0.0468 * model.scaleHeight;
  double btnWidth = map["_buttonWidth"] ?? 0.3733 * model.scaleWidth;
  var btns = map["_buttons"];
  ProcessPattern btnPat;
  Map<String, dynamic> iMap = {
    "_decoration": elemDecoration,
    "_textStyle": choiceButnTxtStyle,
  };
  dynamic si;
  if (btns is List<dynamic>) {
    List<dynamic> children = [];
    si = iMap;
    for (int i = 0; i < btns.length; i++) {
      if (i == (btns.length - 1)) {
        si = "blue";
      }
      children.add(getTapItemElemPattern(btns[i], btnHeight, btnWidth, si));
    }
    iMap = {
      "_crossAxisAlignment": CrossAxisAlignment.center,
      "_mainAxisAlignment": MainAxisAlignment.spaceAround,
      "_children": children,
    };
    Function pf = getPrimePattern["Row"]!;
    btnPat = pf(iMap);
  } else {
    dynamic mbs = map["_btnStyle"];
    si = (mbs == null) ? "blue" : ((mbs is Map<String, dynamic>) ? mbs : iMap);
    btnPat = getTapItemElemPattern(btns, btnHeight, btnWidth, si);
  }
  si = map["_diaBox"];
  List<dynamic> children = (si != null)
      ? [banner, si, btnPat, sizedPat]
      : [banner, btnPat, sizedPat];
  imap = {
    "_mainAxisAlignment": MainAxisAlignment.spaceBetween,
    "_children": children
  };
  pf = getPrimePattern["Column"]!;
  imap["_child"] = pf(imap);
  imap["_borderRadius"] = BorderRadius.all(Radius.circular(18.0 * sizeScale));
  pf = getPrimePattern["ClipRRect"]!;
  pp = pf(imap);
  si = map["_diaBoxHeight"];
  double h = (si == null)
      ? 0.1823 * model.scaleHeight
      : si + 0.1823 * model.scaleHeight;
  imap = {
    "_alignment": Alignment.center,
    "_height": h,
    "_width": w,
    "_decoration": diaDecoration,
    "_child": pp
  };
  pf = getPrimePattern["Container"]!;
  pp = pf(imap);
  imap = {
    "_child": pp,
    "_alignment": const Alignment(0.0, 0.99),
  };
  pf = getPrimePattern["Align"]!;
  return pf(imap);
}

BoxDecoration? getStyleBoxDecoration(String style) {
  switch (style) {
    case "blue":
      return blueGradBD;
    case "corr":
    case "green":
      return greenGradBD;
    case "incorr":
    case "red":
      return redGradBD;
    case "blueBorderBtn":
      return btnDecoration;
    case "blueBtn":
      return selDecoration;
    default:
      return null;
  }
}

ProcessPattern addSubtitle(ProcessPattern title, String subTitle) {
  List<dynamic> c = [title];
  Map<String, dynamic> imap = {
    "_text": subTitle,
    "_textStyle": selButnTxtStyle,
  };
  Function pf = getPrimePattern["Text"]!;
  c.add(pf(imap));
  imap = {
    "_crossAxisAlignment": CrossAxisAlignment.start,
    "_mainAxisAlignment": MainAxisAlignment.spaceAround,
    "_children": c
  };
  pf = getPrimePattern["Column"]!;
  return pf(imap);
}

ProcessPattern getGroupProgNotiPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_greyEvent",
    "_greenEvent",
    "_compPercent",
    "_grProgId",
    "_index"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return GroupProgNotiPattern(map);
}

ProcessPattern getWatchAd(Map<String, dynamic>? pmap) {
  Map<String, dynamic> imap = {
    "_icon": 'lives',
    "_iconColor": Colors.white,
  };
  Function pf = getPrimePattern["Icon"]!;
  ProcessPattern pp = pf(imap);
  imap = {"_textStyle": controlButtonTextStyle, "_text": "+1"};
  pf = getPrimePattern["Text"]!;
  List<dynamic> livesRow = [space10, pp, pf(imap)];
  imap["_text"] = model.map['text']["watchAd"];
  livesRow.insert(0, pf(imap));
  livesRow.insert(0, space10);
  imap = {
    "_children": livesRow,
    "_mainAxisAlignment": MainAxisAlignment.spaceAround,
  };
  pf = getPrimePattern["Row"]!;
  pp = pf(imap);
  imap = {
    "_child": pp,
    "_gradient": greenGradient,
    "_height": 1.2 * btnHeight,
    "_width": 1.2 * btnWidth,
  };
  pf = getPrimePattern["ColorButton"]!;
  return pf(imap);
}

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

ProcessPattern getTapItemElemP(Map<String, dynamic> pmap) {
  double h = pmap["_height"] ?? btnHeight;
  double w = pmap["_width"] ?? btnWidth;
  return getTapItemElemPattern(pmap["_event"]!, h, w, pmap["_spec"]);
}

ProcessPattern getBorderButton(Map<String, dynamic> pmap) {
  double h = pmap["_height"] ?? btnHeight;
  double w = pmap["_width"] ?? btnWidth;
  Map<String, dynamic> spec = pmap["_spec"] ?? {};
  String btnType = pmap["_btnType"];
  late Color c = colorMap[btnType]!;
  spec["_decoration"] = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: c, width: 2),
    borderRadius: BorderRadius.circular(size10),
  );
  spec["_textStyle"] = TextStyle(
    fontFamily: fontNameAN,
    fontWeight: w500,
    fontSize: fsize16,
    color: c,
  );
  return getTapItemElemPattern(pmap["_event"]!, h, w, spec);
}

const Map<String, Function> appPatterns = {
  "BorderButton": getBorderButton,
  "Confirm": getConfirmPattern,
  "GameComplete": getGameCompletePattern,
  "GameItemPattern": getGameItemPattern,
  "GroupProgNoti": getGroupProgNotiPattern,
  "ItemElem": getItemElemPattern,
  "MenuBubble": getMenuBubble,
  "MvcColumn": getMvcColumnPattern,
  "NotiElem": getNotiElemPattern,
  "Slider": getSliderPattern,
  "TapItemElem": getTapItemElemP,
  "ThreeSlider": getThreeSliderPattern,
  "Topic": getTopicPattern,
  "VertSlider": getVertSliderPattern,
  "WatchAd": getWatchAd,
};

const Map<String, Function> appMvc = {
  "MC": getMcMvc,
  "Text": getTextMvc,
  "Sentence": getSentenceMvc,
  "Order": getOrderMvc,
  "Slider": getSliderMvc,
  "SvgMap": getSvgMapMvc,
  "WebView": getWebViewMvc,
};

clearCache() {
  model.versionAgent.removeCachedMap();
}

const Map<String, Function> appFunc = {
  "getSvgMap": getSvgMap,
  "getSvgXML": getSvgXML,
  "onSearch": onSearch,
  "onShare": onShare,
  "clearCache": clearCache,
  "getRenewDay": getRenewDay,
};
