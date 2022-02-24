import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirius_geo_4/resources/basic_resources.dart';
import 'package:sirius_geo_4/agent/config_agent.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/resources/s_g_icons.dart';
import 'package:sirius_geo_4/builder/svg_paint_pattern.dart';
import 'package:sirius_geo_4/builder/get_pattern.dart';
import 'package:sirius_geo_4/resources/fonts.dart';

class NotiElemPattern extends ProcessPattern {
  bool isGroup = false;
  int total;
  Widget w;
  String progId;
  int pno = 0;

  NotiElemPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    progId = map["_progId"];
    var prog = getCompleted(progId);
    isGroup = prog is int;
    if (prog is int) {
      pno = prog;
      total = map["_progTotal"];
      if (prog < total) {
        return Obx(() {
          dynamic value = resxController.getRxValue("groupNoti");
          return _buildWidget(value);
        });
      }
      return _buildWidget(null);
    } else {
      bool done = prog as bool;
      if ((!done) && (progId != null)) {
        return Obx(() {
          dynamic value = resxController.getRxValue("progNoti");
          return _buildWidget(value);
        });
      }
      pno = 1;
      return _buildWidget(null);
    }
  }

  Widget _buildWidget(dynamic value) {
    Widget ic = getPatternWidget(map["_child"]);
    if (isGroup) {
      if (value != null) {
        if ((value is List<String>) && (!value.contains(progId))) {
          if (w != null) {
            return w;
          }
        } else {
          pno++;
        }
      }
      double wi = map["_width"];
      double hp = 0.0184729 * model.screenHeight;
      bool full = (pno >= total);
      int i = full ? total : pno;
      Widget pi = (i == 0)
          ? null
          : Container(
              width: full ? wi : wi * i / total,
              height: hp,
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(10)),
                gradient: greenGradient,
              ));

      double h = map["_height"] * 0.85;
      Widget pc = Positioned(
          top: h,
          left: 0.0,
          child: (i == 0)
              ? Container(
                  width: wi,
                  height: hp,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      border: Border.all(color: colorMap["correct"], width: 1)),
                )
              : Container(
                  alignment: Alignment.centerLeft,
                  width: wi,
                  height: hp,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      border: Border.all(color: colorMap["correct"], width: 1)),
                  child: pi,
                ));
      ic = Align(
        alignment: const Alignment(0.0, -0.25),
        child: ic,
      );
      ic = Stack(
        alignment: Alignment.center,
        children: [ic, pc],
      );
    } else {
      if ((value != progId) && (w != null)) {
        return w;
      }
      if ((progId != null) && (value == progId)) {
        pno++;
      }
      if (pno > 1) {
        return w;
      }
      if ((pno == 1) && (progId != null)) {
        double h = model.screenWidth * 0.04533333;
        Widget pi = Positioned(
          top: map["_height"] * 0.70,
          left: map["_width"] * 0.70,
          child:
              Icon(myIcons["correct"], size: h, color: const Color(0xFF4DC591)),
        );
        ic = Stack(
          alignment: Alignment.center,
          children: [ic, pi],
        );
      }
    }
    w = Container(
        child: ic,
        color: map["_color"],
        alignment: map["_alignment"],
        clipBehavior: map["_clipBehavior"] ?? Clip.none,
        constraints: map["_boxConstraints"],
        decoration: map["_decoration"],
        foregroundDecoration: map["_foregroundDecoration"],
        width: map["_width"],
        height: map["_height"],
        margin: map["_margin"],
        padding: map["_padding"],
        transform: map["_transform"]);
    return w;
  }
}

getSvgMap(Map<String, dynamic> map) {
  String data = map["_data"];
  Map<String, dynamic> mapJson = json.decode(data);
  List<dynamic> mapList = mapJson["word_map"];

  List<Shape> shapes = [];
  Paint borderPaint = map["_borderPaint"];
  Paint shapePaint = map["_shapePaint"];
  String key = map["_matchKey"];
  int i = 0;
  for (Map<String, dynamic> c in mapList) {
    String label = c["key"];
    ShapeText st = ShapeText(label, 24, "Lato", Colors.white70);
    shapes.add(Shape(c["path"], i, st, shapePaint, borderPaint));
    if ((key != null) && (label == key)) {
      map["_ansIndex"] = i;
    }
    i++;
  }
  map["_shapes"] = shapes;
  ValueNotifier<ProcessPattern> noti = map["_childNoti"];
  Function pf = model.appActions.getPattern("SvgPaint");
  noti.value = pf(map);
}

ProcessPattern getMenuBubble(Map<String, dynamic> map) {
  Map<String, dynamic> imap = {
    "_height": 0.06 * model.screenHeight,
    "_name": "assets/images/menu_bubble.png",
    "_boxFit": BoxFit.cover,
  };
  Function pf = getPrimePattern["ImageAsset"];
  ProcessPattern arrow = pf(imap);
  imap = {"_width": 20.0};
  pf = getPrimePattern["SizedBox"];
  imap = {
    "_textStyle": choiceButnTxtStyle,
    "_iconSize": 20.0,
    "_iconColor": colorMap["btnBlue"],
    "_highlightColor": colorMap["btnBlue"],
    "_hoverColor": colorMap["btnBlue"],
    "_gap": pf(imap),
    "_horiz": true,
    "_key": map["_key"],
  };
  List<dynamic> menuBox = [];
  pf = getPrimePattern["IconText"];
  List<dynamic> menuList = map["_menuList"];
  ProcessEvent pe = ProcessEvent("menu");
  double boxHeight = 0.0;
  for (String mStr in menuList) {
    List<String> ls = mStr.split(";");
    imap["_icon"] = ls[0];
    imap["_text"] = ls[1];
    imap["_onTap"] = pe;
    List<dynamic> ld = [ls[1], true];
    imap["_tapAction"] = ld;
    menuBox.add(pf(imap));
    boxHeight += 30.0;
  }

  double boxWidth = 0.50 * model.screenWidth;
  imap = {
    "_align": const Alignment(0.80, -0.85),
    "_bubbleArrow": arrow,
    "_bubbleBox": menuBox,
    "_bubbleHeight": 0.23399 * model.screenHeight,
    "_arrowAlign": const Alignment(0.9, -0.95),
    "_boxAlign": Alignment.centerRight,
    "_boxWidth": boxWidth,
    "_mainAxisAlignment": MainAxisAlignment.spaceEvenly,
    "_boxHeight": boxHeight,
  };
  pf = getPrimePattern["Bubble"];
  return pf(imap);
}
