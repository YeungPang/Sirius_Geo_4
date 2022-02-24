import 'package:flutter/material.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'dart:math';
import 'package:json_theme/json_theme.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:string_validator/string_validator.dart';

final Map<String, dynamic> facts = model.map["patterns"]["facts"];
final Map<String, dynamic> clauses = model.map["patterns"]["clauses"];

class ConfigAgent {
  String defName;
  Map<String, dynamic> defMap;
  ConfigAgent({this.defName});

  dynamic getElement(var iv, Map<String, dynamic> vars,
      {List<int> rowList, List<dynamic> header}) {
    if ((iv == null) || ((iv is String) && (iv.isEmpty))) {
      return null;
    }
    defMap = ((defName != null) ? facts[defName] : defMap);
    if (iv is int) {
      if (defMap != null) {
        if (rowList != null) {
          rowList.add(iv);
        }
        return defMap["elemList"][iv];
      }
    }
    if ((iv is double) || (iv is bool)) {
      return iv;
    }
    String s = iv;
    String src = s.trim();
    List<String> ls = s.split(':');
    int ll = ls.length;
    if (ll > 1) {
      String ref = ls[0].trim();
      if (ref.isNotEmpty) {
        defMap = facts[ref] ?? model.map[ref];
      } else {
        defMap ??= facts;
      }
      for (int i = 1; i < (ll - 1); i++) {
        defMap = defMap[ls[i].trim()];
      }
      src = ls[1].trim();
      if (src.isEmpty) {
        return defMap;
      }
      if (isAlphanumeric(src) && !isNumeric(src)) {
        return defMap[src];
      }
    }
    var si = int.tryParse(src) ??
        (double.tryParse(src) ??
            ((src == "true")
                ? true
                : (src == "false")
                    ? false
                    : src));
    if (si is int) {
      if (defMap != null) {
        if (rowList != null) {
          rowList.add(si);
        }
        dynamic r = defMap["elemList"];
        if (header != null) {
          var h = defMap["header"];
          List<dynamic> hl;
          hl = (h is String) ? h.split(';') : h;
          header.addAll(hl);
        }
        return (r is List<dynamic>) ? r[si] : r;
      }
    }
    if (si is! String) {
      return si;
    }
    RegExp re = RegExp(r"[()]");
    ls = src.split(re);
    if (ls.length > 1) {
      src = ls[1].trim();
    }

    re = RegExp(r"[,]");
    if (src[0] == '[') {
      int inx = src.indexOf(']');
      String s1 = src.substring(1, inx);
      List<dynamic> ds1 = getListContent(s1, defMap, vars, rowList);
      if (src.length > ++inx) {
        String s2 = src.substring(inx);
        List<String> ls2 = s2.split(re);
        if (ls2.length > 1) {
          s2 = ls2[ls2.length - 1].trim();
        }
        if ((s2 is String) && (s2[0] == '_')) {
          s2 = vars[s2] ?? s2;
        }
        si = int.tryParse(s2) ??
            (double.tryParse(s2) ??
                ((s2 == "true")
                    ? true
                    : (s2 == "false")
                        ? false
                        : s2));
        if ((si is int) && (defMap != null)) {
          List<dynamic> ds2 = [];
          for (List<dynamic> ld in ds1) {
            if (ld != null) {
              ds2.add(ld[si]);
            }
          }
          return ds2;
        }
        return [ds1, si];
      }
      return ds1;
    }
    ls = src.split(re);
    String s0 = ls[0].trim();
    si = (s0[0] == '_') ? vars[s0] ?? s0 : s0;
    if (si is String) {
      si = int.tryParse(si) ??
          (double.tryParse(si) ??
              ((si == "true")
                  ? true
                  : (si == "false")
                      ? false
                      : si));
    }
    int inx = ls.length - 1;
    String s1 = (ls.length > 1) ? ls[inx].trim() : null;
    var si2 = (s1 == null) ? null : ((s1[0] == '_') ? (vars[s1] ?? s1) : s1);
    if (si2 is String) {
      si2 = int.tryParse(si2) ??
          (double.tryParse(si2) ??
              ((s1 == "true")
                  ? true
                  : (si2 == "false")
                      ? false
                      : si2));
    }
    if ((defMap != null) && (si is int)) {
      if (header != null) {
        var h = defMap["header"];
        List<dynamic> hl;
        hl = (h is String) ? h.split(';') : h;
        header.addAll(hl);
      }
      List<dynamic> ld = defMap["elemList"][si];
      if (rowList != null) {
        rowList.add(si);
      }
      if ((ls.length > 1) && (si2 is int)) {
        return ld[si2];
      }
      return ld;
    }
    if (ls.length > 1) {
      List<dynamic> ds1 = [si, si2];
      return ds1;
    }
    return si;
  }

