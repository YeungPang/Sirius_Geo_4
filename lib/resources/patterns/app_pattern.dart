import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../basic_resources.dart';
import '../../agent/config_agent.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../s_g_icons.dart';
import '../../builder/svg_paint_pattern.dart';
import '../../builder/get_pattern.dart';
import '../fonts.dart';

class NotiElemPattern extends ProcessPattern {
  bool isGroup = false;
  int total = 0;
  Widget? w;
  dynamic progId;
  int pno = 0;
  List<int>? ids;
  bool waiting = false;

  NotiElemPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    progId = map["_progId"];

    isGroup = (progId is! int) && (progId != null);
    if (isGroup) {
      if (ids == null) {
        if (progId is String) {
          ids = resolveIntList(progId);
        } else if (progId is List<int>) {
          ids = progId;
        } else if (progId is List<dynamic>) {
          ids = [];
          for (int n in progId) {
            ids!.add(n);
          }
        }
      }
      var prog = getCompleted(ids);
      pno = prog;
      total = ids!.length;
      if (prog < total) {
        return Obx(() {
          dynamic value = resxController.getRxValue("progNoti");
          return _buildWidget(value);
        });
      }
      return _buildWidget(null);
    } else {
      var prog = getCompleted(progId);
      bool done = (progId != null) ? prog as bool : false;
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
    Widget? ic = getPatternWidget(map["_child"]);
    if (isGroup) {
      if ((value != null) && (value != -1)) {
        if ((value is int) && (!ids!.contains(value))) {
          if (w != null) {
            return w!;
          }
        } else {
          if (waiting) {
            pno++;
          }
        }
      }
      waiting = true;
      double wi = map["_width"];
      double hp = 0.0184729 * model.scaleHeight;
      bool full = (pno >= total);
      int i = full ? total : pno;
      Widget? pi = (i == 0)
          ? null
          : Container(
              width: full ? wi : wi * i / total,
              height: hp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(size10 * sizeScale)),
                gradient: greenGradient,
              ));

      double h = map["_height"] * 0.85;
      double s10 = size10 * sizeScale;
      Widget pc = Positioned(
          top: h,
          left: 0.0,
          child: (i == 0)
              ? Container(
                  width: wi,
                  height: hp,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(s10),
                          bottomLeft: Radius.circular(s10)),
                      border:
                          Border.all(color: colorMap["correct"]!, width: 1)),
                )
              : Container(
                  alignment: Alignment.centerLeft,
                  width: wi,
                  height: hp,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(s10),
                          bottomLeft: Radius.circular(s10)),
                      border:
                          Border.all(color: colorMap["correct"]!, width: 1)),
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
        return w!;
      }
      if ((progId != null) && (value == progId)) {
        pno++;
      }
      if (pno > 1) {
        return w!;
      }
      if ((pno == 1) && (progId != null)) {
        double h = model.scaleWidth * 0.04533333;
        Widget pi = Positioned(
          top: map["_height"] * 0.70,
          left: map["_width"] * 0.70,
          child:
              Icon(myIcons["correct"], size: h, color: const Color(0xFF4DC591)),
        );
        ic = Stack(
          alignment: Alignment.center,
          children: [ic!, pi],
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
    return w!;
  }
}

class GroupProgNotiPattern extends ProcessPattern {
  int total = 0;
  Widget? w;
  List<int> progId = [];
  int pno = 0;
  late double cp;
  ProcessEvent? greenEvent;
  ProcessEvent? greyEvent;
  int inx = 0;
  bool done = false;

  GroupProgNotiPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    inx = map["_index"];
    greenEvent = map["_greenEvent"];
    done = inx == 0;
    List<dynamic> gid = map["_grProgId"];
    double clp = map["_compPercent"];
    if (!done) {
      List<dynamic> lid = resxController.getCache("groupIds");
      lid.add(gid);
      List<dynamic> cl = resxController.getCache("compList");
      cl.add(clp);
      List<dynamic> ilid = lid[inx - 1];
      for (List<dynamic> sid in ilid) {
        List<int> iid = sid.map((s) => s as int).toList();
        progId.addAll(iid);
      }
      total = progId.length;

      int prog = getCompleted(progId);
      pno += prog;
      cp = cl[inx - 1] / 100.0;
      if ((total == 0) || ((pno / total) < cp)) {
        greyEvent = map["_greyEvent"];
      } else {
        done = true;
      }
    } else {
      List<dynamic> lid = [gid];
      resxController.setCache("groupIds", lid);
      List<dynamic> cl = [clp];
      resxController.setCache("compList", cl);
    }

