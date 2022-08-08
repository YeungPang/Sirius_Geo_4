import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './config_agent.dart';
import '../builder/pattern.dart';
import '../resources/app_model.dart';
import '../model/locator.dart';
import '../builder/get_pattern.dart';
import '../resources/basic_resources.dart';
import '../resources/fonts.dart';
import '../resources/patterns/hint_bubble.dart';
import 'dart:async';

class MvcAgent extends Agent {
  Map<String, dynamic>? currMv;

  Mvc? currMvc;
  Agent? agent;
  ProcessPattern? nextBtnPat;
  ProcessPattern? failBtnPat;
  ProcessPattern? btnPat;
  ProcessPattern? sizedPat;
  double resDialWidth = 0.9333 * model.scaleWidth;
  double resDialHeight = 0.1823 * model.scaleHeight;
  String? image;
  Map<String, dynamic> text = model.map["text"];
  Map<String, dynamic> userProfile = model.map["userProfile"];
  Rx<List<dynamic>>? stackNoti;
  RxDouble? confirmNoti;
  int liveTime = model.map["liveGenTime"];
  RxString? timeNoti;
  int? timing;
  Timer? timer;
  bool liveTimeOn = false;
  int timeDuration = 1;
  ProcessPattern? bgLayout;
  ProcessPattern? incompleteProg;
  ProcessPattern? completeProg;
  ProcessPattern? incorrProg;
  ProcessPattern? space20;
  ProcessPattern? space10;
  ProcessPattern? space5;
  ProcessPattern? hint;
  ProcessPattern? quitDialog;
  Function cpf = getPrimePattern["Container"]!;
  Function tpf = getPrimePattern["Text"]!;
  List<String>? hints;
  int currHint = 0;
  bool hintShowed = false;
  int configLives = model.map["userProfile"]["configLives"];
  int maxconfigLives = model.map["maxConfigLives"];
  bool limit = true;
  //int configLives = model.map["userProfile"]["lives"];

  init() {
    limit = userProfile["userType"] == "User";
    if (limit) {
      if (configLives < maxconfigLives) {
        configLives = maxconfigLives;
      }
      int lives = userProfile["lives"];
      if (lives < configLives) {
        int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        int un = userProfile["liveTimestamp"];
        int timediff = now - un;
        int l = timediff ~/ liveTime;
        lives += l;
        if (lives > configLives) {
          lives = configLives;
        }
        userProfile["lives"] = lives;
        userProfile["liveTimestamp"] = now;
        resxController.setRxValue("lives", lives.toString());
      }
      if (lives < configLives) {
        timer = Timer.periodic(
            Duration(seconds: liveTime), (timer) => _updateTime());
      }
    } else {
      resxController.setRxValue("lives", '∞');
    }
  }

  @override
  dynamic process(ProcessEvent event) {
    switch (event.name) {
      case "newMvc":
        currMv = {};
        currMv!.addAll(event.map!);
        stackNoti = null;
        confirmNoti ??= resxController.addToResxMap("confirm", 0.5) as RxDouble;
        return createNew(0);
      case "add":
        if (currMv != null) {
          currMv!.addAll(event.map!);
          return true;
        }
        return false;
      case "progRow":
        return getProgRow();
      case "showHint":
        if (hintShowed) {
          break;
        }
        List<dynamic>? hintList = currMv!["_hintList"];
        if (hintList == null) {
          ConfigAgent configAgent = currMv!["_configAgent"];
          hintList = configAgent.getElement(currMv!["_hints"], currMv!,
              map: model.map["hints"]);
          currMv!["_hintList"] = hintList;
        }
        int inx = currMvc!.getHintIndex();
        String hintStr = hintList![inx];
        hints = hintStr.split(";");
        currHint = 0;
        setHint(event.name);
        break;
      case "prevHint":
      case "nextHint":
      case "cancelHint":
        setHint(event.name);
        break;
      case "quitDialog":
        quitDialog ??= getQuitDialog();
        return quitDialog;
      case "subscription":
        currMv = event.map;
        String e = currMv!["_event"];
        Function pf = getPrimePattern["Align"]!;
        Map<String, dynamic> imap = {
          "_child": _buildDialog(e),
          "_alignment": const Alignment(0.0, 0.1),
        };
        List<dynamic> l1 = resxController.getRxValue("mvcStack");
        List<dynamic> l = [];
        l.add(l1[0]);
        if (e == "unsubscribed") {
          userProfile["userType"] = "User";
          userProfile["renew"] = "";
          userProfile["lives"] = maxconfigLives;
          resxController.setRxValue("lives", maxconfigLives.toString());
          limit = true;
          model.versionAgent.saveProfile();
        } else if (e.contains("Subscribe")) {
          userProfile["userType"] = e[0] + "Subscriber";
          userProfile["renew"] = currMv!["_time"];
          resxController.setRxValue("lives", '∞');
          if (timer != null) {
            timer!.cancel();
            timer = null;
          }
          limit = false;
          model.versionAgent.saveProfile();
        }
        l.add(pf(imap));
        resxController.setRxValue("mvcStack", l);
        break;
      case "fsm":
        agent = agent ?? model.appActions.getAgent("pattern");
        String mvcName = currMv!["_Q_Pattern_Name"] + "fsm";
        if (clauses[mvcName] == null) {
          mvcName = "fsmPat";
        }
        ProcessEvent ievent = ProcessEvent(mvcName);
        ievent.map = {"_state": currMv!["_state"]};
        if (event.map != null) {
          ievent.map!.addAll(event.map!);
        }
        String? r = agent!.process(ievent);
        if ((r != null) && (r != 'Ø')) {
          r = currMvc!.doAction(r, event.map);
          switch (r) {
            case "Selection":
            case "Editing":
            case "Empty":
            case "DropSel":
              if ((currMv!["_state"] == "selected") ||
                  (currMv!["_state"] == "completed")) {
                confirmNoti!.value = 1.0;
              } else {
                confirmNoti!.value = 0.5;
              }
              break;
            case "TryAgain":
              List<int> il = currMv!["_prog"];
              if (il.last == 2) {
                il.last = -2;
              } else {
                il.last = -1;
              }
              currMv!["_state"] = "start";
              confirmNoti!.value = 0.5;
              currMvc!.retry();
              replaceLast(null);
              break;
            case "correct":
            case "almost":
            case "pass":
              List<int> il = currMv!["_prog"];
              if ((il.isEmpty) || ((il.last != -1) && (il.last != -2))) {
                il.add(1);
              } else if (il.last != -2) {
                il.last = 0;
              } else {
                il.last = 2;
              }
              updateProg();
              if (r == "pass") {
                nextGame();
              } else {
                buildResultDialog(r);
              }
              updateProg();
              break;
            case "incorrect":
              List<int> il = currMv!["_prog"];
              if ((il.isEmpty) || ((il.last != -1) && (il.last != -2))) {
                il.add(0);
                int lives = userProfile["lives"];
                if (limit && (lives > 0)) {
                  r = "lostLife";
                  userProfile["lives"] = --lives;
                  resxController.setRxValue("lives", lives.toString());
                  if (timer == null) {
                    timer = Timer.periodic(
                        Duration(seconds: liveTime), (timer) => _updateTime());
                    userProfile["liveTimestamp"] =
                        DateTime.now().millisecondsSinceEpoch ~/ 1000;
                  }
                  model.versionAgent.saveProfile();
                }
              } else if (il.last != -2) {
                il.last = 0;
              } else {
                il.last = 2;
              }
              buildResultDialog(r);
              updateProg();
              break;
            case "ShowAnswer":
              replaceLast(null);
              buildResultDialog(r);
              break;
            case "NextGame":
              replaceLast(null);
              confirmNoti!.value = 0.5;
              nextGame();
              break;
            case "GameDone":
              bool scoreMark = currMv!["_scoreMark"] ?? false;
              if (scoreMark) {
                setProgress(currMv!["_progId"]);
              }
              currMvc = null;
              currMv = null;
              model.appActions.doFunction("popRoute", null, null);
              break;
            case "RepeatGame":
              // currMv["_state"] = "start";
              // List<int> il = [];
              // currMv["_prog"] = il;
              // currMvc.reset(true);
              createNew(0);
              updateProg();
              // List<dynamic> stackList = [bgLayout, currMvc.getPattern()];
              // stackNoti.value = stackList;
              break;
            case "Cancel":
              currMvc = null;
              currMv = null;
              liveTimeOn = false;
              model.appActions.doFunction("popRoute", null, null);
              break;
            case "Continue":
              replaceLast(null);
              break;
            default:
              break;
          }
        }
        break;
      default:
        break;
    }
    return null;
  }