  List<dynamic> getListContent(String s, Map<String, dynamic> defMap,
      Map<String, dynamic> vars, List<int> rowList) {
    RegExp re = RegExp(r"[\[\],]");
    List<String> ls1 = s.split(re);
    List<dynamic> ds1 = [];
    for (String ds in ls1) {
      if (ds.isNotEmpty) {
        ds = ds.trim();
        List<String> rs = ds.split('‥');
        bool notRange = true;
        if (rs.length > 1) {
          String sr = rs[0].trim();
          if (sr[0] == '_') {
            sr = vars[sr] ?? sr;
          }
          int r1 = int.tryParse(sr);
          sr = rs[1].trim();
          if (sr[0] == '_') {
            sr = vars[sr] ?? sr;
          }
          int r2 = int.tryParse(sr);
          if ((r1 != null) && (r2 != null) && (defMap != null)) {
            notRange = false;
            for (int r = r1; r <= r2; r++) {
              var v = defMap["elemList"][r];
              if (rowList != null) {
                rowList.add(r);
              }
              ds1.add(v);
            }
          }
        }
        if (notRange) {
          var v = getElement(ds, vars, rowList: rowList);
          ds1.add(v);
        }
      }
    }
    return ds1;
  }

  List<dynamic> mapPatternList(String patName, String elemName,
      List<dynamic> elemList, Map<String, dynamic> map) {
    Function pf = model.appActions.getPattern(patName);
    List<dynamic> pl = [];
    for (var v in elemList) {
      if ((v is Map<String, dynamic>) && (elemName == null)) {
        map.addAll(v);
      } else {
        map[elemName] = v;
      }
      ProcessPattern p = pf(map);
      pl.add(p);
    }
    return pl;
  }

  String checkText(String textName, Map<String, dynamic> map) {
    String text = map[textName];
    if (text == null) {
      return null;
    }
    int inx = text.indexOf("#");
    if (inx >= 0) {
      int inx1 = text.indexOf("#", inx + 1);
      String v = text.substring(inx + 1, inx1);
      String elem = getElement(v, map);
      text = text.replaceFirst("#" + v + "#", elem);
    }
    return text;
  }
}

List<dynamic> splitElemList(List<dynamic> list) {
  List<dynamic> vl = [];
  for (var v in list) {
    if (v is String) {
      List<String> ls = v.split(';');
      List<dynamic> lv = [];
      for (String s in ls) {
        dynamic vs = int.tryParse(s);
        vs ??= double.tryParse(s);
        vs ??= (s == "true")
            ? true
            : (s == "false")
                ? false
                : s;
        lv.add(vs);
      }
      vl.add(lv);
    } else if (v is Map<String, dynamic>) {
      vl.add(splitLines(v));
    } else if (v is List<dynamic>) {
      vl.add(splitElemList(v));
    } else {
      if (v is String) {
        dynamic vs = int.tryParse(v);
        vs ??= double.tryParse(v);
        vs ??= (v == "true")
            ? true
            : (v == "false")
                ? false
                : v;
        vl.add(vs);
      } else {
        vl.add(v);
      }
    }
  }
  return vl;
}

Map<String, dynamic> splitLines(Map<String, dynamic> map) {
  Map<String, dynamic> rMap = {};
  map.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      rMap[key] = splitLines(value);
    } else if (value is List<dynamic>) {
      rMap[key] = splitElemList(value);
    } else if (value is String) {
      rMap[key] = value.split(';');
    } else {
      rMap[key] = value;
    }
  });
  return rMap;
}

