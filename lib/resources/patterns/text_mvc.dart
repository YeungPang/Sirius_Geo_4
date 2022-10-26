import 'package:flutter/material.dart';
import '../../agent/config_agent.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../../builder/get_pattern.dart';
import '../app_model.dart';
import '../basic_resources.dart';
import '../fonts.dart';
import 'package:get/get.dart';

class TextMvc extends Mvc {
  TextMvc(Map<String, dynamic> map) : super(map);

  List<int> excl = [];
  double bgHeight = 0.4926 * model.scaleHeight;
  late ProcessPattern view;
  ConfigAgent? configAgent;
  Rx<ProcessPattern>? textNoti;
  TextEditingController tc = TextEditingController();
  late List<dynamic> answers;
  List<dynamic>? options;
  late List<dynamic> ansList;
  List<dynamic>? acceptedList;
  List<dynamic>? elemList;
  List<dynamic>? checkList;
  Map<String, dynamic> imap = {};
  Map<String, dynamic> lmap = {};
  List<dynamic>? children;
  Function? mvcpf;
  Function tipf = getPrimePattern["Text"]!;
  Rx<List<dynamic>>? gvNoti;
  double? childAspectRatio;
  bool multi = false;
  double eheight = 0.0;
  double ewidth = 0.0;
  Function cpf = getPrimePattern["Container"]!;
  int selIndex = -1;
  int len = 0;
  ProcessPattern? inTextPP;
  ProcessPattern? editText;
  bool retrying = false;
  bool refresh = false;
  //Map<String, dynamic> equi = model.map["equivalence"];
  List<int> rowList = [];
  int ans = 0;
  int ansLen = 0;
  List<int> mAnsList = [0];
  List<dynamic>? nAnsList;

  @override
  double getBgHeight() {
    return bgHeight;
  }