    if (!done) {
      return Obx(() {
        dynamic value = resxController.getRxValue("progNoti");
        return _buildWidget(value);
      });
    }
    return _buildWidget(null);
  }

  Widget _buildWidget(dynamic value) {
    if (value is int) {
      if (done || (!progId.contains(value))) {
        if (w != null) {
          return w!;
        }
      } else {
        pno++;
      }
    }
    if (w != null) {
      if (done || ((pno / total) < cp)) {
        return w!;
      }
    }
    if (!done) {
      done = ((pno / total) >= cp);
    }
    ProcessEvent event = done ? greenEvent! : greyEvent!;
    Agent a = model.appActions.getAgent("pattern");

    var p = a.process(event);

    if (p is ProcessPattern) {
      w = p.getWidget();
    } else if (p is Widget) {
      w = p;
    }
/* 
    Widget ic;
    if ((pno / total) < cp) {
      ic = Image.asset("assets/images/greyarrow.png");
    } else {
      ic = Image.asset("assets/images/greenarrow.png");
      if (greenName != null) {
        String name = greenName + (++inx).toString();
        ProcessEvent greenEvent = resxController.getCache(name);
        if (greenEvent != null) {
          //resxController.setRxValue(name, greenEvent);
          greenName = null;
        }
      }
    }
    w = SizedBox(
      child: ic,
      width: map["_width"],
      height: map["_height"],
    ); */
    return w!;
  }
}

getSvgMap(Map<String, dynamic> map) {
  String data = map["_data"];
  Map<String, dynamic> mapJson = json.decode(data);
  List<dynamic> mapList = mapJson["word_map"];

  List<Shape> shapes = [];
  Paint borderPaint = map["_borderPaint"];
  Paint shapePaint = map["_shapePaint"];
  String? key = map["_matchKey"];
  int i = 0;
  for (Map<String, dynamic> c in mapList) {
    String label = c["key"];
    ShapeText st = ShapeText(label, 24 * fontScale, "Lato", Colors.white70);
    shapes.add(Shape(c["path"], i, st, shapePaint, borderPaint));
    if ((key != null) && (label == key)) {
      map["_ansIndex"] = i;
    }
    i++;
  }
  map["_shapes"] = shapes;
  ValueNotifier<ProcessPattern> noti = map["_childNoti"];
  Function pf = model.appActions.getPattern("SvgPaint")!;
  noti.value = pf(map);
}

ProcessPattern getMenuBubble(Map<String, dynamic> map) {
  Map<String, dynamic> imap = {
    "_height": 0.06 * model.scaleHeight,
    "_name": "assets/images/menu_bubble.png",
    "_boxFit": BoxFit.cover,
  };
  Function pf = getPrimePattern["ImageAsset"]!;
  ProcessPattern arrow = pf(imap);
  imap = {"_width": size20};
  pf = getPrimePattern["SizedBox"]!;
  imap = {
    "_textStyle": choiceButnTxtStyle,
    "_iconSize": size20,
    "_iconColor": colorMap["btnBlue"],
    "_highlightColor": colorMap["btnBlue"],
    "_hoverColor": colorMap["btnBlue"],
    "_gap": pf(imap),
    "_horiz": true,
    "_key": map["_key"],
  };
  List<dynamic> menuBox = [];
  pf = getPrimePattern["IconText"]!;
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
    boxHeight += 30.0 * sizeScale;
  }

  double boxWidth = 0.50 * model.scaleWidth;
  double ax = 1.0 - (41.1 / model.screenWidth);
  imap = {
    "_align": Alignment(ax, -0.85),
    "_bubbleArrow": arrow,
    "_bubbleBox": menuBox,
    "_bubbleHeight": 0.23399 * model.scaleHeight,
    "_arrowAlign": const Alignment(0.9, -0.95),
    "_boxAlign": Alignment.centerRight,
    "_boxWidth": boxWidth,
    "_mainAxisAlignment": MainAxisAlignment.spaceEvenly,
    "_boxHeight": boxHeight,
  };
  pf = getPrimePattern["Bubble"]!;
  return pf(imap);
}