List<dynamic> getDataList(Map<String, dynamic> m, var ielem) {
  List<dynamic> elem;
  if (ielem is String) {
    List<String> il = ielem.split(";");
    elem = [];
    for (int i = 0; i < il.length; i++) {
      int ii = int.tryParse(il[i]);
      if (ii != null) {
        elem.add(ii);
      } else {
        elem.add(il[i]);
      }
    }
  } else {
    elem = ielem;
  }
  var mheader = m["header"];
  List<dynamic> header = (mheader is String) ? mheader.split(";") : mheader;
  var mr = m["dataStart"];
  int inx = header.indexOf("ref");
  String ref = elem[inx];
  String inxName = (mr is List<dynamic>) ? mr[0] : mr;
  inx = header.indexOf(inxName);
  if (ref != null) {
    Map<String, dynamic> em = facts[ref];
    List<dynamic> el = (em != null) ? em["elemList"] : null;
    if ((inx >= 0) && (el != null)) {
      List<dynamic> dl = [];
      List<int> excl = [];
      for (int i = inx; i < elem.length; i++) {
        var einx = elem[i];
        if (einx is String) {
          List<int> il = resolveIntList(einx.trim());
          int ri = getRandom(il.length, excl);
          excl.add(ri);
          ri = il[ri];
          var v = el[ri];
          dl.add(v);
        } else if (einx is int) {
          var v = el[einx];
          dl.add(v);
        }
      }
      return dl;
    }
  }
  return null;
}

List<int> resolveIntList(String einx) {
  List<int> il = [];
  String estr = ((einx[0] == '[') || (einx[0] == '('))
      ? einx.substring(1, einx.length - 1)
      : einx;
  List<String> sl = estr.split(',');
  for (String s in sl) {
    if (s.contains('‥')) {
      List<String> sdl = s.split('‥');
      int i0 = int.tryParse(sdl[0].trim());
      int i1 = int.tryParse(sdl[1].trim());
      for (int j = i0; j <= i1; j++) {
        il.add(j);
      }
    } else {
      int i0 = int.tryParse(s.trim());
      il.add(i0);
    }
  }
  return il;
}

dynamic lookup(String estr) {
  Map<String, dynamic> elem;
  if (estr.contains(":")) {
    List<String> sl = estr.split(":");
    List<String> il = sl[0].split(".");
    elem = model.map;
    for (String s in il) {
      elem = elem[s];
    }
    int inx = int.tryParse(sl[1]);
    if (inx != null) {
      List<dynamic> elemList = elem["elemList"];
      return elemList[inx];
    }
    return elem[sl[1]];
  } else {
    elem = model.map["lookup"];
    return elem[estr];
  }
}

dynamic createNotifier(dynamic input) {
  if (input is String) {
    return ValueNotifier<String>(input);
  } else if (input is Map<String, dynamic>) {
    return ValueNotifier<Map<String, dynamic>>(input);
  } else if (input is int) {
    return ValueNotifier<int>(input);
  } else if (input is Widget) {
    return ValueNotifier<Widget>(input);
  } else if (input is List<Widget>) {
    return ValueNotifier<List<Widget>>(input);
  } else if (input is double) {
    return ValueNotifier<double>(input);
  } else if (input is bool) {
    return ValueNotifier<bool>(input);
  } else if (input is List<int>) {
    return ValueNotifier<List<int>>(input);
  } else if (input is List<dynamic>) {
    return ValueNotifier<List<dynamic>>(input);
  } else if (input is ProcessPattern) {
    return ValueNotifier<ProcessPattern>(input);
  }
  return null;
}