  @override
  init() {
    selIndex = -1;
    map["_state"] = "incomplete";
    answers = [];
    configAgent ??= map["_configAgent"];
    String answer = map["_Answer"].toString();
/*     if (answer[0] == 'ℛ') {
      answer = configAgent!.getElement(map["_Answer"], map);
    } */
    if (answer.contains("_ans")) {
      if (!retrying) {
        options = configAgent!
            .getElement(map["_AnswerOptions"], map, rowList: rowList);
        ans = getRandom(options!.length, excl)!;
        excl.add(ans);
        map["_ans"] = rowList.isNotEmpty ? rowList[ans] : ans;
        var oa = options![ans];
        if ((oa is String) && (oa.isNotEmpty) && (oa[0] == '[')) {
          ansList = getListData(oa);
        } else {
          ansList = (oa is List<dynamic>) ? oa : [oa];
        }
        ansLen = ansList.length;
        dynamic ra = map["_range"];
        if (ra is String) {
          ra = configAgent!.getElement("_range", map);
        }
        len = ra ?? ansLen;
/*         if ((acceptedList != null) && (acceptedList!.isNotEmpty)) {
          checkList = null;
          List<dynamic> al = acceptedList![ans];
          for (var va in al) {
            String a = va.toString();
            if (a.isNotEmpty) {
              ansList.add(a.trim());
            }
          }
        } */
        checkList = null;
      }
    } else {
      refresh = false;
      var al = configAgent!.getElement(map["_Answer"], map);
      ansList = (al is List<dynamic>)
          ? resolveList(al, map, configAgent: configAgent)!
          : [al];
      ansLen = ansList.length;
      dynamic ra = map["_range"];
      if (ra is String) {
        ra = configAgent!.getElement("_range", map);
      }
      len = ra ?? ansLen;
    }
    if ((!retrying) && (map["_Accepted_Answers"] != null)) {
      acceptedList = [];
      if (len > 1) {
        var vml = configAgent!.getElement(map["_Accepted_Answers"], map);
        Map<String, dynamic>? am;
        List<dynamic>? lm;
        if (vml is List<dynamic>) {
          lm = resolveList(vml, map, configAgent: configAgent);
        } else {
          am = vml;
        }
        nAnsList = [];
        int i = 0;
        for (var sv in ansList) {
          String s = sv.toString().trim();
          nAnsList!.add(s);
          if (am != null) {
            String? v = am[s];
            if (v != null) {
              if (v[0] == '[') {
                List<dynamic> rList =
                    configAgent!.getListContent(v, null, map, null, null);
                nAnsList!.addAll(rList);
              } else if (v[0] == 'ℛ') {
                dynamic rList = configAgent!.getElement(v, map);
                if (rList is List<dynamic>) {
                  nAnsList!.addAll(rList);
                } else {
                  nAnsList!.add(rList);
                }
              } else {
                nAnsList!.add(v);
              }
            }
          } else {
            List<dynamic> ld = lm![i++];
            if (ld.isNotEmpty) {
              nAnsList!.addAll(ld);
            }
          }
          mAnsList.add(nAnsList!.length);
        }
      } else {
        nAnsList = null;
        dynamic rList = configAgent!.getElement(map["_Accepted_Answers"], map);
        rList = (rList is List<dynamic>)
            ? resolveList(rList, map, configAgent: configAgent)
            : rList;
        if (rList is List<dynamic>) {
          for (var r in rList) {
            if (r is List<dynamic>) {
              acceptedList!.addAll(r);
            } else {
              acceptedList!.add(r);
            }
          }
        } else {
          acceptedList!.add(rList);
        }
      }
      for (var al in acceptedList!) {
        if (al is List<dynamic>) {
          for (var va in al) {
            String a = va.toString();
            if (a.isNotEmpty) {
              ansList.add(a.trim());
            }
          }
        } else {
          ansList.add(al.toString().trim());
        }
      }
    }
    retrying = false;
    //if (inTextPP == null) {
    if (map["_Q_Image"] == null) {
      bgHeight = 0.8 * bgHeight;
    }
    multi = len > 1;
    map["_textEditingController"] = tc;
    ProcessEvent cpe = ProcessEvent("fsm");
    cpe.map = {
      "_event": "edited",
    };
    ProcessEvent ipe = ProcessEvent("fsm");
    ipe.map = {
      "_event": "empty",
    };
    imap = {
      "_hintText": model.map["text"]["typeAnswer"],
      "_clear": multi,
      "_width": 0.666667 * model.scaleWidth,
      "_alignment": Alignment.center,
      "_inputBorder": textFieldBorder,
      "_textStyle": choiceButnTxtStyle,
      "_hintStyle": choiceButnTxtStyle,
      "_complete": cpe,
      "_incomplete": ipe,
      "_retainFocus": multi,
      "_textEditingController": tc
    };
    Function pf = getPrimePattern["InTextField"]!;
    ProcessPattern pp = pf(imap);
    imap["_child"] = pp;
    inTextPP = cpf(imap);
    double w = 0.826667 * model.scaleWidth;
    imap = {
      "_width": w,
      "_height": 0.1600985 * model.scaleHeight,
      "_alignment": Alignment.center,
      "_decoration": shadowRCDecoration
    };
    if (!multi) {
      imap["_child"] = inTextPP;
    }
    pp = cpf(imap);

    if (multi) {
      textNoti = resxController.addToResxMap("textNoti", inTextPP)
          as Rx<ProcessPattern>;
      imap = {"_valueName": "textNoti", "_child": pp};
      pf = getPrimePattern["Obx"]!;
      pp = pf(imap);
      eheight = 0.07143 * model.scaleHeight;
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
      pf = getPrimePattern["DottedBorder"]!;
      cpp = pf(imap);
      elemList = [];
      for (int j = 0; j < len; j++) {
        elemList!.add(cpp);
      }
      children = [];
      children!.addAll(elemList!);
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
      pf = getPrimePattern["GridView"]!;
      ProcessPattern gv = pf(imap);
      lmap = {"_valueName": "gv", "_child": gv};
      pf = getPrimePattern["Obx"]!;
      int l = (len + 1) ~/ 2;
      imap = {
        "_width": w,
        "_height": (eheight + mainAS) * l + mainAS * 1.5,
        "_alignment": Alignment.center,
        "_decoration": shadowRCDecoration,
        "_child": pf(lmap)
      };
      pf = getPrimePattern["Container"]!;
      lmap = {
        "_height": 0.04 * model.scaleHeight,
      };
      Function sp = getPrimePattern["SizedBox"]!;
      List<ProcessPattern> col = [pp, sp(lmap), pf(imap)];
      pf = getPrimePattern["Column"]!;
      imap = {"_children": col};
      map["_colElem"] = pf(imap);
      mvcpf ??= model.appActions.getPattern("MvcColumn")!;
      view = mvcpf!(map);
    } else {
      map["_colElem"] = pp;
      mvcpf ??= model.appActions.getPattern("MvcColumn");
      view = mvcpf!(map);
    }
/*     } else {
      if (multi) {
        children = [];
        children!.addAll(elemList!);
        gvNoti!.value = children!;
        textNoti!.value = inTextPP!;
      } else if (refresh) {
        mvcpf ??= model.appActions.getPattern("MvcColumn");
        view = mvcpf!(map);
      }
      tc.clear();
    } */
  }

  @override
  reset(bool startNew) {
    excl = startNew ? [] : excl;
    refresh = true;
    init();
  }

