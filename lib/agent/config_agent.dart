import 'package:flutter/material.dart';
import '../resources/basic_resources.dart';
import '../model/locator.dart';
import '../builder/pattern.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:string_validator/string_validator.dart';
import 'package:http/http.dart' as http;

final Map<String, dynamic> facts = model.map["patterns"]["facts"];
final Map<String, dynamic> clauses = model.map["patterns"]["clauses"];
final Map<String, dynamic> uProfile = model.map["userProfile"];

class ConfigAgent {
  String? defName;
  Map<String, dynamic>? defMap;
  ConfigAgent({this.defName});

  dynamic getElement(var iv, Map<String, dynamic> vars,
      {List<int>? rowList, List<dynamic>? header, Map<String, dynamic>? map}) {
    if ((iv == null) || ((iv is String) && (iv.isEmpty))) {
      return null;
    }
    defMap = ((defName != null) ? facts[defName] : defMap);
    map ??= defMap;
    if (iv is int) {
      if (map != null) {
        if (rowList != null) {
          rowList.add(iv);
        }
        if (header != null) {
          var h = map["header"];
          List<dynamic> hl;
          hl = (h is String) ? h.split(';') : h;
          header.addAll(hl);
        }
        return map["elemList"][iv];
      }
    }
    //if ((iv is double) || (iv is bool)) {
    if (iv is! String) {
      return iv;
    }
    var as = vars[iv] ?? iv;
    String s = checkModelText(as.toString());
    String src = s.trim();
    if (src[0] != 'ℛ') {
      return resolveStr(src);
    }
    return getRefContent(src.substring(1), map, vars, rowList, header);
  }

