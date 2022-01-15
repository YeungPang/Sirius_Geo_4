import 'package:flutter/material.dart';
import 'package:sirius_geo_4/agent/config_agent.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/builder/std_pattern.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/builder/get_pattern.dart';
import 'package:sirius_geo_4/resources/app_model.dart';
import 'package:sirius_geo_4/resources/basic_resources.dart';
import 'package:sirius_geo_4/resources/fonts.dart';

class SentenceMvc extends Mvc {
  SentenceMvc(Map<String, dynamic> map) : super(map);

  double bgHeight = 0.4926 * model.screenHeight;
  ConfigAgent configAgent;
  TextEditingController tc;
  List<dynamic> answers;
  List<dynamic> options;
  List<dynamic> ansList;
  List<dynamic> children;
  List<dynamic> col;
  List<dynamic> draggingList;
  List<dynamic> dragAnsList;
  List<dynamic> dragChildList;
  List<dynamic> targetList;
  List<dynamic> selectList;
  ValueNotifier<List<dynamic>> sentenceNoti;
  ValueNotifier<List<dynamic>> gvNoti;
  ValueNotifier<ProcessPattern> textNoti;
  Map<String, dynamic> imap;
  Map<String, dynamic> lmap;
  Function mvcpf;
  Function tipf;
  Function tpf = getPrimePattern["Text"];
  Function cpf = getPrimePattern["Container"];
  double childAspectRatio;
  double eheight;
  double ewidth;
  int selIndex = -1;
  int len;
  ProcessPattern view;
  ProcessPattern inTextPP;
  ProcessPattern editText;
  ProcessPattern holder;
  bool refresh = false;
  bool completed = false;
  String ctext;
  ProcessEvent pe;

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
    if (ansList == null) {
      ansList = configAgent.getElement(map["_Answer"], map, null);
      len = ansList.length;
      options = configAgent.getElement(map["_AnswerOptions"], map, null);
      col = [];
      imap = {
        "_text": map["_Descr"],
        "_textStyle": dragButnTxtStyle,
      };
      col.add(tpf(imap));
      eheight = 0.061576 * model.screenHeight; // 0.04926
      ewidth = 0.345 * model.screenWidth;
      ctext = map["_Sentence"];
      imap = {
        "_height": eheight,
        "_width": ewidth,
        "_boxConstraints": BoxConstraints(maxWidth: ewidth),
      };
      ProcessPattern cpp = cpf(imap);
      imap = {
        "_radius": 10.0,
        "_dottedColor": colorMap["btnBlue"],
        "_strokeWidth": 2.0,
        "_child": cpp
      };
      Function pf = getPrimePattern["DottedBorder"];
      holder = pf(imap);
      pe = ProcessEvent("fsm");
      tipf = getPrimePattern["TapItem"];
      List<dynamic> wc = buildSentence();
      sentenceNoti = ValueNotifier<List<dynamic>>(wc);
      imap = {"_runSpacing": 5.0, "_spacing": 5.0};
      pf = getPrimePattern["Wrap"];
      ProcessPattern pp = pf(imap);
      imap = {"_notifier": sentenceNoti, "_child": pp};
      pf = getPrimePattern["ValueTypeListener"];
      col.add(pf(imap));
      pf = getPrimePattern["Column"];
      imap = {
        "_mainAxisAlignment": MainAxisAlignment.spaceBetween,
        "_children": col
      };
      pp = pf(imap);
      imap = {"_height": 0.20 * model.screenHeight, "_child": pp};
      pf = getPrimePattern["SizedBox"];
      col = [];
      col.add(pf(imap));
      if (options == null) {
        tc = TextEditingController();
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
          "_clear": true,
          "_width": 0.666667 * model.screenWidth,
          "_alignment": Alignment.center,
          "_inputBorder": textFieldBorder,
          "_textStyle": choiceButnTxtStyle,
          "_hintStyle": choiceButnTxtStyle,
          "_complete": cpe,
          "_incomplete": ipe,
          "_retainFocus": true,
          "_textEditingController": tc
        };
        pf = getPrimePattern["InTextField"];
        pp = pf(imap);
        imap["_child"] = pp;
        inTextPP = cpf(imap);
        double w = 0.826667 * model.screenWidth;
        imap = {
          "_width": w,
          "_height": 0.1600985 * model.screenHeight,
          "_alignment": Alignment.center,
          "_decoration": shadowRCDecoration
        };
        imap["_child"] = inTextPP;
        pp = cpf(imap);
        textNoti = ValueNotifier<ProcessPattern>(inTextPP);
        imap = {"_notifier": textNoti, "_child": pp};
        pf = getPrimePattern["ValueTypeListener"];
        pp = pf(imap);
        col.add(pp);
      } else {
        pp = buildGridView();
        col.add(pp);
      }
      // pf = getPrimePattern["Column"];
      // imap = {"_children": col};
      map["_colElem"] = col;
      mvcpf ??= model.appActions.getPattern("MvcColumn");
      view = mvcpf(map);
    } else {
      List<dynamic> wc = buildSentence();
      sentenceNoti.value = wc;
      if (refresh) {
        mvcpf ??= model.appActions.getPattern("MvcColumn");
        view = mvcpf(map);
      }
      if (tc != null) {
        tc.clear();
      }
    }
  }

  ProcessPattern buildGridView() {
    draggingList = [];
    dragAnsList = [];
    dragChildList = [];
    selectList = [];
    children = [];
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

    Function dpf = getPrimePattern["Draggable"];
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
    }
    children.addAll(dragChildList);
    gvNoti = createNotifier(children);

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
    lmap = {"_notifier": gvNoti, "_child": gv};
    pf = getPrimePattern["ValueTypeListener"];
    imap = {
      "_width": 0.8267 * model.screenWidth,
      "_height": eheight * children.length / 2 +
          mainAS * (children.length / 2.0 + 1.5),
      "_alignment": Alignment.center,
      "_decoration": shadowRCDecoration,
      "_child": pf(lmap)
    };
    pf = getPrimePattern["Container"];
    return pf(imap);
  }

  List<dynamic> buildSentence() {
    int inx = 0;
    int i = 0;
    Function dpf = getPrimePattern["DragTarget"];
    List<dynamic> wc = [];
    targetList = [];
    while (inx < ctext.length) {
      int inx2 = ctext.indexOf('#', inx);
      String txt;
      if (inx2 < 0) {
        txt = ctext.substring(inx);
      } else {
        txt = ctext.substring(inx, inx2);
      }
      imap = {
        "_text": txt,
        "_textStyle": dragButnTxtStyle,
      };
      wc.add(tpf(imap));
      if (inx2 < 0) {
        break;
      }
      inx = inx2 + 1;
      if (inx < ctext.length) {
        inx2 = ctext.indexOf('#', inx);
        if (inx2 > 0) {
          Map<String, dynamic> tapAction = {
            "_event": "select",
            "_index": i,
            "_item": "target"
          };
          imap = {"_child": holder, "_onTap": pe, "_tapAction": tapAction};
          ProcessPattern pp = tipf(imap);
          if (options != null) {
            ProcessEvent dpe = ProcessEvent("fsm");
            dpe.map = {"_dropIndex": i};
            imap = {"_target": pp, "_dropAction": dpe};
            pp = dpf(imap);
          }
          targetList.add(pp);
          wc.add(pp);
          answers.add("");
          inx = inx2 + 1;
        }
      }
      i++;
    }
    return wc;
  }

  List<dynamic> rebuildSentence(
      int inx, ProcessPattern elem, List<dynamic> wc) {
    int i = 0;
    List<dynamic> nwc = [];
    for (ProcessPattern pp in wc) {
      if (pp is! TextPattern) {
        pp = (i == inx) ? elem : pp;
        nwc.add(pp);
        i++;
      } else {
        nwc.add(pp);
      }
    }
    return nwc;
  }

  @override
  reset(bool startNew) {
    refresh = true;
    init();
  }

  @override
  String doAction(String action, Map<String, dynamic> emap) {
    switch (action) {
      case "Editing":
        int i = 0;
        if (selIndex == -1) {
          while ((answers[i] != "") && (i < answers.length)) {
            i++;
          }
          answers[i] = tc.text;
        } else {
          i = selIndex;
          answers[selIndex] = tc.text;
        }
        imap = {
          "_decoration": elemDecoration,
          "_textStyle": choiceButnTxtStyle,
          "_index": i,
          "_item": tc.text,
        };
        ProcessPattern ep =
            getTapItemElemPattern("select", eheight, ewidth, imap);
        sentenceNoti.value = rebuildSentence(i, ep, sentenceNoti.value);
        completed = true;
        for (String s in answers) {
          if (s.isEmpty) {
            completed = false;
            break;
          }
        }
        if (completed) {
          map["_state"] = "completed";
          if (editText == null) {
            imap = {
              "_text": model.map["text"]["editText"],
              "_textStyle": mediumNormalTextStyle
            };
            editText = tpf(imap);
          }
          textNoti.value = editText;
        } else {
          map["_state"] = "incomplete";
        }
        selIndex = -1;
        break;
      case "Empty":
        if (selIndex == -1) {
          int i = 0;
          while ((answers[i] != "") && (i < answers.length)) {
            i++;
          }
          selIndex = i;
        }
        tc.text = answers[selIndex];
        break;
      case "Selection":
        int inx = emap["_index"];
        if (options == null) {
          if (inx != selIndex) {
            imap = {
              "_decoration": selDecoration,
              "_textStyle": selButnTxtStyle,
              "_index": inx,
              "_item": answers[inx],
            };
            ProcessPattern ep =
                getTapItemElemPattern("select", eheight, ewidth, imap);
            List<dynamic> wc = sentenceNoti.value;
            wc = rebuildSentence(inx, ep, wc);
            if (selIndex > -1) {
              if (answers[selIndex] == "") {
                ep = targetList[selIndex];
              } else {
                imap = {
                  "_decoration": elemDecoration,
                  "_textStyle": choiceButnTxtStyle,
                  "_index": selIndex,
                  "_item": answers[selIndex],
                };
                ep = getTapItemElemPattern("select", eheight, ewidth, imap);
              }
              wc = rebuildSentence(selIndex, ep, wc);
            }
            sentenceNoti.value = wc;
            selIndex = inx;
            tc.text = answers[inx];
            if (map["_state"] == "completed") {
              map["_state"] = "incomplete";
              textNoti.value = inTextPP;
            }
          } else {
            if (completed) {
              map["_state"] = "completed";
              if (editText == null) {
                imap = {
                  "_text": model.map["text"]["editText"],
                  "_textStyle": mediumNormalTextStyle
                };
                editText = tpf(imap);
              }
              textNoti.value = editText;
            }
            ProcessPattern ep;

            if (answers[selIndex] == "") {
              ep = targetList[selIndex];
            } else {
              imap = {
                "_decoration": elemDecoration,
                "_textStyle": choiceButnTxtStyle,
                "_index": selIndex,
                "_item": answers[selIndex],
              };
              ep = getTapItemElemPattern("select", eheight, ewidth, imap);
            }
            sentenceNoti.value =
                rebuildSentence(selIndex, ep, sentenceNoti.value);
            selIndex = -1;
            tc.clear();
          }
        } else {
          if (selIndex == -1) {
            if (emap["_item"] == "target") {
              break;
            }
            selIndex = inx;
            String text = options[inx];
            int ix = answers.indexOf(text);
            if (ix >= 0) {
              sentenceNoti.value =
                  rebuildSentence(ix, draggingList[inx], sentenceNoti.value);
              break;
            } else {
              ix = children.indexOf(dragChildList[inx]);
              if (ix >= 0) {
                children[ix] = draggingList[inx];
              }
            }
          } else {
            if (emap["_item"] == "target") {
              swap(selIndex, inx);
            } else {
              String text = options[selIndex];
              int ix = answers.indexOf(text);
              List<dynamic> wc = sentenceNoti.value;
              if (ix >= 0) {
                wc = rebuildSentence(ix, dragAnsList[selIndex], wc);
              } else {
                ix = children.indexOf(draggingList[selIndex]);
                if (ix >= 0) {
                  children[ix] = dragChildList[selIndex];
                }
              }
              if (selIndex != inx) {
                text = options[inx];
                ix = answers.indexOf(text);
                if (ix >= 0) {
                  wc = rebuildSentence(ix, draggingList[inx], wc);
                } else {
                  ix = children.indexOf(dragChildList[inx]);
                  if (ix >= 0) {
                    children[ix] = draggingList[inx];
                  }
                }
                selIndex = inx;
              } else {
                selIndex = -1;
              }
              sentenceNoti.value = wc;
            }
          }
          List<dynamic> c = [];
          c.addAll(children);
          gvNoti.value = c;
        }
        break;
      case "DropSel":
        swap(emap["_index"], emap["_dropIndex"]);
        break;
      case "CheckAns":
        bool cor = true;
        List<dynamic> c = [];
        c.addAll(sentenceNoti.value);
        int ix = 0;
        map["_state"] = "confirmed";
        for (int i = 0; i < ansList.length; i++) {
          String r = "correct";
          if (answers[i].toLowerCase() != ansList[i].toString().toLowerCase()) {
            r = "incorrect";
            cor = false;
          }
          while ((ix < c.length) && (c[ix] is TextPattern)) {
            ix++;
          }
          buildBadgedElem(i, ix++, r, c);
        }
        sentenceNoti.value = c;
        if (cor) {
          return "correct";
        } else {
          return "incorrect";
        }
        break;
      case "ShowAnswer":
        answers = ansList;
        List<dynamic> c = [];
        c.addAll(sentenceNoti.value);
        int ix = 0;
        for (int i = 0; i < answers.length; i++) {
          while ((ix < c.length) && (c[ix] is TextPattern)) {
            ix++;
          }
          buildBadgedElem(i, ix++, "answer", c);
        }
        sentenceNoti.value = c;
        break;
      case "TryAgain":
        break;
      default:
        break;
    }
    return action;
  }

  swap(int inx, int dinx) {
    List<dynamic> sl = sentenceNoti.value;
    ProcessPattern tp = targetList[dinx];
    ProcessPattern ap = dragAnsList[inx];
    ProcessPattern dp = draggingList[inx];
    List<dynamic> wc = [];
    bool swapped = false;
    int pos = 0;
    for (int i = 0; i < sl.length; i++) {
      if (sl[i] is! TextPattern) {
        if (sl[i] == tp) {
          wc.add(ap);
          answers[pos] = options[inx];
          int ix = children.indexOf(dragChildList[inx]);
          if (ix < 0) {
            ix = children.indexOf(draggingList[inx]);
          }
          if (ix >= 0) {
            children[ix] = tp;
          }
          completed = true;
          for (String s in answers) {
            if (s.isEmpty) {
              completed = false;
              break;
            }
          }
          if (completed) {
            map["_state"] = "completed";
          }
          swapped = true;
        } else if ((sl[i] == ap) || (sl[i] == dp)) {
          swapped = true;
          wc.add(tp);
          answers[pos] = "";
          map["_state"] = "incomplete";
          completed = false;
          int ix = children.indexOf(tp);
          if (ix >= 0) {
            children[ix] = dragChildList[inx];
          }
        } else {
          wc.add(sl[i]);
        }
        pos++;
      } else {
        wc.add(sl[i]);
      }
    }
    if (swapped) {
      selIndex = -1;
    }
    sentenceNoti.value = wc;
    List<dynamic> c = [];
    c.addAll(children);
    gvNoti.value = c;
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
    List<dynamic> wc = sentenceNoti.value;
    map["_state"] = "incomplete";
    answers = [];
    for (int i = 0; i < ansList.length; i++) {
      wc = rebuildSentence(i, targetList[i], wc);
      answers.add("");
    }
    sentenceNoti.value = wc;
    selIndex = -1;
    if (options == null) {
      textNoti.value = inTextPP;
    } else {
      children = [];
      children.addAll(dragChildList);
      gvNoti.value = children;
    }
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
}