dynamic setNotiValue(dynamic input) {
  if (input is List<dynamic>) {
    if (input.length != 2) {
      return false;
    }
    var value = input[1];
    if (value is List<dynamic>) {
      ValueNotifier<List<dynamic>> noti = input[0];
      noti.value = value;
      return true;
    }
    if (value is ProcessPattern) {
      ValueNotifier<ProcessPattern> noti = input[0];
      noti.value = value;
      return true;
    }
    if (value is String) {
      ValueNotifier<String> noti = input[0];
      noti.value = value;
      return true;
    } else if (value is Map<String, dynamic>) {
      ValueNotifier<Map<String, dynamic>> noti = input[0];
      noti.value = value;
      return true;
    } else if (value is int) {
      ValueNotifier<int> noti = input[0];
      noti.value = value;
      return true;
    } else if (value is Widget) {
      ValueNotifier<Widget> noti = input[0];
      noti.value = value;
      return true;
    } else if (value is List<Widget>) {
      ValueNotifier<List<Widget>> noti = input[0];
      noti.value = value;
      return true;
    } else if (value is double) {
      ValueNotifier<double> noti = input[0];
      noti.value = value;
      return true;
    } else if (value is bool) {
      ValueNotifier<bool> noti = input[0];
      noti.value = value;
      return true;
    } else if (value is List<int>) {
      ValueNotifier<List<int>> noti = input[0];
      noti.value = value;
      return true;
    }
    return false;
  }
  return false;
}

int getRandom(int range, List<int> exclude) {
  Random random = Random();
  if (exclude.length >= range) {
    return null;
  }
  int n = random.nextInt(range);
  while (exclude.contains(n)) {
    n++;
    if (n >= range) {
      n = 0;
    }
  }
  return n;
}

List<int> getRandomList(int size, int range, List<int> incl, List<int> excl) {
  int olen = size - range;
  int exlen = (excl != null) ? excl.length : 0;
  if (olen < exlen) {
    return null;
  }
  List<int> rlist = [];
  if (incl != null) {
    rlist.addAll(incl);
  }
  List<int> exclude = [];
  if (excl != null) {
    exclude.addAll(excl);
  }
  exclude.addAll(rlist);
  while (rlist.length < range) {
    int ri = getRandom(size, exclude);
    exclude.add(ri);
    if ((rlist.isEmpty) || (rlist.last < ri)) {
      rlist.add(ri);
    } else {
      for (int i = 0; i < rlist.length; i++) {
        if (rlist[i] > ri) {
          rlist.insert(i, ri);
          break;
        }
      }
    }
  }
  return rlist;
}

List<dynamic> mapList(List<int> inxList, List<dynamic> list) {
  if (inxList.length > list.length) {
    return null;
  }
  List<dynamic> mapList = [];
  for (int i; i < inxList.length; i++) {
    int inx = inxList[i];
    if (inx >= list.length) {
      return null;
    }
    mapList.add(list[inx]);
  }
  return mapList;
}

List<dynamic> resolveList(List<dynamic> list, Map<String, dynamic> vars) {
  List<dynamic> rList = [];
  for (var e in list) {
    var v = ((e is String) && (e[0] == '_')) ? vars[e] : e;
    if ((v is String) && (v.contains('‥'))) {
      List<String> ls = v.split('‥');
      if (ls.length != 2) {
        return null;
      }
      int int1 = int.tryParse(ls[0]);
      int int2 = int.tryParse(ls[1]);
      if ((int1 == null) || (int2 == null)) {
        return null;
      }
      if (int1 > int2) {
        for (int i = int1; i >= int2; i--) {
          rList.add(i);
        }
      } else {
        for (int i = int1; i <= int2; i++) {
          rList.add(i);
        }
      }
    } else {
      rList.add(v);
    }
  }
  return rList;
}

