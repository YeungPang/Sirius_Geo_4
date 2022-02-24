import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirius_geo_4/agent/config_agent.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/builder/get_pattern.dart';
import 'package:sirius_geo_4/resources/app_model.dart';
import 'package:sirius_geo_4/resources/basic_resources.dart';
import 'package:sirius_geo_4/resources/fonts.dart';

class McMvc extends Mvc {
  McMvc(Map<String, dynamic> map) : super(map);
  ConfigAgent configAgent;
  List<int> excl = [];
  Map<String, dynamic> imap;
  Map<String, dynamic> lmap;
  List<dynamic> children = [];
  Function iepf;
  Function tipf;
  Function mvcpf;
  Rx<List<dynamic>> gvNoti;
  ProcessPattern view;
  double eheight;
  double ewidth;
  double childAspectRatio;
  List<dynamic> elemList = [];
  int currSel = -1;
  List<int> range;
  bool isImg = false;
  List<dynamic> options;
  int ans;
  double bgHeight = 0.4926 * model.screenHeight;
  List<dynamic> ansList = [];
  List<dynamic> selList = [];
  List<int> rowList = [];

  @override
  double getBgHeight() {
    return bgHeight;
  }

  @override
  init() {
    if (map["_Q_Image"] == null) {
      bgHeight = 0.8 * bgHeight;
    }
    configAgent ??= map["_configAgent"];
    options =
        configAgent.getElement(map["_AnswerOptions"], map, rowList: rowList);
    if ((options == null) || (options.isEmpty)) {
      return;
    }
    excl = [];
    setup();
    gvNoti = resxController.addToResxMap("gv", children);

    double mainAS = 0.01847 * model.screenHeight;
    childAspectRatio = ewidth / eheight;
    imap = {
      "_crossAxisCount": 2,
      "_childAspectRatio": childAspectRatio,
      "_mainAxisSpacing": mainAS,
      "_crossAxisSpacing": 0.04 * model.screenWidth,
      "_padding": const EdgeInsets.all(10),
    };
    Function pf = getPrimePattern["GridView"];
    ProcessPattern gv = pf(imap);
    lmap = {"_valueName": "gv", "_child": gv};
    pf = getPrimePattern["Obx"];
    imap = {
      "_width": 0.8267 * model.screenWidth,
      "_height":
          eheight * range.length / 2 + mainAS * (range.length / 2.0 + 1.5),
      "_alignment": Alignment.center,
      "_decoration": shadowRCDecoration,
      "_child": pf(lmap)
    };
    pf = getPrimePattern["Container"];
    map["_colElem"] = pf(imap);
    mvcpf = model.appActions.getPattern("MvcColumn");
    view = mvcpf(map);
  }

  setup() {
    currSel = -1;
    elemList = [];
    children = [];
    selList = [];
    //excl = [];
    String answer = map["_Answer"];
    if (answer.contains("_ans")) {
      ans = getRandom(options.length, excl);
    } else if (answer.contains('[')) {
      ansList = configAgent.getElement(map["_Answer"], map);
      range = [];
      for (int k = 0; k < options.length; k++) {
        range.add(k);
      }
    } else {
      RegExp re = RegExp(r"[(),]");
      List<String> sl = answer.trim().split(re);
      ans = int.tryParse(sl[1].trim());
    }
    if (ansList.isEmpty) {
      List<int> incl = [ans];
      map["_ans"] = rowList.isNotEmpty ? rowList[ans] : ans;
      range = getRandomList(options.length, map["_range"], incl, []);
      excl.add(ans);
    }
    map["_ansInx"] = ans;
    // String question = configAgent.checkText("_Question", map);
    // map["_question"] = question;
    String o = options[0];
    isImg = o.contains(".png") || o.contains(".svg");
    eheight = isImg ? 0.12 * model.screenHeight : 0.07143 * model.screenHeight;
    ewidth = 0.345 * model.screenWidth;
    BoxDecoration decoration = isImg ? shadowRCDecoration : elemDecoration;
    Map<String, dynamic> childMap = {
      "_height": eheight,
      "_width": ewidth,
      "_alignment": Alignment.center,
      "_decoration": decoration,
      "_textStyle": choiceButnTxtStyle,
    };
    iepf = model.appActions.getPattern("ItemElem");
    tipf = model.appActions.getPattern("TapItem");
    for (int i in range) {
      childMap["_item"] = options[i];
      childMap["_index"] = i;
      Map<String, dynamic> tapAction = {
        "_event": "select",
        "_item": options[i],
        "_index": i
      };
      childMap["_tapAction"] = tapAction;
      childMap["_child"] = iepf(childMap);
      ProcessEvent pe = ProcessEvent("fsm");
      childMap["_onTap"] = pe;
      ProcessPattern pp = tipf(childMap);
      children.add(pp);
      elemList.add(0);
    }
  }

