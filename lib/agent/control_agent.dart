import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirius_geo_4/agent/config_agent.dart';
import 'package:sirius_geo_4/agent/logic_processor.dart';
import 'package:sirius_geo_4/agent/mvc_agent.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/builder/get_pattern.dart';
import 'package:json_theme/json_theme.dart';
import 'package:sirius_geo_4/resources/app_model.dart';
import 'package:sirius_geo_4/resources/basic_resources.dart';
import 'package:sirius_geo_4/resources/fonts.dart';
import 'package:sirius_geo_4/resources/s_g_icons.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/builder/item_search.dart';

class AgentActions extends AppActions {
  final ControlAgent controlAgent = ControlAgent();
  final MvcAgent mvcAgent = MvcAgent();
  String patName = "";

  @override
  Function getFunction(String name) {
    switch (name) {
      default:
        return appFunc[name];
    }
  }

  @override
  dynamic doFunction(String name, dynamic input, Map<String, dynamic> vars) {
    switch (name) {
      case "mapPat":
        return controlAgent.mapPat(input, vars);
      case "mvc":
        List<dynamic> ld = input;
        ProcessEvent pe = ProcessEvent(ld[0]);
        if (ld.length > 1) {
          pe.map = ld[1];
        }
        return mvcAgent.process(pe);
      case "fsm":
        ProcessEvent pe = ProcessEvent("fsm", map: input);
        return mvcAgent.process(pe);
      case "process":
        ProcessEvent pe = ProcessEvent(input, map: vars);
        return mvcAgent.process(pe);
      case "decode":
        return controlAgent.decode(input, vars);
      case "dataList":
        if ((input is List<dynamic>) && (input.length == 2)) {
          return getDataList(input[0], input[1]);
        }
        return null;
      case "route":
        Get.toNamed("/page?screen=" + input, arguments: vars);
        //Navigator.pushNamed(model.context, input, arguments: {"map": vars});
        return true;
      case "popRoute":
        bool mode = (vars != null) ? vars["mode"] ?? false : false;
        //Navigator.of(model.context).pop(mode);
        Get.back();
        if (mode) {
          Get.back();
        }
        return true;
      case "createNotifier":
        return createNotifier(input);
      case "setNotiValue":
        return setNotiValue(input);
      case "createEvent":
        if (input is List<dynamic>) {
          if (input.length == 2) {
            return ProcessEvent(input[0], map: input[1]);
          } else if (input.length == 1) {
            return ProcessEvent(input[0]);
          }
        }
        if (input is String) {
          return ProcessEvent(input);
        }
        return null;
      case "menu":
        String sel;
        //ValueNotifier<bool> noti;
        if (input is List<dynamic>) {
          sel = input[0];
          Get.back();
          // noti = input[1];
          // noti.value = false;
        } else {
          sel = input;
        }
        switch (sel) {
          case "Search":
            onSearch(Get.context, {});
            return true;
          default:
            return true;
        }
        return false;
      case "setConfig":
        if (input is List<dynamic>) {
          String cName = input[0];
          Map<String, dynamic> config = model.map[cName];
          if (config == null) {
            return false;
          }
          config = splitLines(config);
          cName = input[1];
          Map<String, dynamic> facts = model.map[cName];
          facts = (facts != null) ? facts["facts"] : null;
          if (facts == null) {
            return false;
          }
          facts.addAll(config);
          return true;
        }
        return false;
      case "initApp":
        initApp();
        return true;
      case "getHeight":
        if (input is double) {
          return input * model.screenHeight;
        }
        return null;
      case "getWidth":
        if (input is double) {
          return input * model.screenWidth;
        }
        return null;
      case "checkNull":
        String name = input[0];
        var data = vars[name] ?? input[1];
        vars[name] = data;
        return true;
      case "showDialog":
        Get.dialog(
          getPatternWidget(input),
          useSafeArea: true,
        );
        return true;
      case "key":
        return GlobalKey();
      case "changeNoti":
        if ((input is! List<dynamic>) || (input.length != 2)) {
          return false;
        }
        ValueNotifier noti = input[0];
        List<dynamic> ld = input[1];
        if (ld.length != 2) {
          return false;
        }
        noti.value = (noti.value == ld[0]) ? ld[1] : ld[0];
        return true;
      case "pushStack":
        model.stack.add(input);
        return true;
      case "popStack":
        List<dynamic> sl = model.stack.last;
        model.stack.removeLast();
        return sl;
      case "updateListNoti":
        if (input is List<dynamic>) {
          ValueNotifier<List<dynamic>> noti = input[0];
          List<dynamic> value = [];
          List<dynamic> inList = [];
          inList.add(noti.value);
          for (int i = 1; i < input.length; i++) {
            inList.add(input[i]);
          }
          Map<String, dynamic> lmap = {"_outputList": value};
          bool ok = handleList(inList, lmap);
          if (ok) {
            noti.value = value;
            return true;
          }
        }
        return false;
      default:
        return false;
    }
  }

  @override
  Function getPattern(String name) {
    Function pf = getPrimePattern[name] ?? appPatterns[name];
    if (pf == null) {
      patName = name;
      pf = getControlPattern;
    }
    return pf;
  }

