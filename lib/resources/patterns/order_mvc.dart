import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../agent/config_agent.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../../builder/get_pattern.dart';
import '../app_model.dart';
import '../basic_resources.dart';
import '../fonts.dart';

class OrderMvc extends Mvc {
  OrderMvc(Map<String, dynamic> map) : super(map);

  double bgHeight = 0.3941 * model.scaleHeight;
  ConfigAgent? configAgent;
  List<dynamic> answers = [];
  List<dynamic> options = [];
  List<dynamic> ansList = [];
  List<dynamic> children = [];
  List<dynamic> col = [];
  List<dynamic> draggingList = [];
  List<dynamic> dragAnsList = [];
  List<dynamic> dragChildList = [];
  List<dynamic> targetList = [];
  List<dynamic> selectList = [];
  Rx<List<dynamic>>? gvNoti;
  Map<String, dynamic> imap = {};
  Map<String, dynamic> lmap = {};
  Function? mvcpf;
  Function tipf = getPrimePattern["TapItem"]!;
  Function tpf = getPrimePattern["Text"]!;
  Function cpf = getPrimePattern["Container"]!;
  double childAspectRatio = 0.0;
  double eheight = 0.0;
  double ewidth = 0.0;
  double width = 0.8267 * model.scaleWidth;
  int selIndex = -1;
  int len = 0;
  late ProcessPattern view;
  late ProcessPattern holder;
  bool refresh = false;
  bool completed = false;
  late ProcessPattern bottomtext;
  late ProcessEvent pe;

  @override
  double getBgHeight() {
    double? r = map["_bgHeight"];
    return (r == null) ? bgHeight : r * model.scaleHeight;
  }

  @override
  init() {
    selIndex = -1;
    map["_state"] = "incomplete";
    answers = [];
    configAgent ??= map["_configAgent"];
    if (ansList.isEmpty) {
      ansList = configAgent!.getElement(map["_Answer"], map);
      len = ansList.length;
      options = configAgent!.getElement(map["_AnswerOptions"], map);
      int olen = options.length;
      List<int> oList = getRandomList(olen, olen, null, null)!;
      options = mapList(oList, options)!;
      col = [];
      var inf = configAgent!.getElement("_Info1", map);
      imap = {
        "_text": inf.toString(),
        "_textStyle": smallTextStyle,
      };
      ProcessPattern pp = tpf(imap);
      inf = configAgent!.getElement("_Info2", map);
      imap["_text"] = inf.toString();
      bottomtext = tpf(imap);
      imap = {
        "_height": size20,
        "_width": width,
        "_child": pp,
        "_alignment": Alignment.centerRight,
      };
      col.add(cpf(imap));
      imap["_child"] = bottomtext;
      bottomtext = cpf(imap);

      eheight = 0.061576 * model.scaleHeight;
      ewidth = 0.345 * model.scaleWidth;
      imap = {
        "_height": eheight,
        "_width": ewidth,
        "_boxConstraints": BoxConstraints(maxWidth: ewidth),
      };
      ProcessPattern cpp = cpf(imap);
      imap = {
        "_radius": size10,
        "_dottedColor": colorMap["btnBlue"],
        "_strokeWidth": 2.0,
        "_child": cpp
      };
      Function pf = getPrimePattern["DottedBorder"]!;
      holder = pf(imap);
      pp = buildGridView();
      col.add(pp);
      col.add(bottomtext);
    }
    map["_colElem"] = col;
    mvcpf ??= model.appActions.getPattern("MvcColumn");
    view = mvcpf!(map);
  }