  @override
  reset(bool startNew) {
    excl = startNew ? [] : excl;
    setup();
    gvNoti.value = children;
    view = mvcpf(map);
  }

  @override
  String doAction(String action, Map<String, dynamic> emap) {
    int inx = emap["_index"];
    switch (action) {
      case "Selection":
        swapChoiceElem(inx);
        break;
      case "CheckAns":
        String r;
        map["_state"] = "confirmed";
        if (ansList.isEmpty) {
          if (range[currSel] == ans) {
            r = "correct";
          } else {
            r = "incorrect";
          }
          buildBadgedElem(range[currSel], r);
        } else {
          r = "correct";
          for (int k in selList) {
            if (ansList.contains(options[k])) {
              buildBadgedElem(k, "correct");
            } else {
              buildBadgedElem(k, "incorrect");
              r = "incorrect";
            }
          }
          if (selList.length != ansList.length) {
            r = "incorrect";
          }
        }
        return r;
      case "ShowAnswer":
        if (ansList.isEmpty) {
          swapChoiceElem(range[currSel]);
          buildBadgedElem(ans, "answer");
        } else {
          for (int k in selList) {
            ProcessPattern pp = elemList[k];
            elemList[k] = children[k];
            children[k] = pp;
          }
          List<dynamic> c = children;
          for (int k = 0; k < options.length; k++) {
            if (ansList.contains(options[k])) {
              buildBadgedElem(k, "answer");
              children = gvNoti.value;
            }
          }
          children = c;
        }
        break;
      case "TryAgain":
        if (ansList.isEmpty) {
          swapChoiceElem(range[currSel]);
        } else {
          for (int k in selList) {
            ProcessPattern pp = elemList[k];
            elemList[k] = children[k];
            children[k] = pp;
          }
          selList = [];
        }
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

  swapChoiceElem(int i) {
    int ri = range.indexOf(i);
    if (elemList[ri] is int) {
      BoxDecoration decoration = isImg ? elemDecoration : selDecoration;
      Map<String, dynamic> childMap = {
        "_height": eheight,
        "_width": ewidth,
        "_alignment": Alignment.center,
        "_decoration": decoration,
        "_textStyle": selButnTxtStyle,
        "_item": options[i],
        "_index": i,
      };
      Map<String, dynamic> tapAction = {
        "_event": "select",
        "_item": options[i],
        "_index": i
      };
      childMap["_tapAction"] = tapAction;
      childMap["_child"] = iepf(childMap);
      ProcessEvent pe = ProcessEvent("fsm");
      childMap["_onTap"] = pe;
      ProcessPattern pp = tipf(childMap);
      elemList[ri] = children[ri];
      children[ri] = pp;
      if (ansList.isEmpty) {
        if (currSel >= 0) {
          ProcessPattern pp = elemList[currSel];
          elemList[currSel] = children[currSel];
          children[currSel] = pp;
        }
        currSel = ri;
      } else {
        selList.add(ri);
      }
      map["_state"] = "selected";
    } else {
      ProcessPattern pp = elemList[ri];
      elemList[ri] = children[ri];
      children[ri] = pp;
      if (ansList.isEmpty) {
        if (ri == currSel) {
          if (map["_state"] != "confirmed") {
            map["_state"] = "start";
          }
          currSel = -1;
        } else {
          map["_state"] = "selected";
          if (currSel >= 0) {
            ProcessPattern pp = elemList[currSel];
            elemList[currSel] = children[currSel];
            children[currSel] = pp;
          }
          currSel = ri;
        }
      } else {
        if (selList.contains(ri)) {
          selList.remove(ri);
        } else {
          selList.add(ri);
        }
        if (selList.isEmpty) {
          if (map["_state"] != "confirmed") {
            map["_state"] = "start";
          }
        } else {
          map["_state"] = "selected";
        }
      }
    }
    retry();
  }

  @override
  dynamic getAnswer() {
    return configAgent.checkText("_Answer_Text", map);
  }

  @override
  retry() {
    List<dynamic> c = [];
    c.addAll(children);
    children = c;
    gvNoti.value = children;
  }

  buildBadgedElem(int i, String type) {
    Map<String, dynamic> childMap = {
      "_height": eheight,
      "_width": ewidth,
      "_item": options[i],
      "_index": i,
      "_childInx": range.indexOf(i)
    };
    List<dynamic> c = [];
    c.addAll(children);
    buildBadgedElement(type, c, gvNoti, isImg, childMap);
  }

  @override
  int getHintIndex() {
    return ans;
  }
}