  ProcessPattern? createNew(int it) {
    currMv!["_state"] = "start";
    currMv!["_subTitle"] = null;
    currMv!["_scoreMark"] = null;
    currMv!["_mapping"] = null;
    hintShowed = false;
    currHint = 0;
    if (it == 0) {
      List<int> il = [];
      currMv!["_prog"] = il;
      currMv!["_hintList"] = null;
    }
    List<dynamic> itemRef = currMv!["_itemRef"];
    List<dynamic> item = itemRef[it];
    Map<String, dynamic> itemRefMap = currMv!["_itemRefMap"];
    var mheader = itemRefMap["header"];
    List<dynamic> header = (mheader is String) ? mheader.split(";") : mheader;
    List<dynamic> input = [header, item];
    model.appActions.doFunction("mapPat", input, currMv);
    String mvcName = currMv!["_Q_Pattern_Name"];
    String? ref = currMv!["_ref"];
    ConfigAgent configAgent =
        (ref != null) ? ConfigAgent(defName: ref) : ConfigAgent();
    String? mapping = currMv!["_mapping"];
    if (mapping != null) {
      List<dynamic> header = [];
      List<dynamic> data =
          configAgent.getElement(mapping, currMv!, header: header);
      input = [header, data];
      model.appActions.doFunction("mapPat", input, currMv);
/*       Map<String, dynamic> inMap = facts["mapping"][mapping];
      if (inMap != null) {
        var elemList = inMap["elemList"];
        int inx = currMv["_mapping_inx"];
        var data = (inx != null) ? elemList[inx] : elemList;
        input = [inMap["header"], data];
        model.appActions.doFunction("mapPat", input, currMv);
      }
 */
    }
    currMv!["_configAgent"] = configAgent;
    Function? mvcF = appMvc[mvcName];
    if (mvcF != null) {
      currMvc = mvcF(currMv);
      currMvc!.init();
      Map<String, dynamic> imap = {
        "_height": currMvc!.getBgHeight(),
        "_width": model.screenWidth,
        "_decoration": bgDecoration
      };
      Function pf = getPrimePattern["Container"]!;
      bgLayout = pf(imap);
      List<dynamic> children = [pf(imap), currMvc!.getPattern()];
      if (stackNoti != null) {
        stackNoti!.value = children;
        checkLives();
        return null;
      }

      stackNoti = resxController.addToResxMap("mvcStack", children)
          as Rx<List<dynamic>>;
      imap = {"_children": children};
      pf = getPrimePattern["Stack"]!;
      ProcessPattern pp = pf(imap);
      imap = {"_valueName": "mvcStack", "_child": pp};
      pf = getPrimePattern["Obx"]!;
      pp = pf(imap);

      if (it == 0) {
        int lives = userProfile["lives"];
        int wquestions = itemRef.length ~/ 2;
        if (lives <= wquestions) {
          if (lives == 0) {
            checkLives();
          } else {
            lowLives();
          }
        }
      } else {
        checkLives();
      }
      return pp;
    } else {
      agent = agent ?? model.appActions.getAgent("pattern");
      ProcessEvent event = ProcessEvent(mvcName, map: currMv);
      return agent!.process(event);
    }
  }