  dynamic getRefContent(String s, Map<String, dynamic>? map,
      Map<String, dynamic> vars, List<int>? rowList, List<dynamic>? header) {
/*     if (s.isEmpty || (s[0] != '(') || (s[s.length - 1] != ')')) {
      throw Exception("Invalid reference: ℛ" + s);
    } */
    String src = (s[0] == '(') ? s.substring(1, s.length - 1) : s;
    if ((src[0] == '[') && (src[src.length - 1] == ']')) {
      return getListContent(src, map, vars, rowList, header);
    }
    List<String> ls = src.split(':');
    int ll = ls.length;
    if (ll > 1) {
      String ref = ls[0].trim();
      if (ref.isNotEmpty) {
        map = facts[ref] ?? model.map[ref];
      } else {
        map ??= facts;
      }
      int l = 1;
      for (int i = 1; i < (ll - 1); i++) {
        map = map![ls[i].trim()];
        l++;
      }
      src = ls[l].trim();
      if (src.isEmpty) {
        return map;
      }
      if (isAlphanumeric(src) && !isInt(src)) {
        return map![src];
      }
    }
    if ((src[0] == '[') && (src[src.length - 1] == ']')) {
      return getListContent(src, map, vars, rowList, header);
    }
    var si = resolveStr(src);
    if (si is int) {
      if (map != null) {
        if (rowList != null) {
          rowList.add(si);
        }
        dynamic r = map["elemList"];
        if (header != null) {
          var h = map["header"];
          List<dynamic> hl;
          hl = (h is String) ? h.split(';') : h;
          header.addAll(hl);
        }
        dynamic re = r;
        if (r is List<dynamic>) {
          re = r[si];
          if ((re is String) && (re.contains(";"))) {
            re = re.split(';');
            r[si] = re;
          }
        } else {
          if ((re is String) && (re.contains(";"))) {
            re = re.split(';');
          }
        }
        return re;
      }
    }
    if (si is! String) {
      return si;
    }
    RegExp re = RegExp(r"[,]");
    if (src[0] == '[') {
      int inx = src.indexOf(']');
      String s1 = src.substring(1, inx);
      List<dynamic> ds1 = getListContent(s1, map, vars, rowList, header);
      if (src.length > ++inx) {
        String s2 = src.substring(inx);
        List<String> ls2 = s2.split(re);
        if (ls2.length > 1) {
          s2 = ls2[ls2.length - 1].trim();
        }
        if (s2[0] == '_') {
          s2 = vars[s2] ?? s2;
        }
        si = resolveStr(s2);
        if ((si is int) && (map != null)) {
          List<dynamic> ds2 = [];
          for (List<dynamic> ld in ds1) {
            var rs = ld[si];
            if ((rs is String) && (rs[0] == '[')) {
              rs = getListContent(rs, map, vars, rowList, header, noRef: true);
              //rs = getListData(rs);
            }
            ds2.add(rs);
          }
          return ds2;
        }
        return [ds1, si];
      }
      return ds1;
    }
    int ib = src.indexOf('[');
    if (ib > 0) {
      int ic = src.indexOf(',');
      ls = [src.substring(0, ic), src.substring(ib)];
    } else {
      ls = src.split(re);
    }
    String s0 = ls[0].trim();
    si = (s0[0] == '_') ? vars[s0] ?? s0 : s0;
    if (si is String) {
      si = resolveStr(si);
    }
    int inx = ls.length - 1;
    String? s1 = (ls.length > 1) ? ls[inx].trim() : null;
    var si2 = ((s1 == null) || (s1.isEmpty))
        ? null
        : ((s1[0] == '_') ? (vars[s1] ?? s1) : s1);
    if (si2 is String) {
      si2 = resolveStr(si2);
    }
    if ((map != null) && (si is int)) {
      if (header != null) {
        var h = map["header"];
        List<dynamic> hl;
        hl = (h is String) ? h.split(';') : h;
        header.addAll(hl);
      }
      var vld = map["elemList"][si];
      List<dynamic>? ld;
      if (vld is List<dynamic>) {
        ld = vld;
      } else if (vld is String) {
        if (vld[0] == '[') {
          vld = vld.substring(1, vld.length - 1);
          ld = getListData(vld);
        } else if (vld.contains(';')) {
          ld = vld.split(';');
        } else {
          ld = [vld];
        }
      }
      if (rowList != null) {
        rowList.add(si);
      }
      if (ls.length > 1) {
        if (si2 is int) {
          var rs = ld![si2];
          if ((rs is String) && (rs.isNotEmpty) && (rs[0] == '[')) {
            rs = getListContent(rs, map, vars, rowList, header, noRef: true);
            //rs = getListData(rs);
          }
          return rs;
        } else {
          String s = si2;
          s = s.substring(1, s.length - 1);
          List<dynamic> lrs = getListData(s);
          List<dynamic> rsl = [];
          for (int i in lrs) {
            var rs = ld![i];
            if ((rs is String) && (rs.isNotEmpty) && (rs[0] == '[')) {
              rs = getListContent(rs, map, vars, rowList, header, noRef: true);
              rsl.addAll(rs);
            } else {
              rsl.add(rs);
            }
          }
          return rsl;
        }
      }
      return ld!;
    }
    if (ls.length > 1) {
      List<dynamic> ds1 = [si, si2];
      return ds1;
    }
    return si;
  }