dynamic getCompleted(String pid) {
  if (pid == null) {
    return false;
  }
  int inx1 = pid.indexOf('[');
  int inx2 = pid.indexOf(']');
  String s = pid.substring(inx1 + 1, inx2);
  RegExp re = RegExp(r"[\[\],]");
  List<String> sl = s.trim().split(re);
  int len = sl.length;
  List<dynamic> prog = model.map["userProfile"]["progress"];
  if (prog.isEmpty) {
    if (len == 1) {
      return 0;
    } else {
      return false;
    }
  }
  int i = int.tryParse(sl[0]);
  int total = 0;
  while (inx1 >= 0) {
    for (int pi in prog) {
      int ci = pi % 1024;
      if (ci == i) {
        ci = pi >> 10;
        if (len > 1) {
          int i3 = int.tryParse(sl[1].trim());
          i3 = 1 << i3;
          if ((i3 & ci) != 0) {
            return true;
          } else {
            return false;
          }
        }
        while (ci != 0) {
          if ((ci & 1) != 0) {
            total++;
          }
          ci >>= 1;
        }
      }
    }
    inx1 = pid.indexOf('[', inx2);
    if (inx1 > 0) {
      inx2 = pid.indexOf(']', inx1);
      s = pid.substring(inx1 + 1, inx2);
      sl = s.trim().split(re);
      i = int.tryParse(sl[0]);
    }
  }
  if (len > 1) {
    return false;
  }
  return total;
}

setProgress(String pid) {
  List<dynamic> prog = model.map["userProfile"]["progress"];
  RegExp re = RegExp(r"[\[\],]");
  List<String> sl = pid.trim().split(re);
  int len = sl.length;
  int k = 1;
  List<String> nl = [];
  while (k < len) {
    nl.add("[" + sl[k] + "]");
    int i = int.tryParse(sl[k++]);
    int i3 = int.tryParse(sl[k]);
    k += 3;
    bool notFound = true;
    if (prog.isNotEmpty) {
      for (int j = 0; j < prog.length; j++) {
        int pi = prog[j];
        int ci = pi % 1024;
        if (ci == i) {
          pi |= 1 << (10 + i3);
          prog[j] = pi;
          notFound = false;
          break;
        }
      }
    }
    if (notFound) {
      i |= 1 << (10 + i3);
      prog.add(i);
    }
  }

  resxController.setRxValue("progNoti", pid);
  resxController.setRxValue("groupNoti", nl);
  // model.progNoti.value = pid;
  // model.groupNoti.value = nl;
}

Future<String> _loadString(String fileName) async {
  return await rootBundle.loadString(fileName);
}

loadData(Map<String, dynamic> map) async {
  String fileName = map["_fileName"];
  Function func = model.appActions.getFunction(map["_func"]);
  _loadString(fileName).then((value) {
    map["_data"] = value;
    func(map);
  });
}

bool handleList(List<dynamic> input, Map<String, dynamic> map) {
  if (input.length < 2) {
    return false;
  }
  List<dynamic> list = map["_outputList"] ?? input[0];
  if (map["_outputList"] != null) {
    list.addAll(input[0]);
  }
  String type = input[1];
  switch (type) {
    case "add":
      if (input.length < 3) {
        return false;
      }
      list.add(input[2]);
      break;
    case "insertAt":
    case "insertAllAt":
      if (input.length < 3) {
        return false;
      }
      int index = (input.length == 4) ? input[3] : map["_index"];
      if (index == null) {
        return false;
      }
      if (index <= list.length) {
        if (type == "insertAt") {
          list.add(input[2]);
        } else {
          list.addAll(input[2]);
        }
      } else {
        if (type == "insertAt") {
          list.insert(index, input[2]);
        } else {
          list.insertAll(index, input[2]);
        }
      }
      break;
    case "remove":
      if (input.length < 3) {
        return false;
      }
      list.remove(input[2]);
      break;
    case "removeAt":
      if (input.length == 3) {
        list.removeAt(input[2]);
      } else {
        int index = map["_index"];
        if (index == null) {
          return false;
        }
        list.removeAt(index);
      }
      break;
    case "removeLast":
      list.removeLast();
      break;
    case "removeRange":
      bool inse = input.length == 5;
      int start = inse ? input[3] : map["_start"];
      int end = inse ? input[4] : map["_end"];
      if ((start == null) || (end == null)) {
        return false;
      }
      list.removeRange(start, end);
      break;
    case "replace":
      int index = (input.length == 4) ? input[3] : map["_index"];
      if ((index == null) || (input.length < 3)) {
        return false;
      }
      list[index] = input[2];
      break;
    default:
      return false;
  }
  return true;
}