  ProcessPattern buildGridView() {
    draggingList = [];
    dragAnsList = [];
    dragChildList = [];
    targetList = [];
    selectList = [];
    children = [];
    answers = [];
    Map<String, dynamic> cmap = {
      "_decoration": dragDecoration,
      "_textStyle": mediumNormalTextStyle,
      "_childWhenDragging": holder,
    };
    Map<String, dynamic> gmap = {
      "_decoration": selDecoration,
      "_textStyle": selButnTxtStyle,
      "_childWhenDragging": holder,
    };
    Map<String, dynamic> amap = {
      "_decoration": btnDecoration,
      "_textStyle": choiceButnTxtStyle,
      "_childWhenDragging": holder,
    };

    pe = ProcessEvent("fsm");

    Function dpf = getPrimePattern["Draggable"]!;
    for (int i = 0; i < options.length; i++) {
      Map<String, dynamic> dragAction = {
        "_event": "dropSel",
        "_item": "dragging",
        "_index": i
      };
      gmap["_item"] = options[i];
      gmap["_index"] = i;
      gmap["_data"] = dragAction;
      ProcessPattern pp =
          getTapItemElemPattern("select", eheight, ewidth, gmap);
      selectList.add(pp);
      gmap["_child"] = pp;
      pp = dpf(gmap);
      draggingList.add(pp);

      dragAction = {"_event": "dropSel", "_item": "dragChild", "_index": i};
      cmap["_item"] = options[i];
      cmap["_index"] = i;
      cmap["_data"] = dragAction;
      cmap["_feedback"] = selectList[i];
      pp = getTapItemElemPattern("select", eheight, ewidth, cmap);
      cmap["_child"] = pp;
      pp = dpf(cmap);
      dragChildList.add(pp);

      dragAction = {"_event": "dropSel", "_item": "dragAns", "_index": i};
      amap["_item"] = options[i];
      amap["_index"] = i;
      amap["_data"] = dragAction;
      amap["_feedback"] = selectList[i];
      pp = getTapItemElemPattern("select", eheight, ewidth, amap);
      amap["_child"] = pp;
      pp = dpf(amap);
      dragAnsList.add(pp);

      Map<String, dynamic> tapAction = {
        "_event": "select",
        "_index": i,
        "_item": "target"
      };
      imap = {"_child": holder, "_onTap": pe, "_tapAction": tapAction};
      pp = tipf(imap);
      ProcessEvent dpe = ProcessEvent("fsm");
      dpe.map = {"_dropIndex": i};
      imap = {"_target": pp, "_dropAction": dpe};
      Function pf = getPrimePattern["DragTarget"]!;
      pp = pf(imap);
      targetList.add(pp);
      children.add(dragChildList[i]);
      children.add(targetList[i]);
      answers.add("");
    }
    gvNoti = resxController.addToResxMap("gv", children) as Rx<List<dynamic>>;

    double mainAS = 0.01847 * model.scaleHeight;
    childAspectRatio = ewidth / eheight;
    imap = {
      "_crossAxisCount": 2,
      "_childAspectRatio": childAspectRatio,
      "_mainAxisSpacing": mainAS,
      "_crossAxisSpacing": 0.04 * model.scaleWidth,
      "_padding": EdgeInsets.all(size10),
    };
    Function pf = getPrimePattern["GridView"]!;
    ProcessPattern gv = pf(imap);
    lmap = {"_valueName": "gv", "_child": gv};
    pf = getPrimePattern["Obx"]!;
    imap = {
      "_width": width,
      "_height": eheight * children.length / 2 +
          mainAS * (children.length / 2.0 + 2.0),
      "_alignment": Alignment.center,
      "_decoration": shadowRCDecoration,
      "_child": pf(lmap)
    };
    pf = getPrimePattern["Container"]!;
    return pf(imap);
  }

  @override
  reset(bool startNew) {
    refresh = true;
    init();
  }