  List<dynamic> getListContent(String s, Map<String, dynamic>? map,
      Map<String, dynamic> vars, List<int>? rowList, List<dynamic>? header,
      {bool noRef = false}) {
    //RegExp re = RegExp(r"[\[\],]");
    String src = (s[0] == '[') ? s.substring(1, s.length - 1) : s;
    List<String> lstack = [];
    int inx = src.indexOf('(');
    while (inx >= 0) {
      int einx = src.indexOf(')', inx) + 1;
      String s1 = src.substring(0, inx);
      inx = s1.lastIndexOf(',');
      if (inx < 0) {
        inx = 0;
      }
      s1 = src.substring(inx, einx);
      lstack.add(s1);
      src = src.replaceFirst(s1, 'ç,');
      inx = src.indexOf('(');
    }
    inx = src.indexOf('[');
    while (inx >= 0) {
      int einx = src.indexOf(']', inx) + 1;
      String s1 = src.substring(0, inx);
      inx = s1.lastIndexOf(',');
      if (inx < 0) {
        inx = 0;
      }
      if ((inx < (src.length - 1)) && (src[inx] == ',')) {
        inx++;
      }
      s1 = src.substring(inx, einx);
      lstack.add(s1);
      src = src.replaceFirst(s1, 'ç,');
      inx = src.indexOf('[');
    }
    List<String> ls1 = src.split(',');
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
          int? r1 = int.tryParse(sr);
          sr = rs[1].trim();
          if (sr[0] == '_') {
            sr = vars[sr] ?? sr;
          }
          int? r2 = int.tryParse(sr);
          if ((r1 != null) && (r2 != null) && (map != null)) {
            notRange = false;
            for (int r = r1; r <= r2; r++) {
              var v = map["elemList"][r];
              if (rowList != null) {
                rowList.add(r);
              }
              ds1.add(v);
            }
          }
        }
        if (notRange) {
          dynamic v;
          if (ds == 'ç') {
            ds = lstack[0];
            lstack.removeAt(0);
            v = noRef ? ds : getRefContent(ds, map, vars, rowList, header);
            if (v is List<dynamic>) {
              ds1.addAll(v);
            } else {
              ds1.add(v);
            }
          } else {
            var rs = resolveStr(ds);

            v = (noRef) ? rs : getElement(rs, vars, header: header, map: map);
            ds1.add(v);
            if ((rs is int) && (rowList != null)) {
              rowList.add(rs);
            }
          }
        }
      }
    }
    return ds1;
  }

  List<dynamic> mapPatternList(String patName, String? elemName,
      List<dynamic> elemList, Map<String, dynamic> map) {
    Function? pf = model.appActions.getPattern(patName);
    List<dynamic> pl = [];
    for (var v in elemList) {
      if ((v is Map<String, dynamic>) && (elemName == null)) {
        map.addAll(v);
      } else {
        map[elemName!] = v;
      }
      ProcessPattern p = pf!(map);
      pl.add(p);
    }
    return pl;
  }

  dynamic checkText(String textName, Map<String, dynamic> map) {
    dynamic t = map[textName];
    if (t == null) {
      return null;
    }
    List<dynamic> tl = (t is List<dynamic>) ? t : [t];
    for (int i = 0; i < tl.length; i++) {
      String text = tl[i];

      int inx = text.indexOf("#");
      while (inx >= 0) {
        int inx1 = text.indexOf("#", inx + 1);
        String v = text.substring(inx + 1, inx1);
        String elem = getElement(v, map).toString();
        text = text.replaceFirst("#" + v + "#", elem);
        inx = text.indexOf("#");
      }
      tl[i] = checkModelText(text);
    }
    if (tl.length == 1) {
      return tl[0];
    }
    return tl;
  }
}