  lowLives() {
    int lives = userProfile["lives"];
    String t = text["notFinish"];
    t = t.replaceFirst("#n#", lives.toString());
    Map<String, dynamic> imap = {
      "_text": t,
      "_textAlign": TextAlign.center,
      "_textStyle": choiceButnTxtStyle,
      "_alignment": Alignment.center,
      "_width": resDialWidth * 0.8,
      "_height": 40.0 * sizeScale
    };
    ProcessPattern pp = tpf(imap);
    imap["_child"] = pp;
    pp = cpf(imap);
    double h = 40.0;
    List<dynamic> children = [pp];

    imap = {
      "_text": text["looseProgress"],
      "_textAlign": TextAlign.center,
      "_textStyle": resTxtStyle.copyWith(color: colorMap["btnBlue"]),
      "_alignment": Alignment.center,
      "_width": resDialWidth * 0.8,
      "_height": 16.0 * sizeScale
    };
    pp = tpf(imap);
    imap["_child"] = pp;
    pp = cpf(imap);
    children.add(pp);
    h += 16.0;
    List<dynamic> btns = ["cancel", "continue"];
    imap = {
      "_title": text["lowLives"],
      "_diaStyle": "blue",
      "_buttons": btns,
    };

    setDialog(children, h, imap);
  }

  checkLives() {
    int lives = userProfile["lives"];
    if (lives == 0) {
      timing ??= liveTime;
      Map<String, dynamic> imap = {"_width": model.size10};
      Function pf = getPrimePattern["SizedBox"]!;
      space10 = pf(imap);
      imap = {
        "_textStyle": incorrTxtStyle,
      };
      ProcessPattern pp = tpf(imap);
      timeNoti =
          resxController.addToResxMap("timeNoti", getTiming()) as RxString;
      imap = {
        "_child": pp,
        "_valueKey": "_text",
        "_valueName": "timeNoti",
      };
      pf = getPrimePattern["Obx"]!;
      pp = pf(imap);
      imap = {
        "_child": pp,
        "_alignment": Alignment.center,
        "_width": resDialWidth * 0.8,
        "_height": 16.0 * sizeScale
      };
      double h = 16.0 * sizeScale;
      pp = cpf(imap);
      List<dynamic> children = [pp];
      imap = {
        "_text": text["playAgain"],
        "_textAlign": TextAlign.center,
        "_textStyle": resTxtStyle.copyWith(color: colorMap["incorrect"]),
        "_alignment": Alignment.center,
        "_width": resDialWidth * 0.8,
        "_height": 36.0 * sizeScale
      };
      pp = tpf(imap);
      imap["_child"] = pp;
      pp = cpf(imap);
      children.add(pp);
      h += 36.0 * sizeScale;

      imap = {
        "_title": text["liveOut"],
        "_diaStyle": "red",
        "_btnStyle": "blueBorder",
        "_buttons": "cancel",
      };

      setDialog(children, h, imap);
      liveTimeOn = true;
      if (timer != null) {
        timer!.cancel();
      }
      timer = Timer.periodic(
          Duration(seconds: timeDuration), (timer) => _updateTime());
      userProfile["liveTimestamp"] = DateTime.now().millisecondsSinceEpoch;
    }
  }

  _updateTime() {
    if (liveTimeOn) {
      timing = timing! - timeDuration;
    } else {
      timing = 0;
    }
    if (timing! <= 0) {
      int lives = userProfile["lives"] + 1;
      resxController.setRxValue("lives", lives.toString());
      userProfile["lives"] = lives;
      model.versionAgent.saveProfile();
      if (liveTimeOn) {
        replaceLast(null);
        liveTimeOn = false;
      }
      timer!.cancel();
      timer = null;
      if (lives < configLives) {
        timer = Timer.periodic(
            Duration(seconds: liveTime), (timer) => _updateTime());
        userProfile["liveTimestamp"] =
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }
      timing = liveTime;
    } else if (liveTimeOn) {
      timeNoti!.value = getTiming();
    }
  }

  String getTiming() {
    int min = timing! ~/ 60;
    int sec = timing! % 60;
    String t = text["nextLife"] + min.toString() + ":" + sec.toString();
    return t;
  }

  List<dynamic> getLivesRow(dynamic textStyle) {
    Map<String, dynamic> imap = {
      "_icon": 'lives',
      "_iconColor": Colors.white,
    };
    Function pf = getPrimePattern["Icon"]!;
    List<dynamic> livesRow = [
      pf(imap),
    ];
    imap = {"_textStyle": textStyle};
    ProcessPattern pp = tpf(imap);
    imap = {
      "_child": pp,
      "_valueKey": "_text",
      "_valueName": "lives",
    };
    pf = getPrimePattern["Obx"]!;
    pp = pf(imap);
    imap = {
      "_child": pp,
    };
    pf = getPrimePattern["Center"]!;
    pp = pf(imap);
    imap = {"_child": pp, "_width": 40.0 * sizeScale};
    pf = getPrimePattern["SizedBox"]!;
    livesRow.add(pf(imap));
    return livesRow;
  }

  setDialog(List<dynamic> children, double h, Map<String, dynamic> map) {
    ProcessPattern pp = getWatchAd(null);
    children.add(pp);
    h += 1.2 * btnHeight;

    pp = getTapItemElemPattern(
        "livesSub", 1.8 * btnHeight, 1.2 * btnWidth, "blue");
    children.add(pp);
    h += btnHeight * 1.8;
    h += 60.0 * sizeScale;

    Map<String, dynamic> imap = {
      "_mainAxisAlignment": MainAxisAlignment.spaceEvenly,
      "_children": children
    };
    Function pf = getPrimePattern["Column"]!;
    pp = pf(imap);
    imap = {"_height": h, "_child": pp};
    pf = getPrimePattern["SizedBox"]!;
    pp = pf(imap);
    List<dynamic> bannerRow = getLivesRow(bannerTxtStyle);
    bannerRow.add(space10);
    imap = {
      "_title": map["_title"],
      "_bannerRow": bannerRow,
      "_diaStyle": map["_diaStyle"],
      "_diaBox": pp,
      "_width": resDialWidth,
      "_diaBoxHeight": h,
      "_btnStyle": map["_btnStyle"],
      "_buttons": map["_buttons"],
    };
    pp = getDialogPattern(imap);
    //Get.dialog(getPatternWidget(pp));
    List<dynamic> stackList = [];
    stackList.addAll(stackNoti!.value);
    stackList.add(pp);
    stackNoti!.value = stackList;
  }