  @override
  String doAction(String action, Map<String, dynamic>? emap) {
    switch (action) {
      case "Selection":
        int inx = emap!["_index"]! as int;
        if (selIndex == -1) {
          if (emap["_item"]! == "target") {
            break;
          }
          selIndex = inx;
          int ix = children.indexOf(dragChildList[inx]);
          if (ix < 0) {
            ix = children.indexOf(dragAnsList[inx]);
          }
          children[ix] = draggingList[inx];
        } else {
          if (emap["_item"]! == "target") {
            swap(selIndex, inx);
          } else {
            int ix = children.indexOf(draggingList[selIndex]);
            int i = ix % 2;
            if (i > 0) {
              children[ix] = dragAnsList[selIndex];
            } else {
              children[ix] = dragChildList[selIndex];
            }
            if (selIndex != inx) {
              ix = children.indexOf(dragChildList[inx]);
              if (ix < 0) {
                ix = children.indexOf(dragAnsList[inx]);
              }
              children[ix] = draggingList[inx];
              selIndex = inx;
            } else {
              selIndex = -1;
            }
          }
        }
        List<dynamic> c = [];
        c.addAll(children);
        gvNoti!.value = c;
        break;
      case "DropSel":
        int sI = selIndex;
        swap(emap!["_index"]!, emap["_dropIndex"]!);
        selIndex = sI;
        break;
      case "CheckAns":
        bool cor = true;
        int ix = 1;
        map["_state"] = "confirmed";
        for (int i = 0; i < ansList.length; i++) {
          String r = "correct";
          if (answers[i].toString().trim().toLowerCase() !=
              ansList[i].toString().trim().toLowerCase()) {
            r = "incorrect";
            cor = false;
          }
          buildBadgedElem(i, ix, r, children);
          ix += 2;
        }
        List<dynamic> c = [];
        c.addAll(children);
        gvNoti!.value = c;
        if (cor) {
          return "correct";
        } else {
          return "incorrect";
        }
      case "ShowAnswer":
        answers = ansList;
        int ix = 1;
        for (int i = 0; i < answers.length; i++) {
          buildBadgedElem(i, ix, "answer", children);
          ix += 2;
        }
        List<dynamic> c = [];
        c.addAll(children);
        gvNoti!.value = c;
        break;
      case "TryAgain":
        break;
      default:
        break;
    }
    return action;
  }

  swap(int inx, int dinx) {
    ProcessPattern tp = targetList[dinx];
    ProcessPattern ap = dragAnsList[inx];
    ProcessPattern cp = dragChildList[inx];
    ProcessPattern dp = draggingList[inx];
    int ix = children.indexOf(ap);
    if (ix < 0) {
      ix = children.indexOf(dp);
    }
    if (ix < 0) {
      ix = children.indexOf(cp);
    }
    int dix = children.indexOf(tp);
    children[ix] = tp;
    int i = dix % 2;
    int ia;
    if (i > 0) {
      ia = dix ~/ 2;
      children[dix] = ap;
      answers[ia] = options[inx];
    } else {
      ia = ix ~/ 2;
      children[dix] = cp;
      answers[ia] = "";
    }
    completed = true;
    for (var vs in answers) {
      String s = vs.toString();
      if (s.isEmpty) {
        completed = false;
        break;
      }
    }
    if (completed) {
      map["_state"] = "completed";
    } else {
      map["_state"] = "incomplete";
    }
    selIndex = -1;
    List<dynamic> c = [];
    c.addAll(children);
    gvNoti!.value = c;
  }

  @override
  ProcessPattern getPattern() {
    return view;
    //return map["_colElem"];
  }

  @override
  dynamic getAnswer() {
    return ansList;
  }

  @override
  retry() {
    answers = [];
    children = [];
    map["_state"] = "incomplete";
    for (int i = 0; i < targetList.length; i++) {
      children.add(dragChildList[i]);
      children.add(targetList[i]);
      answers.add("");
    }
    selIndex = -1;
    List<dynamic> c = [];
    c.addAll(children);
    gvNoti!.value = c;
  }

  buildBadgedElem(int i, int cinx, String type, List<dynamic> c) {
    Map<String, dynamic> childMap = {
      "_height": eheight,
      "_width": ewidth,
      "_item": answers[i],
      "_index": i,
      "_childInx": cinx
    };
    buildBadgedElement(type, c, null, false, childMap);
  }

  @override
  int getHintIndex() {
    return 0;
  }
}