List<dynamic> splitElemList(List<dynamic> list) {
  List<dynamic> vl = [];
  for (var v in list) {
    if (v is String) {
      List<String> ls = v.split(';');
      List<dynamic> lv = [];
      for (String s in ls) {
        dynamic vs = resolveStr(s);
        lv.add(vs);
      }
      vl.add(lv);
    } else if (v is Map<String, dynamic>) {
      vl.add(splitLines(v));
    } else if (v is List<dynamic>) {
      vl.add(splitElemList(v));
    } else {
      if (v is String) {
        dynamic vs = resolveStr(v);
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

List<dynamic>? getDataList(Map<String, dynamic> m, var ielem) {
  List<dynamic> elem;
  var mheader = m["header"];
  if (ielem is String) {
    List<String> il = ielem.split(";");
    elem = [];
    for (int i = 0; i < il.length; i++) {
      int? ii = int.tryParse(il[i]);
      if (ii != null) {
        elem.add(ii);
      } else {
        elem.add(il[i]);
      }
    }
  } else {
    if (ielem is Map<String, dynamic>) {
      elem = ielem.values.map((e) => e).toList();
      mheader = ielem.keys.map((e) => e.substring(1)).toList();
    } else {
      elem = ielem;
    }
  }
  List<dynamic> header = (mheader is String) ? mheader.split(";") : mheader;
  var mr = m["dataStart"];
  int inx = header.indexOf("ref");
  String? ref = (inx >= 0) ? elem[inx] : null;
  String inxName = (mr is List<dynamic>) ? mr[0] : mr;
  inx = header.indexOf(inxName);
  if (ref != null) {
    Map<String, dynamic>? em = facts[ref];
    List<dynamic>? el = (em != null) ? em["elemList"] : null;
    if ((inx >= 0) && (el != null)) {
      List<dynamic> dl = [];
      List<int> excl = [];
      for (int i = inx; i < elem.length; i++) {
        var einx = elem[i];
        bool isRef = false;
        if ((einx is String) && (einx.isNotEmpty)) {
          String iinx = einx.trim();
          if (iinx[0] == 'ℛ') {
            iinx = iinx.substring(2, iinx.length - 1);
            isRef = true;
          }
          int? ii = int.tryParse(iinx);
          einx = ii ?? iinx;
        }
        if (einx is String) {
          if (einx.isNotEmpty) {
            if ((isRef) && (einx.contains(':'))) {
              List<String> ls = einx.split(':');
              String ref = ls[0].trim();
              Map<String, dynamic>? map = facts[ref] ?? model.map[ref];
              if (map != null) {
                List<dynamic> r = map["elemList"];
                var h = map["header"];
                int? i = int.tryParse(ls[1].trim());
                if ((i != null) && (i < r.length)) {
                  List<dynamic> header = (h is String) ? h.split(";") : h;
                  List<dynamic> input = [header, r[i]];
                  Map<String, dynamic> m = {};
                  model.appActions.doFunction("mapPat", input, m);
                  dl.add(m);
                }
              }
            }
          } else {
            List<int> il = resolveIntList(einx.trim());
            if (il.isNotEmpty) {
              int ri = getRandom(il.length, excl)!;
              excl.add(ri);
              ri = il[ri];
              var v = el[ri];
              dl.add(v);
            }
          }
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
  if (einx.isNotEmpty) {
    String estr = ((einx[0] == '[') || (einx[0] == '('))
        ? einx.substring(1, einx.length - 1)
        : einx;
    List<String> sl = estr.split(',');
    for (String s in sl) {
      if (s.contains('‥')) {
        List<String> sdl = s.split('‥');
        int i0 = int.tryParse(sdl[0].trim())!;
        int i1 = int.tryParse(sdl[1].trim())!;
        for (int j = i0; j <= i1; j++) {
          il.add(j);
        }
      } else {
        int i0 = int.tryParse(s.trim())!;
        il.add(i0);
      }
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
    int? inx = int.tryParse(sl[1]);
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

int? getRandom(int range, List<int> exclude) {
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

List<int>? getRandomList(
    int size, int range, List<int>? incl, List<int>? excl) {
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
    int ri = getRandom(size, exclude)!;
    exclude.add(ri);
    rlist.add(ri);
  }
  int pos = getRandom(range, [])!;
  for (int i = pos; i < rlist.length; i++) {
    int e = rlist.last;
    rlist.removeLast();
    rlist.insert(0, e);
  }
  return rlist;
}

List<dynamic>? mapList(List<int> inxList, List<dynamic> list) {
  if (inxList.length > list.length) {
    return null;
  }
  List<dynamic> mapList = [];
  for (int i = 0; i < inxList.length; i++) {
    int inx = inxList[i];
    if (inx >= list.length) {
      return null;
    }
    mapList.add(list[inx]);
  }
  return mapList;
}

List<dynamic>? resolveList(List<dynamic> list, Map<String, dynamic> vars,
    {ConfigAgent? configAgent}) {
  List<dynamic> rList = [];
  for (var e in list) {
    var v = ((e is String) && (e[0] == '_')) ? vars[e] : e;
    v = (v is String) ? v.trim() : v;
    if ((v is String) && (v.contains('‥'))) {
      List<String> ls = v.split('‥');
      if (ls.length != 2) {
        return null;
      }
      int? int1 = int.tryParse(ls[0]);
      int? int2 = int.tryParse(ls[1]);
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
      if ((v is String) &&
          ((v[0] == 'ℛ') || (v[0] == '[')) &&
          (configAgent != null)) {
        v = (v[0] == 'ℛ') ? configAgent.getElement(v, vars) : v;
        if (v is String) {
          v = v.trim();
          if (v[0] == '[') {
            String s = v.substring(1, v.length - 1);
            v = getListData(s);
          }
        }
        if (v is List<dynamic>) {
          v = resolveList(v, vars, configAgent: configAgent);
        }
      }
      rList.add(v);
    }
  }
  return rList;
}

dynamic getCompleted(dynamic pid) {
  if (pid == null) {
    return false;
  }

  List<dynamic> prog = uProfile["progress"];
  if (prog.isEmpty) {
    if (pid is List<int>) {
      return 0;
    } else {
      return false;
    }
  }
  List<dynamic> gProg = uProfile["groupProgress"] ?? [];
  if (pid is List<int>) {
    int ic = 0;
    for (int pi in pid) {
      if (_checkCompleted(pi, prog, gProg)) {
        ic++;
      }
    }
    return ic;
  } else {
    return _checkCompleted(pid, prog, gProg);
  }
}

bool _checkCompleted(int pi, List<dynamic> prog, List<dynamic> gProg) {
  int g = pi ~/ 64;
  int inx = gProg.indexOf(g);
  if (inx >= 0) {
    int p = 1 << (pi % 64);
    int pg = prog[inx];
    p &= pg;
    return (p != 0);
  }
  return false;
}

setProgress(int pi) {
  List<dynamic> prog = uProfile["progress"];
  int g = pi ~/ 64;
  List<dynamic> gProg = uProfile["groupProgress"] ?? [];
  int inx = gProg.indexOf(g);
  int pg = (inx < 0) ? 0 : prog[inx];
  int p64 = pi % 64;
  int p = 1 << p64;
  pg |= p;
  if (inx < 0) {
    gProg.add(g);
    prog.add(pg);
  } else {
    prog[inx] = pg;
  }
  uProfile["groupProgress"] = gProg;
  resxController.setRxValue("progNoti", pi);
  model.versionAgent.saveProfile();
}

Future<String> loadString(String fileName) async {
  return await rootBundle.loadString(fileName);
}

loadData(Map<String, dynamic> map) async {
  String fileName = map["_fileName"];
  Function func = model.appActions.getFunction(map["_func"])!;
  if (fileName.contains("http")) {
    http.get(Uri.parse(fileName)).then((http.Response response) {
      if (response.statusCode == 200) {
        map["_data"] = response.body;
        func(map);
      }
    });
  } else {
    loadString(fileName).then((value) {
      map["_data"] = value;
      func(map);
    });
  }
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
      int? index = (input.length == 4) ? input[3] : map["_index"];
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
        int? index = map["_index"];
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
      int? start = inse ? input[3] : map["_start"];
      int? end = inse ? input[4] : map["_end"];
      if ((start == null) || (end == null)) {
        return false;
      }
      list.removeRange(start, end);
      break;
    case "replace":
      int? index = (input.length == 4) ? input[3] : map["_index"];
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

dynamic resolveStr(String src) {
  dynamic d = int.tryParse(src) ??
      (double.tryParse(src) ??
          ((src == "true")
              ? true
              : (src == "false")
                  ? false
                  : checkModelText(src)));
  return d;
}

String checkModelText(String text) {
  int inx = 0;
  while (inx >= 0) {
    inx = text.indexOf('⊤');
    if (inx >= 0) {
      int inx1 = text.indexOf(")", inx + 1);
      String v = text.substring(inx + 2, inx1);
      String? elem = lookup(v) ?? model.map["text"][v];
      if (elem != null) {
        text = text.replaceFirst("⊤(" + v + ")", elem);
      } else {
        text = text.replaceFirst("⊤(" + v + ")", "");
      }
    }
  }
  return text;
}

getStyleCls(String css, Map<String, dynamic> scls, {bool overwrite = true}) {
  List<String> sText = css.trim().split('}');
  for (String st in sText) {
    String s = st.trim();
    if (s.isNotEmpty) {
      List<String> sl = s.split('{');
      String s0 = sl[0].trim();
      if ((overwrite) || (scls[s0] == null)) {
        scls[s0] = getStyle(sl[1].trim());
      }
    }
  }
}

Map<String, dynamic> getStyle(String s) {
  Map<String, dynamic> style = {};
  Color? fillColor;
  double fillOpacity = 1.0;
  Color? strokeColor;
  double strokeOpacity = 1.0;
  double strokeWith = 1.0;
  StrokeCap? strokeCap;
  StrokeJoin? strokeJoin;
  double? strokeMiterLimit;

  List<String> stl = s.split(';');
  for (String st in stl) {
    List<String> cs = st.split(':');
    switch (cs[0].trim().toLowerCase()) {
      case 'fill':
        fillColor = colorConvert(cs[1].trim());
        break;
      case "fill-opacity":
      case "opacity":
        fillOpacity = double.parse(cs[1].trim());
        break;
      case "stroke":
        strokeColor = colorConvert(cs[1].trim());
        break;
      case "stroke-opacity":
        strokeOpacity = double.parse(cs[1].trim());
        break;
      case "stroke-width":
        String cs1 = cs[1].trim();
        if (cs1.toLowerCase().contains("px")) {
          cs1 = cs1.substring(0, cs1.length - 2);
        }
        strokeWith = double.parse(cs1);
        break;
      case "stroke-miterlimit":
        strokeMiterLimit = double.parse(cs[1].trim());
        break;
      case "stroke-linecap":
        switch (cs[1].trim()) {
          case "round":
            strokeCap = StrokeCap.round;
            break;
          case "square":
            strokeCap = StrokeCap.square;
            break;
          case "butt":
            strokeCap = StrokeCap.butt;
            break;
          default:
            break;
        }
        break;
      case "stroke-linejoin":
        switch (cs[1].trim()) {
          case "round":
            strokeJoin = StrokeJoin.round;
            break;
          case "bevel":
            strokeJoin = StrokeJoin.bevel;
            break;
          case "miter":
            strokeJoin = StrokeJoin.miter;
            break;
          default:
            break;
        }
        break;
      default:
        break;
    }
  }
  if (fillColor != null) {
    fillColor = fillColor.withOpacity(fillOpacity);
    style["fill"] = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
  }
  if (strokeColor != null) {
    strokeColor = strokeColor.withOpacity(strokeOpacity);
    Paint p = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWith;
    if (strokeMiterLimit != null) {
      p.strokeMiterLimit = strokeMiterLimit;
    }
    if (strokeJoin != null) {
      p.strokeJoin = strokeJoin;
    }
    if (strokeCap != null) {
      p.strokeCap = strokeCap;
    }
    style["stroke"] = p;
  }
  return style;
}

Color? colorConvert(String color) {
  if (color[0] == '#') {
    color = color.replaceAll("#", "");
    dynamic converted;
    if (color.length < 6) {
      for (int i = color.length; i < 6; i++) {
        color += "F";
      }
    }
    if (color.length == 6) {
      converted = Color(int.parse("0xFF" + color));
    } else if (color.length == 8) {
      converted = Color(int.parse("0x" + color));
    }
    return converted;
  }
  return colorMap[color];
}

Map<String, dynamic> getMapContent(String s) {
  Map<String, dynamic> m = {};
  String str = checkModelText(s);
  int ninx = 0;
  while (ninx < str.length) {
    int inx = str.indexOf(':');
    String key = str.substring(0, inx).trim();
    str = str.substring(++inx).trim();
    late String value;
    if (str[0] == 'ℛ') {
      ninx = str.indexOf(')');
    } else if (str[0] == '[') {
      ninx = str.indexOf(']');
    }
    ninx = str.indexOf(',', ninx);
    if (ninx < 0) {
      ninx = str.length;
    }
    value = str.substring(0, ninx++);
    if (ninx < str.length) {
      str = str.substring(ninx).trim();
      ninx = 0;
    }
    m[key] = resolveStr(value);
  }
  return m;
}

List<dynamic> getListData(String s) {
  List<dynamic> l = [];
  String str = s;
  int ninx = 0;
  while (ninx < str.length) {
    late String value;
    if (str[0] == 'ℛ') {
      ninx = str.indexOf(')');
    } else if (str[0] == '[') {
      ninx = str.indexOf(']');
    }
    ninx = str.indexOf(',', ninx);
    if (ninx < 0) {
      ninx = str.length;
    }
    value = str.substring(0, ninx++);
    if (ninx < str.length) {
      str = str.substring(ninx).trim();
      ninx = 0;
    }
    if (value.contains('‥')) {
      List<String> ks = value.split('‥');
      var ib = resolveStr(ks[0]);
      var ie = resolveStr(ks[1]);
      for (int i = ib; i <= ie; i++) {
        l.add(i);
      }
    } else {
      var v = resolveStr(value);
      l.add(v);
    }
  }
  return l;
}