  ProcessPattern _buildDialog(String event) {
    late ProcessPattern rtc;
    Map<String, dynamic> imap;

    String? subTitle = currMv!["_subTitle"];
    double rheight = resDialHeight;
    //double rtch = 0.02463 * model.scaleHeight;
    double rtch = 0.032 * model.scaleHeight;
    if (sizedPat == null) {
      Function pf = getPrimePattern["SizedBox"]!;
      imap = {"_height": 5.0 * sizeScale};
      sizedPat = pf(imap);
    }
    imap = {
      "_height": rtch,
      "_width": resDialWidth,
      "_alignment": Alignment.center,
      "_color": Colors.white,
    };
    BoxDecoration? decoration;
    List<dynamic>? supplement;
    switch (event) {
      case "correct":
      case "aSubscribePrice":
      case "mSubscribePrice":
      case "unsubscribed":
        String? btn;
        if (event == "correct") {
          List<int> il = currMv!["_prog"];
          if (il.last == 1) {
            Map<String, dynamic> tmap = {
              "_text": text["+1point"],
              "_textStyle":
                  resTxtStyle.copyWith(color: const Color(0xFF4DC591)),
            };
            imap["_child"] = tpf(tmap);
          }
        } else {
          imap["_child"] = currMv!["_child"];
          btn = "continue";
          rheight += currMv!["_height"];
          imap["_height"] = currMv!["_height"];
        }
        rtc = cpf(imap);
        String txt = (event == "correct")
            ? text["corrText"]
            : (event.contains("Price") ? text["subscribed"] : text[event]);
        imap = {
          "_text": txt,
          "_textStyle": bannerTxtStyle,
        };
        if (subTitle != null) {
          imap["_child"] = addSubtitle(tpf(imap), subTitle);
        } else {
          imap["_child"] = tpf(imap);
        }
        btnPat = createNextBtn(event: btn);
        image = "assets/images/correct.png";
        break;
      case "incorrect":
      case "lostLife":
        if (event == "lostLife") {
          Map<String, dynamic> tmap = {
            "_text": text["wontLoose"],
            "_textStyle": resTxtStyle,
          };
          imap["_child"] = tpf(tmap);
        }
        rtc = cpf(imap);
        imap = {
          "_text": (event == "lostLife") ? text["looseLife"] : text["notQuite"],
          "_textStyle": bannerTxtStyle,
        };
        if (subTitle != null) {
          imap["_child"] = addSubtitle(tpf(imap), subTitle);
        } else {
          imap["_child"] = tpf(imap);
        }
        btnPat = createTwoBtns();
        image = (event == "lostLife")
            ? "assets/images/looseLife.png"
            : "assets/images/fail.png";
        break;
      case "almost":
        if (userProfile["lives"] >= 0) {
          Map<String, dynamic> tmap = {
            "_text": text["wontLoose"],
            "_textStyle": resTxtStyle,
          };
          imap["_child"] = tpf(tmap);
        }
        rtc = cpf(imap);
        imap = {
          "_text": text["almost"],
          "_textStyle": bannerTxtStyle,
        };
        if (subTitle != null) {
          imap["_child"] = addSubtitle(tpf(imap), subTitle);
        } else {
          imap["_child"] = tpf(imap);
        }
        btnPat = createTwoBtns();
        image = "assets/images/almost.png";
        break;
      case "ShowAnswer":
        var anstxt = currMvc!.getAnswer();
        if (anstxt != null) {
          if (anstxt is String) {
            Map<String, dynamic> tmap = {
              "_text": anstxt,
              "_textStyle": choiceButnTxtStyle,
            };
            imap["_child"] = tpf(tmap);
          } else {
            List<dynamic> ansList = anstxt;
            Map<String, dynamic> tmap = {
              "_text": ansList[0],
              "_textStyle": choiceButnTxtStyle,
            };
            List<dynamic> al = [];
            al.add(tpf(tmap));
            double h = 10 * sizeScale;
            for (int i = 1; i < ansList.length; i++) {
              h += 20.0 * sizeScale;
              tmap["_text"] = ansList[i];
              al.add(tpf(tmap));
            }
            rheight += h;
            rtch += h;
            imap["_height"] = rtch;
            tmap = {
              "_crossAxisAlignment": CrossAxisAlignment.center,
              "_mainAxisAlignment": MainAxisAlignment.spaceBetween,
              "_children": al
            };
            Function sf = getPrimePattern["Column"]!;
            imap["_child"] = sf(tmap);
          }
        } else {
          Map<String, dynamic> tmap = {"_height": 16.0 * sizeScale};
          Function sf = getPrimePattern["SizedBox"]!;
          imap["_child"] = sf(tmap);
        }
        rtc = cpf(imap);
        imap = {
          "_text": text["answer"],
          "_textStyle": bannerTxtStyle,
        };
        imap["_child"] = tpf(imap);
        btnPat = createNextBtn();
        image = "assets/images/answer.jpeg";
        break;
      case "mCancel":
      case "aCancel":
        imap["_child"] = currMv!["_child"];

        rheight += currMv!["_height"];
        imap["_height"] = currMv!["_height"];
        rtc = cpf(imap);
        imap = {
          "_text": text["cancelSubs"],
          "_textStyle": bannerTxtStyle,
        };
        imap["_child"] = tpf(imap);
        btnPat = createTwoBtns();
        image = null;
        decoration = redGradBD;
        if (event == "aCancel") {
          Map<String, dynamic> pmap = {
            "_event": currMv!["_sEvent"],
            "_height": currMv!["_sHeight"],
            "_spec": currMv!["_spec"],
          };
          rheight += currMv!["_height"] * 2.5;
          supplement = [currMv!["_sChild"], getTapItemElemP(pmap)];
        }
        break;
      default:
        break;
    }
    Function pf = getPrimePattern["Align"]!;
    imap["_alignment"] = (image != null)
        ? const Alignment(-0.8, 0.0)
        : const Alignment(0.0, 0.0);
    ProcessPattern pp = pf(imap);
    imap = {
      "_child": pp,
      "_height": 0.07266 * model.scaleHeight,
      //"_height": 0.08 * model.scaleHeight,
      "_width": resDialWidth,
      "_decoration": (image != null) ? getDecoration(image!) : decoration,
    };
    ProcessPattern banner = cpf(imap);
    List<dynamic> children = [banner, rtc, btnPat];
    if (supplement != null) {
      children.addAll(supplement);
    }
    children.add(sizedPat);
    imap = {
      "_mainAxisAlignment": MainAxisAlignment.spaceBetween,
      "_children": children
    };
    pf = getPrimePattern["Column"]!;
    imap["_child"] = pf(imap);
    imap["_borderRadius"] = BorderRadius.all(Radius.circular(18.0 * sizeScale));
    pf = getPrimePattern["ClipRRect"]!;
    pp = pf(imap);
    imap = {
      "_alignment": Alignment.center,
      "_height": rheight,
      "_width": resDialWidth,
      "_decoration": diaDecoration,
      "_child": pp
    };
    pp = cpf(imap);

    return pp;
  }

