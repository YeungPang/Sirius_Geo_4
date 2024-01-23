import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xml/xml.dart';
import '../basic_resources.dart';
import '../../agent/config_agent.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../s_g_icons.dart';
import '../../builder/svg_paint_pattern.dart';
import '../../builder/get_pattern.dart';
import '../fonts.dart';

final List<String> styleCode = [
  "fill",
  "fill-opacity",
  "opacity",
  "stroke",
  "stroke-opacity",
  "stroke-width",
  "stroke-linecap",
  "stroke-linejoin"
];

class NotiElemPattern extends ProcessPattern {
  bool isGroup = false;
  int total = 0;
  Widget? w;
  dynamic progId;
  int pno = 0;
  List<int>? ids;
  bool waiting = false;

  NotiElemPattern(super.map);
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
                    bottomLeft: Radius.circular(size10),
                    bottomRight: full ? Radius.circular(size10) : Radius.zero),
                gradient: greenGradient,
              ));

      double h = map["_height"] * 0.85;
      double s10 = size10;
      //BorderSide b2 = const BorderSide(color: Colors.black, width: 2.0);
      //BorderSide b4 = BorderSide(color: colorMap["correct"]!, width: 4.0);
      Border b = Border.all(color: colorMap["correct"]!, width: 2.0);
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
                    border: b,
                  ))
              : Container(
                  alignment: Alignment.centerLeft,
                  width: wi,
                  height: hp,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(s10),
                          bottomLeft: Radius.circular(s10)),
                      border: b),
                  //Border.all(color: colorMap["correct"]!, width: 2.0)),
                  child: pi,
                ));
      ic = Align(
        alignment: const Alignment(0.0, -0.3),
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
      } else {
        ic = Stack(
          alignment: Alignment.center,
          children: [ic!],
        );
      }
    }
    w = Card(
      elevation: 4.0,
      shadowColor: Colors.grey,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(size10)),
      child: Container(
          color: map["_color"],
          alignment: map["_alignment"],
          clipBehavior: map["_clipBehavior"] ?? Clip.none,
          constraints: map["_boxConstraints"],
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(size10)),
            border: Border.all(color: Colors.black12, width: 1.0),
          ),
          //foregroundDecoration: map["_foregroundDecoration"],
          width: map["_width"],
          height: map["_height"],
          margin: map["_margin"],
          padding: map["_padding"],
          transform: map["_transform"],
          child: ic),
    );
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

  GroupProgNotiPattern(super.map);
  @override
  Widget getWidget({String? name}) {
    inx = map["_index"];
    greenEvent = map["_greenEvent"];
    done = inx == 0;
    List<dynamic> gid = map["_grProgId"];
    double clp = map["_compPercent"] ?? 0.0;
    if (!done) {
      List<dynamic> lid = resxController.getCache("groupIds");
      lid.add(gid);
      List<dynamic> cl = resxController.getCache("compList");
      cl.add(clp);
      List<dynamic> ilid = lid[inx - 1];
      for (var sid in ilid) {
        if (sid is List<dynamic>) {
          List<int> iid = sid.map((s) => s as int).toList();
          progId.addAll(iid);
        } else {
          progId.add(sid);
        }
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

getSvgXML(Map<String, dynamic> map) {
  String data = map["_data"];
  var xdoc = XmlDocument.parse(data);
  List<Shape> shapes = [];
  Map<String, dynamic> scls = {};
  String? inStyle = map["_style"];

  if (inStyle != null) {
    getStyleCls(inStyle, scls);
  }
  var svg = xdoc.rootElement;
  if ((scls[".default"] == null) && (svg.attributes.isNotEmpty)) {
    String styleStr = "";
    for (var attr in svg.attributes) {
      if (styleCode.contains(attr.localName)) {
        styleStr += attr.localName + ':' + attr.value + ";";
        //styleStr += "${attr.localName}:${attr.value};";
      }
    }
    if (styleStr.isNotEmpty) {
      scls[".default"] = getStyle(styleStr);
    }
  }
  if (scls[".default"] == null) {
    var styles = svg.findAllElements("style");
    if (styles.isNotEmpty) {
      for (var node in styles) {
        getStyleCls(node.value!, scls, overwrite: false);
      }
    }
  }
  var gElem = svg.findAllElements('g');
  if (gElem.length <= 1) {
    var pElem = svg.findAllElements("path");
    addShapes(pElem, shapes, shapes.length, scls, map);
  } else {
    for (var ge in gElem) {
      if ((scls[".default"] == null) && (ge.attributes.isNotEmpty)) {
        String styleStr = "";
        for (var attr in ge.attributes) {
          if (styleCode.contains(attr.localName)) {
            styleStr += attr.localName + ':' + attr.value + ";";
          }
        }
        if (styleStr.isNotEmpty) {
          scls[".local"] = getStyle(styleStr);
        }
      }
      var pElem = ge.findElements("path");
      String? sId = ge.getAttribute("id");
      addShapes(pElem, shapes, shapes.length, scls, map, sId: sId);
    }
  }
  Map<String, dynamic> _mv = map["_mv"];
  _mv["_selPaint"] =
      (scls[".selected"] != null) ? scls[".selected"]["fill"] : null;
  _mv["_ansPaint"] = (scls[".answer"] != null) ? scls[".answer"]["fill"] : null;
  _mv["_background"] = colorMap[map["_backgroundColor"]];
  if (map["_selLabelColor"] != null) {
    _mv["_selLabelColor"] = colorMap[map["_selLabelColor"]];
  }
  map["_shapes"] = shapes;
  ValueNotifier<ProcessPattern> noti = map["_childNoti"];
  Function pf = model.appActions.getPattern("SvgPaint")!;
  noti.value = pf(map);
}

addShapes(Iterable<XmlElement> pElem, List<Shape> shapes, int i,
    Map<String, dynamic> scls, Map<String, dynamic> map,
    {String? sId}) {
  String? key = map["_matchKey"];
  String styleStr = "";
  for (var pe in pElem) {
    String? label;
    late String strPath;
    String? cls;
    Map<String, dynamic>? style = scls[".default"] ?? scls[".local"];
    for (var attr in pe.attributes) {
      switch (attr.localName) {
        case "d":
          strPath = attr.value;
          break;
        case "class":
          cls = '.${attr.value}';
          break;
        case "title":
          label = attr.value;
          break;
        case "name":
          label = attr.value;
          break;
        case "id":
          label ??= attr.value;
          break;
        case "style":
          style ??= getStyle(attr.value);
          break;
        default:
          if ((style == null) && (styleCode.contains(attr.localName))) {
            styleStr += attr.localName + ':' + attr.value + ";";
          }
          break;
      }
    }
    Map<String, dynamic>? m = (styleStr.isNotEmpty)
        ? getStyle(styleStr)
        : ((style != null) ? style : ((cls != null) ? scls[cls] : null));
    Paint? fillPaint = (m != null) ? m["fill"] : null;
    Paint? strokePaint = (m != null) ? m["stroke"] : null;
    if ((fillPaint == null) && (strokePaint == null)) {
      fillPaint ??= Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      strokePaint ??= Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
    }
    label ??= sId ?? "";
    ShapeText st = ShapeText(label, 24 * fontScale, "Lato", Colors.white70);
    shapes.add(Shape(strPath, i, st, fillPaint, strokePaint, sId: sId));
    if ((key != null) && (label == key)) {
      map["_ansIndex"] = i;
    }
    i++;
  }
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
  //ProcessEvent pe = ProcessEvent("menu");
  double boxHeight = 0.0;
  for (String mStr in menuList) {
    ProcessEvent pe = ProcessEvent("fsmEvent");
    List<String> ls = mStr.split(";");
    pe.map = {"_event": ls[0], "_title": ls[1]};
    imap["_icon"] = ls[0];
    imap["_text"] = ls[1];
    imap["_onTap"] = pe;
    //List<dynamic> ld = [ls[1], true];
    imap["_tapAction"] = "menufsm";
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