  @override
  String doAction(String action, Map<String, dynamic>? emap) {
    switch (action) {
      case "Editing":
        int i;
        if (selIndex == -1) {
          i = answers.length;
          answers.add(tc.text);
        } else {
          i = selIndex;
          answers[selIndex] = tc.text;
        }
        if (len > 1) {
          imap = {
            "_decoration": elemDecoration,
            "_textStyle": choiceButnTxtStyle,
            "_index": i,
            "_item": tc.text,
          };
          ProcessPattern ep =
              getTapItemElemPattern("select", eheight, ewidth, imap);
          children![i] = ep;
          List<dynamic> c = [];
          c.addAll(children!);
          gvNoti!.value = c;
          if (answers.length == len) {
            map["_state"] = "completed";
            if (editText == null) {
              imap = {
                "_text": model.map["text"]["editText"],
                "_textStyle": mediumNormalTextStyle
              };
              editText = tipf(imap);
            }
            textNoti!.value = editText!;
          } else {
            map["_state"] = "incomplete";
          }
          selIndex = -1;
        } else {
          map["_state"] = "completed";
        }
        break;
      case "Empty":
        if (len > 1) {
          if (selIndex == -1) {
            selIndex = answers.length - 1;
          }
          tc.text = answers[selIndex];
        } else {
          map["_state"] = "incomplete";
        }
        break;
      case "Selection":
        int inx = emap!["_index"];
        if (inx != selIndex) {
          imap = {
            "_decoration": selDecoration,
            "_textStyle": selButnTxtStyle,
            "_index": inx,
            "_item": answers[inx],
          };
          ProcessPattern ep =
              getTapItemElemPattern("select", eheight, ewidth, imap);
          children![inx] = ep;
          if (selIndex > -1) {
            imap = {
              "_decoration": elemDecoration,
              "_textStyle": choiceButnTxtStyle,
              "_index": selIndex,
              "_item": answers[selIndex],
            };
            children![selIndex] =
                getTapItemElemPattern("select", eheight, ewidth, imap);
          }
          selIndex = inx;
          tc.text = answers[inx];
          if (map["_state"] == "completed") {
            map["_state"] = "incomplete";
            textNoti!.value = inTextPP!;
          }
        } else {
          if (answers.length == len) {
            map["_state"] = "completed";
            if (editText == null) {
              imap = {
                "_text": model.map["text"]["editText"],
                "_textStyle": mediumNormalTextStyle
              };
              editText = tipf(imap);
            }
            textNoti!.value = editText!;
          }
          imap = {
            "_decoration": elemDecoration,
            "_textStyle": choiceButnTxtStyle,
            "_index": selIndex,
            "_item": answers[selIndex],
          };
          children![selIndex] =
              getTapItemElemPattern("select", eheight, ewidth, imap);
          selIndex = -1;
          tc.clear();
        }
        List<dynamic> c = [];
        c.addAll(children!);
        gvNoti!.value = c;
        break;
      case "CheckAns":
        String r;
        map["_state"] = "confirmed";
        if (checkList == null) {
          checkList = [];
          List<dynamic> al = (nAnsList == null) ? ansList : nAnsList!;
          for (int i = 0; i < al.length; i++) {
            checkList!.add(al[i].toString().trim().toLowerCase());
          }
        }
        if (len == 1) {
          String ansText = tc.text.trim().toLowerCase();
          //ansText = equi[ansText] ?? ansText;
          if (checkList!.contains(ansText)) {
            return "correct";
          } else {
            return "incorrect";
          }
        }
        List<int> dl = [];
        List<dynamic> c = [];
        c.addAll(children!);
        int alen = 0;
        if (answers.length == len) {
          for (int i = 0; i < len; i++) {
            String ansText = answers[i].toString().toLowerCase();
            //ansText = equi[ansText] ?? ansText;
            int inx = checkList!.indexOf(ansText);
            if (inx < 0) {
              r = "incorrect";
            } else {
              if (dl.contains(inx)) {
                r = "incorrect";
              } else {
                alen++;
                r = "correct";
                if (nAnsList == null) {
                  dl.add(inx);
                } else {
                  int si = 0;
                  while (mAnsList[si + 1] <= inx) {
                    si++;
                  }
                  int sn = mAnsList[si + 1];
                  si = mAnsList[si];
                  for (int i = si; i < sn; i++) {
                    dl.add(i);
                  }
                }
              }
            }
            buildBadgedElem(i, r, c);
          }
        }
        if (alen == len) {
          return "correct";
        }
        return "incorrect";
      case "ShowAnswer":
        if (multi) {
          answers = ansList;
          List<dynamic> c = [];
          c.addAll(children!);
          for (int i = 0; i < c.length; i++) {
            buildBadgedElem(i, "answer", c);
          }
        }
        break;
      case "TryAgain":
        answers = [];
        retrying = true;
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
    if (map["_Answer_Text"] != null) {
      return configAgent!.checkText("_Answer_Text", map);
    }
    List<dynamic> aList = [];
    for (int i = 0; i < ansLen; i++) {
      aList.add(ansList[i]);
    }
    return aList;
  }

  @override
  retry() {
    retrying = true;
    init();
  }

  buildBadgedElem(int i, String type, List<dynamic> c) {
    Map<String, dynamic> childMap = {
      "_height": eheight,
      "_width": ewidth,
      "_item": answers[i],
      "_index": i,
      "_childInx": i
    };
    //if (i == (c.length - 1)) {
    buildBadgedElement(type, c, gvNoti, false, childMap);
    //} else {
    //buildBadgedElement(type, c, null, false, childMap);
    //}
  }

  @override
  int getHintIndex() {
    return ans;
  }
}