  buildResultDialog(String event) {
    Map<String, dynamic> imap = {
      "_child": _buildDialog(event),
      "_alignment": const Alignment(0.0, 0.99),
    };
    Function pf = getPrimePattern["Align"]!;
    List<dynamic> stackList = [];
    stackList.addAll(stackNoti!.value);
    stackList.add(pf(imap));
    if (currMv!["_addRes"] != null) {
      stackList.add(currMv!["_addRes"]);
      currMv!["_addRes"] = null;
    }
    stackNoti!.value = stackList;
  }

  ProcessPattern createNextBtn({String? event}) {
    if (event == null) {
      nextBtnPat ??= getTapItemElemPattern("next", btnHeight, btnWidth, "blue");
      return nextBtnPat!;
    } else {
      return getTapItemElemPattern(event, btnHeight, btnWidth,
          {"_btnType": "blue", "_onTap": currMv!["_onTap"]});
    }
  }

  ProcessPattern createTwoBtns() {
    String btn1 = "showAnswer";
    String btn2 = "tryAgain";
    late ProcessPattern pp;
    late List<dynamic> children;
    Map<String, dynamic>? m1 = currMv!["_btn1"];
    Map<String, dynamic>? m2 = currMv!["_btn2"];
    Map<String, dynamic> iMap = {
      "_decoration": elemDecoration,
      "_textStyle": choiceButnTxtStyle,
    };
    if (m1 == null) {
      if (failBtnPat != null) {
        return failBtnPat!;
      }
      pp = getTapItemElemPattern(btn1, btnHeight, btnWidth, iMap);
      children = [pp, getTapItemElemPattern(btn2, btnHeight, btnWidth, "blue")];
    } else {
      Map<String, dynamic> nmap = {};
      nmap.addAll(m1);
      Map<String, dynamic> spec = iMap;
      if (m1["_spec"] != null) {
        spec.addAll(m1["_spec"]);
      }
      nmap["_spec"] = spec;
      pp = getTapItemElemP(nmap);
      nmap = {};
      nmap.addAll(m2!);
      spec = {};
      if (m2["_spec"] != null) {
        spec.addAll(m2["_spec"]);
      }
      nmap["_spec"] = spec;
      children = [pp, getTapItemElemP(nmap)];
    }

    iMap = {
      "_crossAxisAlignment": CrossAxisAlignment.center,
      "_mainAxisAlignment": MainAxisAlignment.spaceAround,
      "_children": children,
    };
    Function pf = getPrimePattern["Row"]!;
    failBtnPat = pf(iMap);
    return failBtnPat!;
  }

  replaceLast(ProcessPattern? pp) {
    List<dynamic> stackList = [];
    stackList.addAll(stackNoti!.value);
    //List<dynamic> stackList = stackNoti.value;
    if (pp == null) {
      stackList.removeLast();
    } else {
      stackList.last = pp;
    }
    stackNoti!.value = stackList;
  }

  nextGame() {
    List<int> il = currMv!["_prog"];
    List<dynamic> itemRef = currMv!["_itemRef"];
    int ilen = il.length;
    if (ilen < itemRef.length) {
      if (itemRef[ilen - 1] == itemRef[ilen]) {
        currMv!["_state"] = "start";
        currMvc!.reset(false);
        replaceLast(currMvc!.getPattern());
        //confirmNoti!.value = 0.5;
        checkLives();
      } else {
        createNew(ilen);
      }
    } else {
      gameComplete();
    }
  }