  @override
  Agent getAgent(String name) {
    controlAgent.requestAgent(name);
    return controlAgent;
  }

  ProcessPattern getControlPattern(Map<String, dynamic> map) {
    controlAgent.requestAgent("pattern");
    return controlAgent.process(ProcessEvent(patName, map: map));
  }

  @override
  dynamic getResource(String res, String spec, {dynamic value}) {
    String _res = (res.contains("Color")) ? "color" : res;
    switch (_res) {
      case "model":
        return model.map[spec];
      case "color":
        Color c = colorMap[spec];
        if (c != null) {
          return c;
        }
        return ThemeDecoder.decodeColor(spec, validate: false);
      case "textStyle":
        return textStyle[spec];
      case "appRes":
        return resources[spec];
      case "icon":
        return myIcons[spec];
      case "resxValue":
        return resxController.getRxValue(spec);
      case "setResxValue":
        resxController.setRxValue(spec, value);
        return true;
      default:
        return null;
    }
  }
}

class ControlAgent extends Agent {
  List<ProcessEvent> processStack = [];
  String _type = "pattern";
  Map<String, dynamic> patterns = model.map["patterns"];
  String mapName = "patMap";

  @override
  dynamic process(ProcessEvent event) {
    switch (_type) {
      case "process":
        return agentProcess(event);
        break;
      case "pattern":
        LogicProcessor lp = LogicProcessor(patterns);
        if (event.map != null) {
          lp.vars.addAll(event.map);
        }
        var r = lp.process(event.name);
        if ((event.map != null) && (event.map.length < lp.vars.length)) {
          List<String> l = lp.vars.keys.toList();
          for (String k in l) {
            if (event.map[k] == null) {
              event.map[k] = lp.vars[k];
            }
          }
        }
        return r;
        break;
      default:
        break;
    }
    return false;
  }

  requestAgent(String type) {
    _type = type;
  }

  dynamic agentProcess(ProcessEvent event) {
    return false;
  }

  bool mapPat(List<dynamic> l, Map<String, dynamic> vars) {
    if (l.length != 2) {
      return false;
    }
    List<dynamic> pl = (l[1] is String) ? l[1].split(';') : l[1];
    if (pl == null) {
      return false;
    }
    List<dynamic> patHeader = (l[0] is String) ? l[0].split(';') : l[0];
    int len = (patHeader.length > pl.length) ? pl.length : patHeader.length;
    for (int i = 0; i < len; i++) {
      var ipat = pl[i];
      ipat = (ipat is String)
          ? (ipat.isEmpty)
              ? nil
              : (ipat[0] == '_')
                  ? vars[ipat] ?? ipat
                  : ipat
          : ipat;
      String k = '_' + patHeader[i];
      if ((ipat != nil) && (ipat != exist)) {
        switch (k) {
          case "_hratio":
            k = "_height";
            double h = ipat * model.screenHeight;
            vars[k] = h;
            break;
          case "_wratio":
            k = "_width";
            double w = ipat * model.screenWidth;
            vars[k] = w;
            break;
          case "_color":
            vars[k] = ThemeDecoder.decodeColor(ipat, validate: false);
            break;
          case "_alignment":
          case "_align":
            vars[k] = ThemeDecoder.decodeAlignment(ipat, validate: false);
            break;
          case "_crossAxisAlignment":
            vars[k] =
                ThemeDecoder.decodeCrossAxisAlignment(ipat, validate: false);
            break;
          case "_mainAxisAlignment":
            vars[k] =
                ThemeDecoder.decodeMainAxisAlignment(ipat, validate: false);
            break;
          case "_mainAxisSize":
            vars[k] = ThemeDecoder.decodeMainAxisSize(ipat, validate: false);
            break;
          case "_verticalDirection":
            vars[k] =
                ThemeDecoder.decodeVerticalDirection(ipat, validate: false);
            break;
          case "_padding":
          case "_margin":
            vars[k] =
                ThemeDecoder.decodeEdgeInsetsGeometry(ipat, validate: false);
            break;
          default:
            var s = (ipat is String)
                ? int.tryParse(ipat) ??
                    (double.tryParse(ipat) ??
                        ((ipat == "true")
                            ? true
                            : (ipat == "false")
                                ? false
                                : ipat))
                : ipat;
            vars[k] = s;
            break;
        }
      } else {
        if ((ipat == nil) && (vars[k] != null)) {
          vars[k] = null;
        }
      }
    }
    return true;
  }

  dynamic decode(List<dynamic> l, Map<String, dynamic> vars) {
    String name = l[0];
    var v = l[1];
    switch (name) {
      case "borderRadius":
        return ThemeDecoder.decodeBorderRadius(v, validate: false);
      case "alignment":
      case "align":
        if (v is Map<String, dynamic>) {
          return Alignment(v["horiz"], v["vert"]);
        }
        return ThemeDecoder.decodeAlignment(v, validate: false);
      case "axis":
        if (v == "horizontal") {
          return Axis.horizontal;
        } else if (name == "vertical") {
          return Axis.vertical;
        }
        break;
      case "padding":
      case "margin":
        return ThemeDecoder.decodeEdgeInsetsGeometry(v, validate: false);
      default:
        return null;
    }
  }
}