  gameComplete() {
    Function pf;
    Function cpf = getPrimePattern["Container"]!;
    Map<String, dynamic> imap;
    ProcessPattern pp;
    int corr = 0;
    List<dynamic> slw = [];
    List<dynamic> l = currMv!["_prog"];
    int ll = l.length;
    for (int i = 0; i < ll; i++) {
      if (l[i] == 1) {
        corr++;
      }
    }
    double score = corr / ll;
    int incorr = ll - corr;
    List<dynamic> completeText = [];
    double width = 0.93333 * model.scaleWidth;
    TextStyle sts = yourScoreStyle;
    TextStyle bts = yourScoreStyle.copyWith(fontSize: 50 * fontScale);
    double textHeight = 0.08128 * model.scaleHeight;
    //Function tpf = getPrimePattern["Text"];

    bool scoreMark = score >= currMv!["_PassScore"];
    if (scoreMark) {
      BoxDecoration bd = getDecoration("assets/images/star_background.png")!;
      imap = {
        "_height": 0.4926 * model.scaleHeight,
        "_width": width,
        "_decoration": bd,
      };
      pp = cpf(imap);
      imap = {
        "_alignment": Alignment.topCenter,
        "_child": pp,
      };
      pf = getPrimePattern["Align"]!;
      pp = pf(imap);
      slw.add(pp);
      if (score >= 0.99) {
        pf = getPrimePattern["ImageAsset"]!;
        imap = {
          "_height": 0.18473 * model.scaleHeight,
          "_name": "assets/images/trophy.png",
          "_boxFit": BoxFit.cover,
        };
        pp = pf(imap);
        imap["_child"] = pp;
        pp = cpf(imap);
        imap = {
          "_alignment": const Alignment(0.0, -0.6),
          "_child": pp,
        };
        pf = getPrimePattern["Align"]!;
        pp = pf(imap);
        slw.add(pp);
        textHeight = 0.1084 * model.scaleHeight;
        imap = {
          "_text": text["congrat"],
          "_textStyle": complTextStyle,
          "_textAlign": TextAlign.center,
        };
        pp = tpf(imap);
        completeText.add(pp);
        imap["_text"] = text["highScore"];
        pp = tpf(imap);
        completeText.add(pp);
        imap["_text"] = text["forQuiz"];
        pp = tpf(imap);
        completeText.add(pp);
      } else {
        imap = {
          "_text": text["wellDone"],
          "_textStyle": complTextStyle,
          "_textAlign": TextAlign.center,
        };
        pp = tpf(imap);
        completeText.add(pp);
        imap["_text"] = text["quizComplete"];
        pp = tpf(imap);
        completeText.add(pp);
      }
    } else {
      sts = sts.copyWith(color: const Color(0xFFF76F71));
      bts = bts.copyWith(color: const Color(0xFFF76F71));
      textHeight = 0.1084 * model.scaleHeight;
      pf = getPrimePattern["ImageAsset"]!;
      imap = {
        "_name": "assets/images/circles.png",
        "_boxFit": BoxFit.cover,
      };
      pp = pf(imap);
      imap["_child"] = pp;
      imap["_width"] = width;
      pp = cpf(imap);
      imap = {
        "_alignment": Alignment.topCenter,
        "_child": pp,
      };
      pf = getPrimePattern["Align"]!;
      pp = pf(imap);
      slw.add(pp);
      imap = {
        "_text": "HMM...",
        "_textStyle": complTextStyle,
        "_textAlign": TextAlign.center,
      };
      pp = tpf(imap);
      completeText.add(pp);
      imap["_text"] = text["maybe"];
      pp = tpf(imap);
      completeText.add(pp);
      imap["_text"] = text["practice"];
      pp = tpf(imap);
      completeText.add(pp);
    }
    int scorep = (score * 100).round();
    imap = {
      "_mainAxisAlignment": MainAxisAlignment.spaceBetween,
      "_crossAxisAlignment": CrossAxisAlignment.center,
      "_children": completeText,
    };
    pf = getPrimePattern["Column"]!;
    pp = pf(imap);
    imap = {
      "_alignment": Alignment.center,
      "_height": textHeight,
      "_width": width,
      "_child": pp,
    };
    pp = cpf(imap);
    imap = {
      "_alignment": const Alignment(0.0, -0.95),
      "_child": pp,
    };
    pf = getPrimePattern["Align"]!;
    pp = pf(imap);
    slw.add(pp);
    completeText = [];
    imap = {
      "_text": text["yourScore"],
      "_textStyle": sts,
      "_textAlign": TextAlign.center,
    };
    pp = tpf(imap);
    completeText.add(pp);
    imap = {
      "_text": scorep.toString() + " %",
      "_textStyle": bts,
      "_textAlign": TextAlign.center,
    };
    pp = tpf(imap);
    completeText.add(pp);
    imap = {
      "_mainAxisAlignment": MainAxisAlignment.spaceBetween,
      "_crossAxisAlignment": CrossAxisAlignment.center,
      "_children": completeText,
    };
    pf = getPrimePattern["Column"]!;
    pp = pf(imap);
    imap = {
      "_alignment": Alignment.center,
      "_height": 0.11084 * model.scaleHeight,
      "_width": width,
      "_child": pp,
    };
    ProcessPattern c = cpf(imap);
    double sh = 0.1355 * model.scaleHeight;
    double sw = 0.1867 * model.scaleWidth;
    List<dynamic> children = [];
    imap = {
      "_name": "scoreCard",
      "_text": text["corr"],
      "_points": corr,
      "_color": const Color(0xFF4DC591),
      "_alignment": Alignment.bottomCenter,
      "_height": sh,
      "_width": sw,
    };
    children.add(getGameItemPattern(imap));
    imap = {
      "_name": "scoreCard",
      "_text": text["totalQ"],
      "_points": ll,
      "_color": const Color(0xFF1785C1),
      "_alignment": Alignment.topCenter,
      "_height": sh,
      "_width": sw,
    };
    children.add(getGameItemPattern(imap));
    imap = {
      "_name": "scoreCard",
      "_text": text["incorr"],
      "_points": incorr,
      "_color": const Color(0xFFF76F71),
      "_alignment": Alignment.bottomCenter,
      "_height": sh,
      "_width": sw,
    };
    children.add(getGameItemPattern(imap));
    imap = {
      "_mainAxisAlignment": MainAxisAlignment.spaceBetween,
      "_crossAxisAlignment": CrossAxisAlignment.center,
      "_children": children,
    };
    pf = getPrimePattern["Row"]!;
    pp = pf(imap);
    imap = {
      "_alignment": Alignment.center,
      "_height": sh,
      "_width": sw * 3 + 20.0 * sizeScale,
      "_child": pp,
    };
    ProcessPattern s = cpf(imap);
    double shareHeight = 0.07389 * model.scaleHeight;
    double bh = 0.04926 * model.scaleHeight;
    double bw = 0.32 * model.scaleWidth;
    Map<String, dynamic> nmap = {
      "_name": "shareContainer",
      "_width": width,
      "_height": 0.9264 * model.scaleHeight,
      "_shareHeight": shareHeight,
      "_shareIcon": "assets/images/share.png",
      "_screenName": "GameCompleteScreen",
      "_sharedScreenText": model.map["text"]["sharedScreenText"],
    };
    currMv!["_scoreMark"] = scoreMark;
    if (scoreMark) {
      imap = {"_name": "socialMediaButtons"};
      children = [
        c,
        s,
        getGameItemPattern(nmap),
        getGameItemPattern(imap),
        getTapItemElemPattern("gameDone", bh, bw, "blue")
      ];
    } else {
      imap = {"_height": shareHeight};
      pf = getPrimePattern["SizedBox"]!;
      pp = pf(imap);
      children = [
        c,
        s,
        pp,
        getTapItemElemPattern("repeatGame", bh, bw, "corr"),
        getTapItemElemPattern("gameDone", bh, bw, "blue")
      ];
    }
    imap = {
      "_mainAxisAlignment": MainAxisAlignment.spaceBetween,
      "_crossAxisAlignment": CrossAxisAlignment.center,
      "_children": children
    };
    pf = getPrimePattern["Column"]!;
    pp = pf(imap);
    imap = {
      "_alignment": Alignment.center,
      "_width": width,
      "_height": 0.4803 * model.scaleHeight,
      "_child": pp
    };
    pp = cpf(imap);
    imap = {"_alignment": const Alignment(0.0, 0.95), "_child": pp};
    pf = getPrimePattern["Align"]!;
    pp = pf(imap);
    slw.add(pp);
    nmap["_gameCompleteList"] = slw;
    pp = getGameCompletePattern(nmap);
    replaceLast(pp);
  }

  ProcessPattern getProgRow() {
    ProcessPattern pp = prepareProgRow();
    Function pf;
    Map<String, dynamic> imap;
    if (currMv!["_hints"] == null) {
      imap = {"_child": hint, "_opacity": 0.5};
      pf = getPrimePattern["Opacity"]!;
    } else {
      Map<String, dynamic> eventMap = {};
      ProcessEvent pe = ProcessEvent("mvc");
      pe.map = eventMap;
      List<dynamic> l = ["showHint"];
      imap = {"_child": hint, "_onTap": pe, "_tapAction": l};
      pf = getPrimePattern["TapItem"]!;
    }
    List<dynamic> br = [pp, pf(imap)];
    imap = {
      "_mainAxisAlignment": MainAxisAlignment.spaceBetween,
      "_children": br
    };
    pf = getPrimePattern["Row"]!;
    pp = pf(imap);
    return pp;
  }

  ProcessPattern prepareProgRow() {
    Map<String, dynamic> imap;
    ProcessPattern pp;
    Function pf;
    if (incompleteProg == null) {
      imap = {
        "_icon": "incomplete",
        "_iconSize": 12.0,
        "_iconColor": const Color(0xFF999FAD)
      };
      Function ipf = getPrimePattern["Icon"]!;
      incompleteProg = ipf(imap);
      imap = {
        "_icon": "complete",
        "_iconSize": 12.0,
        "_iconColor": const Color(0xFF4DC591)
      };
      completeProg = ipf(imap);
      imap = {
        "_icon": "complete",
        "_iconSize": 12.0,
        "_iconColor": const Color(0xFF999FAD)
      };
      incorrProg = ipf(imap);
      imap = {"_width": 8.0 * sizeScale};
      pf = getPrimePattern["SizedBox"]!;
      space10 = pf(imap);
      imap["_width"] = 3.0 * sizeScale;
      space5 = pf(imap);
      //imap["_width"] = model.size20;
      imap["_width"] = 15.0 * sizeScale;
      space20 = pf(imap);
      imap = {
        "_icon": "hint",
        "_iconSize": 30.0 * sizeScale,
        "_iconColor": Colors.green,
      };
      pp = ipf(imap);
      imap = {
        "_width": 40.0 * sizeScale,
        "_alignment": Alignment.centerLeft,
        "_child": pp
      };
      hint = cpf(imap);
    }
    List<dynamic> lg = getProgIconList();
    resxController.addToResxMap("prog", lg);
    imap = {"_children": lg};
    //progNoti = createNotifier(lg);
    pf = getPrimePattern["Wrap"]!;
    pp = pf(imap);
    imap = {"_valueName": "prog", "_child": pp};
    pf = getPrimePattern["Obx"]!;
    pp = pf(imap);
    imap = {
      "_width": 0.83 * model.scaleWidth,
      "_alignment": Alignment.centerLeft,
      "_margin": const EdgeInsets.only(left: 5),
      //"_height": size20 + size10 + size5,
      "_child": pp
    };
    pp = cpf(imap);
    imap = {"_child": pp, "_alignment": const Alignment(0.8, 0.0)};
    pf = getPrimePattern["Align"]!;
    return pf(imap);
  }

  List<dynamic> getProgIconList() {
    List<dynamic> itemRef = currMv!["_itemRef"];
    List<int> il = currMv!["_prog"];
    int ilen = il.length;
    int ln1 = ilen - 1;
    int itlen = itemRef.length;
    List<dynamic> lg = [];
    for (int i = 0; i < ilen; i++) {
      ProcessPattern ic = (il[i] >= 1) ? completeProg! : incorrProg!;
      lg.add(ic);
      if (i < ln1) {
        lg.add(space5);
      }
    }
    ln1 = itlen - 1;
    if ((ilen > 0) && (ilen < itlen)) {
      lg.add(space5);
    }
    for (int i = ilen; i < itlen; i++) {
      lg.add(incompleteProg);
      if (i < ln1) {
        lg.add(space5);
      }
    }
    return lg;
  }

  updateProg() {
    List<dynamic> lg = getProgIconList();
    resxController.setRxValue("prog", lg);
    //progNoti.value = lg;
  }

  ProcessPattern getQuitDialog() {
    Map<String, dynamic> imap = {
      "_height": 0.061576 * model.scaleHeight,
      "_name": "assets/images/quit_bubble_arrow.png",
      "_boxFit": BoxFit.cover,
    };
    Function pf = getPrimePattern["ImageAsset"]!;
    ProcessPattern arrow = pf(imap);

    imap = {
      "_icon": "cancel",
      "_iconSize": 16.0,
      "_iconColor": const Color(0xFF999FAE),
    };
    pf = getPrimePattern["Icon"]!;
    ProcessPattern pp = pf(imap);
    //Map<String, dynamic> eventMap = {"mode": false};
    ProcessEvent pe = ProcessEvent("popRoute");
    //pe.map = eventMap;
    List<dynamic> l = ["cancel"];
    imap = {"_child": pp, "_onTap": pe, "_tapAction": l};
    Function tipf = getPrimePattern["TapItem"]!;
    pp = tipf(imap);
    double boxWidth = 0.88 * model.scaleWidth;
    imap = {
      "_alignment": const Alignment(0.9, 0.0),
      "_width": boxWidth,
      "_height": 0.0431 * model.scaleHeight,
      "_child": pp,
      "_decoration": BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(size10),
          topLeft: Radius.circular(size10),
        ),
      ),
    };
    ProcessPattern banner = cpf(imap);

    //Function rpf = getPrimePattern["Row"];
    //Function tpf = getPrimePattern["Text"];
    imap = {"_text": text["quitText"], "_textStyle": normalSTextStyle};
/*     List<dynamic> children = [space20, tpf(imap)];
    imap["_children"] = children;
    imap["_mainAxisAlignment"] = MainAxisAlignment.start;
    ProcessPattern rp = rpf(imap);
    imap["_text"] = text["looseProgress"];
    children = [space20, tpf(imap)];
    imap["_children"] = children;
    pp = rpf(imap);
    children = [rp, pp];
 */
    List<dynamic> children = [tpf(imap)];
    imap["_height"] = model.size10;
    pf = getPrimePattern["SizedBox"]!;
    children.add(pf(imap));
    imap["_text"] = text["looseProgress"];
    children.add(tpf(imap));
    children.add(pf(imap));
    pf = getPrimePattern["Column"]!;
    imap = {
      "_children": children,
      "_mainAxisAlignment": MainAxisAlignment.spaceAround,
      "_crossAxisAlignment": CrossAxisAlignment.start,
    };
    pp = pf(imap);

    imap = {"_child": pp, "_alignment": const Alignment(-0.7, 0.0)};
    // pp = cpf(imap);
    // pf = getPrimePattern["Expanded"];
    // imap = {"_child": pp};
    ProcessPattern bubbleText = cpf(imap);

    double bwidth = 0.373333 * model.scaleWidth;
    double bheight = 0.046798 * model.scaleHeight;
    imap = {
      "_textStyle": controlButtonTextStyle,
      "_beginColor": colorMap["btnBlue"],
      "_endColor": colorMap["btnBlueGradEnd"],
      "_height": bheight,
      "_width": bwidth,
      "_item": text["cancel"],
    };
    pp = getItemElemPattern(imap);
    imap = {"_child": pp, "_onTap": pe, "_tapAction": l};
    pp = tipf(imap);
    children = [pp];
    imap = {
      "_decoration": elemDecoration,
      "_textStyle": choiceButnTxtStyle,
      "_height": bheight,
      "_width": bwidth,
      "_alignment": Alignment.center,
      "_item": text["quit"],
    };
    pp = getItemElemPattern(imap);
    Map<String, dynamic> eventMap = {"mode": true};
    pe = ProcessEvent("popRoute");
    pe.map = eventMap;
    l = ["quit"];
    imap = {"_child": pp, "_onTap": pe, "_tapAction": l};
    pp = tipf(imap);
    children.insert(0, pp);
    imap = {
      "_children": children,
      "_mainAxisAlignment": MainAxisAlignment.spaceAround,
      "_mainAxisSize": MainAxisSize.max,
    };
    Function rpf = getPrimePattern["Row"]!;
    ProcessPattern rp = rpf(imap);
    imap = {
      "_child": rp,
      "_width": boxWidth,
      "_height": 0.061576 * model.scaleHeight,
      "_color": Colors.white,
      "_alignment": Alignment.topCenter
    };
    pp = cpf(imap);
    children = [banner, bubbleText, pp];
    double ax = (100.0 / model.screenWidth) - 1.0;
    imap = {
      "_align": Alignment(ax, -0.85),
      "_bubbleArrow": arrow,
      "_bubbleBox": children,
      "_bubbleHeight": 0.23399 * model.scaleHeight,
      "_arrowAlign": const Alignment(-0.95, -1.0),
      "_boxAlign": Alignment.bottomCenter,
      "_boxWidth": boxWidth,
      "_boxHeight": 0.197044 * model.scaleHeight,
    };
    pf = getPrimePattern["Bubble"]!;
    return pf(imap);
  }

  setHint(String mode) {
    switch (mode) {
      case "cancelHint":
        hintShowed = false;
        //replaceLast(null);
        Get.back();
        return;
      case "prevHint":
        currHint--;
        break;
      case "nextHint":
        currHint++;
        break;
      default:
        break;
    }
    String hintText = text["hintText"];
    int ix = currHint + 1;
    bool hasPrev = ix > 1;
    bool last = ix == hints!.length;
    hintText = hintText
        .replaceFirst("#n#", ix.toString())
        .replaceFirst("#t#", hints!.length.toString());
    String hint = hints![currHint];
    double ax = 1.0 - (100.0 / model.screenWidth);
    Map<String, dynamic> nmap = {
      "_hasPrev": hasPrev,
      "_last": last,
      "_hint": hint,
      "_align": Alignment(ax, 0.90),
      "_bubbleSize": 0.061576 * model.scaleHeight,
      "_assetName": "assets/images/hint_bubble_arrow.png",
      "_bubbleHeight": 0.197044 * model.scaleHeight,
      "_arrowAlign": const Alignment(0.9, 0.90),
      "_boxAlign": Alignment.topCenter,
      "_boxWidth": 0.88 * model.scaleWidth,
      "_boxHeight": 0.1601 * model.scaleHeight,
      "_bannerHeight": 0.043103 * model.scaleHeight,
      "_hintText": hintText,
      "_prevHint": text["prevHint"],
      "_nextHint": text["nextHint"],
      "_tryTeachMode": text["tryTeachMode"],
      "_onCancel": "cancelHint",
      "_onTryTeachMode": "cancelHint",
      "_onPrev": "prevHint",
      "_onNext": "nextHint",
    };
    ProcessPattern pp = getHintBubble(nmap);
    Widget w = getPatternWidget(pp)!;
    if (hintShowed) {
      Get.back();
      Get.dialog(w);
      //replaceLast(pp);
    } else {
      hintShowed = true;
      Get.dialog(w);
/*       List<dynamic> stackList = [];
      stackList.addAll(stackNoti.value);
      stackList.add(pp);
      stackNoti.value = stackList;
 */
    }
  }
}
