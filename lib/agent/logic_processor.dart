import 'dart:math';

import 'package:flutter/cupertino.dart';
import '../builder/pattern.dart';
import '../model/locator.dart';
import 'package:string_validator/string_validator.dart';

final re = RegExp(
    r"[⋀⋁⊻∈⋓⋂∉⋃∄↲⊆⊂⊄≠=≈~⇒&∣|\*\-+－＋⁺⁻\/≁≪≫⋘⋙←→≥≤<>≔⊌⥹⥻⟷@,Φσℒℛℝℳ𝕄𝄁ƒ𝓅⋓ℓητ𝕥‥⊖:]");

const binOp = "∈|@∉⊆⊂⊄≠=≈~⇒&∣⊻≪≫≥≤<>－＋⥹⥻⋘⋙";
const matrixSymbol = "𝔸𝔹ℂ𝔻𝔼𝔽𝕄ℝ𝕥𝄁";
const matrixOp = "¯𝗑ᵀ﹒";

const arithOp = "*/≁-+÷";
const priorArithOp = "*/≁÷";
const checkNeg = "≠=≈≥≤<>≔:,*/≁+÷";
const arithFunc = "㏑㏒𝓮";

const setOP = "⋂⋃⊌－⊖";

const uniqueBiOp = '≔';

const andOr = "⋀⋁";

const symbol = "∀∃∄Ø|";

const unaryOp = "τηƒℓℛℒℳΦ𝓅⋓↲ç∄σ¬∑∆∏⋓⊤㏑㏒𝓮";

const sufOp = "☒!☑☐▶✂";

const statSymbol = "ȳρσĀμχŷỹȲỸŶ𝘗𝘊ℙ";

const powerSymbol = "¯⁰¹²³⁴⁵⁶⁷⁸⁹ⁱʲᵏˡᵐⁿˣʸᵀ";
const elemSymbol = "₀₁₂₃₄₅₆₇₈₉ᵢⱼₖₗₘₙ";
const powerNo = "⁰¹²³⁴⁵⁶⁷⁸⁹⁻";
RegExp rPNo = RegExp(r"[⁰¹²³⁴⁵⁶⁷⁸⁹⁻]");

const nil = 'Ø';
const exist = '∃';

final text = model.map["text"];

class PredResult {
  Map<String, dynamic>? vars;
  List<dynamic>? varList;
  List<int>? pos;
  int? nextPos;
  bool retain = false;
  String loop = nil;
  dynamic returnObj;
  List<PredResult> goalStack = [];
/*   copy(PredResult pr) {
    varList = varList;
    vars = vars;
    pos = pr.pos;
    loop = pr.loop;
    nextPos = pr.nextPos;
    retain = pr.retain;
    returnObj = pr.returnObj;
  } */
}

class ExprVar {
  List<dynamic> expr;
  int pos;
  ExprVar(this.expr, this.pos);
}

class LogicProcessor {
  Map<String, dynamic> myProcess;
  List<PredResult> goalStack = [];
  List<PredResult> predStack = [];
  Map<String, dynamic> vars = {};
  List<dynamic> varList = [];
  //Map<String, dynamic>? clauses;
  PredResult? pr;
  PredResult? gr;

  LogicProcessor(this.myProcess);

  dynamic process(String spec, {Map<String, dynamic>? inVar}) {
    List<String> sl = spec.split(RegExp(r"[,() ]"));
    List<dynamic> args = [];
    String type = '∃';
    if (inVar != null) {
      vars.addAll(inVar);
    }
    if (sl.length > 1) {
      for (int i = 1; i < sl.length; i++) {
        String v = sl[i];
        if (v.isNotEmpty) {
          args.add(v);
          if (v[0] == '_') {
            vars[v] = null;
            type = '∀';
          }
        }
      }
    }
    List<dynamic> expr = (args.isNotEmpty) ? [sl[0], args] : [sl[0]];
    var r = resolveDynList(expr);
    bool fail = (r is bool) ? !r : r == null;
    if (fail) {
      return fail;
    }
    if ((r is bool) && (type == '∀') && (varList.isNotEmpty)) {
      return varList;
    }
    return r;
  }

  dynamic resolveDynList(List<dynamic> expr, {bool ret = true}) {
/*     String retMulti = nil;
    if ((expr.isNotEmpty) && (expr[0] == '⊎')) {
      expr = expr[1];
      retMulti = '⊎';
    } */
    if (expr.contains(",")) {
      return handleList(expr);
    }
    if (expr.any((var item) => (item is String) && setOP.contains(item))) {
      return handleSetOP(expr);
    }
    if (expr.any((var item) => (item is String) && arithOp.contains(item))) {
      return handleArithOP(expr);
    }
    int len = expr.length;
    int i = 0;
    dynamic r;
    bool fail = false;
    pr = PredResult();
    pr!.varList = [];
    pr!.vars = vars;
    pr!.pos = [];
    if (predStack.isNotEmpty) {
      pr!.pos!.addAll(predStack.last.pos!);
    }
    pr!.pos!.add(0);
    pr!.nextPos = 1;
    predStack.add(pr!);
    goalStack = [];
    while (i < len) {
      pr!.pos!.last = i;
      varList = [];
      var e = expr[i];
      if ((i < (len - 2)) &&
          (expr[i + 1] is String) &&
          (binOp.contains(expr[i + 1]))) {
        int j = i + 2;
        List<dynamic> rl = [];
        while ((j < len) && (expr[j] != '⋀') && (expr[j] != '⋁')) {
          rl.add(expr[j++]);
        }
        var e2 = (rl.length == 1) ? rl[0] : rl;
        r = handleBinaryOp(e, expr[i + 1], e2);
        i = j - 1;
        //i += 2;
      } else if ((i < (len - 2)) && (expr[i + 1] == '≔')) {
        if (e is String) {
          if (e[0] != '_') {
            r = false;
            break;
          }
        } else if ((e is List<dynamic>) && ((e.length != 3) || (e[1] != '@'))) {
          r = false;
          break;
        }
        int j = i + 2;
        List<dynamic> rl = [];
        while ((j < len) && (expr[j] != '⋀') && (expr[j] != '⋁')) {
          rl.add(expr[j++]);
        }
        r = ((rl.length == 1) &&
                ((rl[0] is int) || (rl[0] is double) || (rl[0] is bool)))
            ? rl[0]
            : resolveDynList(rl);
        if (e is List<dynamic>) {
          if (e[0] is List<dynamic>) {
            if (e[2] is int) {
              e[0][e[2]] = r;
            } else {
              r = false;
              break;
            }
          } else if (e[0] is Map<String, dynamic>) {
            e[0][e[2]] = r;
          } else {
            r = false;
            break;
          }
        } else {
          vars[e] = (r == nil) ? null : r;
          r = true;
        }
        i = j - 1;
      } else {
        if (e is String) {
          if (unaryOp.contains(e)) {
            r = handleUnaryOp(e, expr[++i]);
          } else if ((e == '⋀') || (e == '⋁')) {
            r = true;
            if (e == '⋁') {
              i++;
            }
          } else if ((i < (len - 1)) && (expr[i + 1] is List<dynamic>)) {
            r = handlePred(e, expr[++i]);
          } else {
            if (e[0] == '_') {
              r = vars[e] ?? e;
              if (r is String) {
                r = handlePred(e, null);
              }
            } else {
              r = handlePred(e, null);
            }
          }
        } else {
          r = (e is List<dynamic>) ? resolveDynList(e) : e;
        }
      }
      fail = (r is bool) ? !r : r == null;
      if (fail) {
        if ((i < (len - 1)) && (expr[i + 1] == '⋁')) {
          fail = false;
          i = i + 2;
        }
        goalStack = pr!.goalStack;
        if (fail && (goalStack.isNotEmpty)) {
          int inx = backTrack(i, false);
          fail = inx == i;
          i = inx;
        }
        if (fail) {
          if (pr!.varList!.isNotEmpty) {
            vars = pr!.varList!.last;
            i = expr.length;
            r = true;
          } else {
            predStack.removeLast();
            if (predStack.isNotEmpty) {
              pr = predStack.last;
            }
            // if (pr!.varList!.isNotEmpty) {
            //   return pr!.varList;
            // } else {
            debugPrint("Fail at: " + expr.toString());
            //return false;
            return r;
            //}
          }
        }
      } else {
        if (pr!.returnObj != null) {
          break;
        }
        pr!.nextPos = ++i;
        if ((i < expr.length) && (expr[i] == '⋁')) {
          i += 2;
          pr!.nextPos = i + 1;
        }
        if (i < expr.length) {
          if ((varList.length > 1) || (pr!.retain)) {
            gr = PredResult();
            vars = varList[0];
            if (!pr!.retain) {
              varList.removeAt(0);
            }
            gr!.varList = varList;
            varList = [];
            gr!.pos = [];
            gr!.pos!.addAll(pr!.pos!);
            gr!.nextPos = i;
            gr!.loop = pr!.loop;
            goalStack.add(gr!);
            pr!.goalStack = goalStack;
            //pr!.varList = varList;
          }
        } else {
          if (varList.isNotEmpty) {
            pr!.varList!.addAll(varList);
          }
          if ((pr!.varList!.isEmpty) || !pr!.varList!.contains(vars)) {
            pr!.varList!.add(vars);
          } else {
            vars = pr!.varList![0];
          }
          goalStack = pr!.goalStack;
          i = backTrack(i, true);
        }
      }
    }
    if (ret) {
      //if (retMulti == '⊎') {
      varList = pr!.varList!;
      //}
      var retObj = pr!.returnObj;
      String loop = (varList.isNotEmpty) ? pr!.loop : nil;
      predStack.removeLast();
      if (predStack.isNotEmpty) {
        pr = predStack.last;
        pr!.loop = loop;
        goalStack = pr!.goalStack;
        if (retObj != null) {
          pr!.returnObj = retObj;
          return retObj;
        }
      }
    } else {
      predStack.removeLast();
      pr = predStack.last;
    }
    return r;
  }

  int backTrack(int inx, bool succ) {
    // if ((gr == null) && (goalStack.isNotEmpty)) {
    //   gr = goalStack.first;
    // }
    gr = goalStack.isNotEmpty ? goalStack.last : null;
    int ri = inx;
    if (succ && (gr != null) && (gr!.loop == '∃')) {
      gr!.varList = [];
      goalStack.removeAt(0);
      return inx;
    }
    if ((gr != null) &&
        (gr!.pos!.length == pr!.pos!.length) &&
        (gr!.varList!.isNotEmpty)) {
      bool stayOn = true;
      if (gr!.pos!.length > 1) {
        for (int j = 0; j < (gr!.pos!.length - 1); j++) {
          if (gr!.pos![j] != pr!.pos![j]) {
            stayOn = false;
            break;
          }
        }
      }
      if (stayOn) {
        if ((!gr!.retain) || (succ)) {
          vars = gr!.varList![0];
          pr!.pos = [];
          pr!.pos!.addAll(gr!.pos!);
          ri = gr!.nextPos!;
        }
        if ((!gr!.retain) || (!succ)) {
          gr!.varList!.removeAt(0);
        }
        if (gr!.varList!.isEmpty) {
          goalStack.removeLast();
        }
      }
    }
    return ri;
  }

  dynamic handlePred(String e1, List<dynamic>? l) {
    if (e1.isEmpty) {
      return e1;
    }
    var ev = (e1[0] == '_') ? vars[e1] ?? e1 : e1;
    if (ev is List<dynamic>) {
      return handleList(ev);
    } else if (ev is! String) {
      return ev;
    }
    String e = ev;
    if (e.isEmpty) {
      return e;
    }
    if (isNumeric(e[0])) {
      dynamic v = getNum(e);
      if (v != null) {
        return v;
      }
    }
    List<dynamic>? r2 = (l != null) ? handleList(l) : null;
    dynamic fact;
    Map<String, dynamic>? facts = myProcess["facts"];
    if (facts != null) {
      fact = facts[e];
    }
    dynamic r;
    if (fact != null) {
      r = fact;
      if (l != null) {
        for (String le in r2!) {
          if (r is Map<String, dynamic>) {
            r = r[le];
          } else {
            return null;
          }
        }
      }
      return r;
    }
    dynamic clause;
    dynamic cls;

    //setc = true;
    Map<String, dynamic>? myClauses = myProcess["clauses"];
    if (myClauses != null) {
      var mycls = myClauses[e];
      if (mycls != null) {
        List<dynamic> cList = [];
        if (mycls is List<dynamic>) {
          if (mycls[0] is String) {
            mycls = mycls.join();
          } else {
            for (var v in mycls) {
              String s = (v is List<dynamic>) ? v.join() : v;
              Clause c = Clause(e, s, myProcess);
              cList.add(c);
            }
            cls = (cList.length > 1) ? cList : cList[0];
          }
        }
        if (cList.isEmpty) {
          cls = Clause(e, mycls, myProcess);
        }
      }
    }
    if (cls != null) {
      String type = '';
      if (l != null) {
        type = '∃';
        for (String s in l) {
          if (s[0] == '_') {
            type = '∀';
          }
        }
      }
      List<String>? s2 =
          (r2 != null) ? r2.map((er) => er as String).toList() : null;
/*       if (cls is List<dynamic>) {
        List<dynamic> cList = [];
        for (Clause c in cls) {
          if (c.match(type, s2, vars)) {
            cList.add(c);
          }
        }
        clause = cList;
      } else { */
      Clause c = cls;
      clause = (c.match(type, s2, vars)) ? c : null;
      //}
    }
    if (clause != null) {
      bool success = false;
      PredResult? mpr = pr;
      List<PredResult> mgoalStack = goalStack;
      List<PredResult> mpredStack = predStack;
      PredResult? mgr = gr;
      //int i = 0;
/*       if (clause is List<dynamic>) {
        List<dynamic> cvarList = [];
        for (Clause c in clause) {
          vars = c.vars;
          goalStack = [];
          predStack = [];
          varList = [];
          pr = null;
          gr = null;
          r = resolveDynList(c.preds);
          bool success = (r is bool) ? r : r != null;
          if (success) {
            if ((c.clientVars != null) && (varList.isNotEmpty)) {
              for (Map<String, dynamic> v in varList) {
                Map<String, dynamic> cVars = {};
                if ((mpr != null) && (mpr.vars != null)) {
                  cVars.addAll(mpr.vars!);
                }
                c.clientVars!.forEach((key, value) {
                  cVars[key] = v[value];
                });
                cvarList.add(cVars);
              }
            }
            if (pr!.returnObj != null) {
              break;
            }
            i++;
          }
        }
        varList = cvarList;
        if (varList.isNotEmpty) {
          mpr!.vars = varList[0];
        }
        success = i > 0;
      } else { */
      Clause c = clause;
      vars = c.vars;
      goalStack = [];
      predStack = [];
      varList = [];
      pr = null;
      gr = null;
      r = resolveDynList(c.preds);
      success = (r is bool) ? r : r != null;
      if (success) {
/*           if (c.clientVars != null) {
            c.clientVars!.forEach((key, value) {
              mpr!.vars![key] = vars[value];
            });
          } */
        if (varList.isNotEmpty) {
          List<dynamic> cvarList = varList;
          varList = [];
          for (Map<String, dynamic> v in cvarList) {
            Map<String, dynamic> cvars = {};
            cvars.addAll(mpr!.vars!);
            if (c.inargs != null) {
              for (String key in c.inargs!) {
                cvars[key] = v[key];
              }
            }
            varList.add(cvars);
          }
        } else if (c.inargs != null) {
          for (String key in c.inargs!) {
            mpr!.vars![key] = vars[key];
          }
        }
        //}
      }
      var retObj = pr!.returnObj ?? success;
      pr = mpr;
      vars = mpr!.vars ?? {};
      goalStack = mgoalStack;
      predStack = mpredStack;
      gr = mgr;
      return retObj;
    }
    if (l == null) {
      if ((e[0] == "'") || (e[0] == '"')) {
        return e.substring(1, e.length - 1);
      }
      return e;
    }
    return null;
  }

  dynamic handleUnaryOp(String e, List<dynamic> l) {
    if (e == 'ℛ') {
      List<dynamic> r = handleList(l);
      int len = r.length;
      switch (len) {
        case 1:
          return model.appActions.getResource(r[0], null);
        case 2:
          return model.appActions.getResource(r[0], r[1]);
        case 3:
          return model.appActions.getResource(r[0], r[1], value: r[2]);
      }
      if (len > 1) {
      } else if (len > 0) {}
      return null;
    }
    if ((e == 'ƒ') || (e == '𝓅')) {
      String name = l[0];
      if (name[0] == '_') {
        name = vars[name];
      }
      List<dynamic> rl = l;
      rl.removeAt(0);
      if (rl.isNotEmpty) {
        rl = handleList(rl);
        return model.appActions.doFunction(name, rl[0], vars);
      } else {
        return model.appActions.doFunction(name, null, vars);
      }
/*       List<dynamic> rl = handleList(l);
      int len = rl.length;
      switch (len) {
        case 1:
          return model.appActions.doFunction(rl[0], null, vars);
        case 2:
          return model.appActions.doFunction(rl[0], rl[1], vars);
        default:
          return null;
      } */
      // Function getFunc = model.appActions.getFunction(rl[0]);
      // if (getFunc == null) {
      //   return null;
      // }
      // switch (len) {
      //   case 1:
      //     return getFunc(vars);
      //   case 2:
      //     return getFunc(rl[1], vars);
      //   default:
      //     return null;
      // }
    }
    if (e == 'ℳ') {
      Map<String, dynamic> m = {};
      for (var ml in l) {
        if (ml is List<dynamic>) {
          dynamic d = ml[2];
          if (ml.length > 3) {
            List<dynamic> lm = [];
            for (int i = 2; i < ml.length; i++) {
              lm.add(ml[i]);
            }
            d = lm;
          }
          bool notVar = true;
          if ((d is String) && (d[0] == '_')) {
            d = vars[d];
            notVar = false;
          }
          if (d is String) {
            d = handlePred(d, null);
          } else if ((d is List<dynamic>) && (notVar)) {
            d = resolveDynList(d, ret: false);
          }
          m[ml[0]] = d;
        }
      }
      return m;
    }
    if ((e == 'ç') && (l.length == 1)) {
      var r = l[0];
      if (r is String) {
        r = vars[r] ?? r;
      }
      return r;
    }
    var r = (l.isEmpty) ? l : resolveDynList(l, ret: false);
    if (r is String) {
      r = vars[r] ?? r;
    }
    switch (e) {
      case 'η':
        if (r is List<dynamic>) {
          return r.length;
        }
        if (r is Map<String, dynamic>) {
          return r.length;
        }
        if (r is String) {
          return r.length;
        }
        return null;
      case 'Φ':
        if (r is List<dynamic>) {
          Function? getPat = model.appActions.getPattern(r[0]);
          if (getPat != null) {
            return getPat(r[1]);
          }
        } else {
          Function? getPat = model.appActions.getPattern(r);
          if (getPat != null) {
            return getPat(vars);
          }
        }
        return null;
      case '⊤':
        return text[r];
      case 'σ':
        if (r is ProcessPattern) {
          return r.getWidget();
        }
        Function? getPat = model.appActions.getPattern(r);
        if (getPat != null) {
          ProcessPattern p = getPat(vars);
          return p.getWidget();
        }
        return null;
      case 'ℒ':
        if (r is List<dynamic>) {
          return r;
        }
        if (r is String) {
          r = vars[r] ?? r;
        }
        return [r];
      case '⋓':
        if (r is Map<String, dynamic>) {
          vars.addAll(r);
        }
        return true;
      case '∄':
        if (r is String) {
          if (r.isEmpty) {
            return true;
          }
          if (r[0] == '_') {
            return true;
          }
          return false;
        }
        if (r is List<dynamic>) {
          return r.isEmpty;
        }
        return (r == null) || (r == nil);
      case '¬':
        if (r is bool) {
          return !r;
        }
        return null;
      case 'τ':
        debugPrint(r.toString());
        return true;
      case 'ç':
        return r;
      case '↲':
        pr!.returnObj = r;
        return r;
/*       case '∀':
        if (varList.isEmpty) {
          varList.add(vars);
        }
        pr!.retain = true;
        return true;
 */
      case '㏑':
      case '㏒':
      case '𝓮':
        List<dynamic> value = [e, r];
        return getNum(value);
      default:
        return null;
    }
  }

  dynamic handleBinaryOp(var e1, String op, var e2) {
    var r1 = (e1 is List<dynamic>)
        ? (((e1[0] == '∀') || (e1[0] == '∃'))
            ? e1
            : resolveDynList(e1, ret: false))
        : ((e1 is String) && (e1[0] == '_'))
            ? vars[e1] ?? e1
            : handlePred(e1, null);
    var r2 = (e2 is List<dynamic>)
        ? resolveDynList(e2, ret: false)
        : ((e2 is String) && (e2[0] == '_'))
            ? vars[e2] ?? e2
            : (e2 is String)
                ? handlePred(e2, null)
                : e2;
    switch (op) {
      case '∈':
        if (e1 is List<dynamic>) {
          if ((e1[0] == '∀') || (e1[0] == '∃')) {
            if (e1[1] is List<dynamic>) {
              r1 = e1[1][0];
            } else {
              r1 = e1[1];
            }
            pr!.loop = e1[0];
          }
        }
        if ((r1 is String) && (r1[0] == '_')) {
          if (r2 is List<dynamic>) {
            if (r2.isEmpty) {
              return false;
            }
            for (int i = 0; i < r2.length; i++) {
              Map<String, dynamic> rvars = {};
              rvars.addAll(vars);
              rvars[r1] = r2[i];
              varList.add(rvars);
            }
            vars = varList[0];
          } else if (r2 is Map<String, dynamic>) {
            List<dynamic> keys = r2.keys.toList();
            if (keys.isEmpty) {
              return false;
            }
            List<dynamic> values = r2.values.toList();
            for (int j = 1; j < keys.length; j++) {
              Map<String, dynamic> rvars = {};
              rvars.addAll(vars);
              rvars[r1] = [keys[j], values[j]];
              varList.add(rvars);
            }
            vars = varList[0];
          } else {
            vars[r1] = r2;
            varList.add(vars);
          }
          return r2;
        } else if ((r2 is List<dynamic>) && (r2.isNotEmpty)) {
          return r2.contains(r1);
        } else if (r2 is Map<String, dynamic>) {
          if (r2.isNotEmpty) {
            return r2[r1];
          }
        }
        return null;
      case "≪":
        if ((r1 is String) && (r1[0] == '_')) {
          if ((r2 is List<dynamic>) && (r2.isNotEmpty)) {
            vars[e1] = r2[0];
            r2.removeAt(0);
            return vars[e1];
          }
        }
        if (r1 is List<dynamic>) {
          r1.add(r2);
          return r1;
        }
        return null;
      case "≫":
        if ((r2 is String) && (r2[0] == '_')) {
          if ((r1 is List<dynamic>) && (r1.isNotEmpty)) {
            vars[e2] = r1.last;
            r1.removeLast();
            return vars[e2];
          }
        }
        if (r2 is List<dynamic>) {
          r2.insert(0, r1);
          return r2;
        }
        return null;
      case "@":
        if (r1 is String) {
          r1 = handlePred(r1, null);
        }
        if ((r1 is List<dynamic>) && (r2 is int)) {
          return r1[r2];
        }
        if (r1 is Map<String, dynamic>) {
          return r1[r2];
        }
        return null;
      case '=':
        return checkEqual(r1, r2);
      case '≈':
        return checkApprox(r1, r2);
      case '>':
        return r1 > r2;
      case '<':
        return r1 < r2;
      case '≥':
        return r1 >= r2;
      case '≤':
        return r1 <= r2;
      default:
        return null;
    }
  }

  List<dynamic> handleList(List<dynamic> l) {
    List<dynamic> rl = [];
    int len = l.length;
    for (int j = 0; j < len; j++) {
      var v = l[j];
      if (v != ',') {
        if ((v is String) && (v[0] == '_')) {
          var v1 = vars[v] ?? v;
          if ((v1 is String) && (v1[0] != '_')) {
            v1 = handlePred(v1, null);
          }
          rl.add(v1);
        } else {
          if (v is List<dynamic>) {
            rl.add(resolveDynList(v, ret: false));
          } else {
            if (v is String) {
              if ((j < len - 1) && (l[j + 1] is List<dynamic>)) {
                if (unaryOp.contains(v)) {
                  v = handleUnaryOp(v, l[++j]);
                } else {
                  v = handlePred(v, l[++j]);
                }
              } else {
                v = handlePred(v, null);
              }
            }
            rl.add(v);
          }
        }
      }
    }
    return rl;
  }

  dynamic handleSetOP(List<dynamic> expr) {
    if (expr.length < 3) {
      return null;
    }
    ExprVar ev = ExprVar(expr, 0);
    var e0 = getVar(ev);
    if ((e0 is String) && (e0 != nil)) {
      return null;
    }
    var e1 = expr[ev.pos++];
    if (!setOP.contains(e1)) {
      return null;
    }
    var e2 = getVar(ev);
    bool isMap = (e0 is Map<String, dynamic>) || (e2 is Map<String, dynamic>);
    int len = expr.length;
    if (isMap) {
      Map<String, dynamic> e = (e1 == '⊌') ? e0 : {};
      if ((e1 != '⊌') && (e0 is Map<String, dynamic>)) {
        e.addAll(e0);
      }
      while (ev.pos <= len) {
        String op = e1;
        Map<String, dynamic> m = e2;
        switch (op) {
          //case '⊎':
          case '⊌':
            e.addAll(m);
            break;
          case '⋃':
            Map<String, dynamic> et = {};
            et.addAll(m);
            e.addAll(et);
            break;
          case '⋂':
            e.forEach((key, value) {
              e[key] = m[key];
            });
            break;
          case '－':
            e.forEach((key, value) {
              e[key] = (m[key] != null) ? null : value;
            });
            break;
          default:
            return null;
        }
        if (ev.pos < len) {
          e1 = expr[ev.pos++];
          e2 = getVar(ev);
        } else {
          ev.pos++;
        }
      }
      return e;
    } else {
      if (e2 is! List<dynamic>) {
        return null;
      }
      List<dynamic> e = (e1 == '⊌') ? e0 : [];
      if ((e1 != '⊌') && (e0 is! String)) {
        e.addAll(e0);
      }
      while (ev.pos <= len) {
        String op = e1;
        List<dynamic> m = e2;
        switch (op) {
          //case '⊎':
          case '⊌':
          case '⋃':
            e.addAll(m);
            break;
          case '⋂':
            for (var element in e) {
              if (!m.contains(element)) {
                e.remove(element);
              }
            }
            break;
          case '－':
            for (var element in m) {
              e.remove(element);
            }
            break;
          default:
            return null;
        }
        if (ev.pos < len) {
          e1 = expr[ev.pos++];
          e2 = getVar(ev);
        } else {
          break;
        }
      }
      return e;
    }
  }

  dynamic handleArithOP(List<dynamic> expr) {
    if (expr.length < 3) {
      if ((expr.length == 2) && (expr[0] == '-')) {
        expr.insert(0, 0);
      } else {
        return null;
      }
    }
    ExprVar ev = ExprVar(expr, 0);
    var e0 = getVar(ev);
    if (e0 is String) {
      return nextStringOp(e0, ev);
    }
    if (e0 is List<dynamic>) {
      return nextListOp(e0, ev);
    }
    if (e0 is! num) {
      return null;
    }
    return nextArithOp(e0, ev);
  }

  String? nextStringOp(String s1, ExprVar ev) {
    var e1 = ev.expr[ev.pos++];
    if (e1 != '+') {
      return null;
    }
    String s2 = getVar(ev).toString();
    if (ev.pos < ev.expr.length) {
      s2 = nextStringOp(s2, ev)!;
    }
    return s1 + s2;
  }

  List<dynamic>? nextListOp(List<dynamic> d1, ExprVar ev) {
    var e1 = ev.expr[ev.pos++];
    if (e1 != '+') {
      return null;
    }
    var d2 = getVar(ev);
    if (d2 is List<dynamic>) {
      if (ev.pos < ev.expr.length) {
        d2 = nextListOp(d2, ev);
      }
      d1.addAll(d2);
    } else {
      d1.add(d2);
      if (ev.pos < ev.expr.length) {
        return nextListOp(d1, ev);
      }
    }
    return d1;
  }

  num? nextArithOp(num n1, ExprVar ev) {
    var e1 = ev.expr[ev.pos++];
    if (!arithOp.contains(e1)) {
      return null;
    }
    var e0 = getVar(ev);
    if (e0 is! num) {
      return null;
    }
    num n2 = e0;
    if (priorArithOp.contains(e1)) {
      switch (e1) {
        case '*':
          n2 = n2 * n1;
          break;
        case '/':
          n2 = n1 / n2;
          break;
        case '≁':
          n2 = n1 % n2;
          break;
        case '÷':
          n2 = n1 ~/ n2;
          break;
      }
      if (ev.pos < ev.expr.length) {
        return nextArithOp(n2, ev);
      }
      return n2;
    } else {
      if (ev.pos < ev.expr.length) {
        n2 = nextArithOp(n2, ev)!;
      }
      switch (e1) {
        case '+':
          n2 = n2 + n1;
          break;
        case '-':
          n2 = n1 - n2;
          break;
        default:
          return null;
      }
      return n2;
    }
  }

  num? getNum(dynamic value) {
    num? base;
    String exp;
    dynamic bStr;
    if (value is String) {
      switch (value[0]) {
        case '㏑':
        case '㏒':
          bStr = value.substring(1);
          base = num.tryParse(bStr);
          if (value[0] == '㏑') {
            return log(base!);
          }
          return log(base!) / ln10;
        case '𝓮':
          bStr = '𝓮';
          base = e;
          break;
      }
      List<String> sl = value.split(rPNo);
      if (sl.length == 1) {
        bStr = vars[value] ?? value;
        return num.tryParse(bStr);
      }
      int l = sl[0].length;
      bStr = sl[0];
      exp = value.substring(l);
    } else {
      List<dynamic> ld = value;
      bStr = (ld[0] is List<dynamic>)
          ? resolveDynList(ld[0], ret: false)
          : vars[ld[0]] ?? ld[0];
      if (arithFunc.contains(bStr)) {
        dynamic bd = (ld[1] is List<dynamic>)
            ? resolveDynList(ld[1], ret: false)
            : vars[ld[1]] ?? ld[1];
        if (bd is num) {
          base = bd;
        } else {
          base = num.tryParse(bStr);
        }
        switch (bStr) {
          case '㏑':
            return log(base!);
          case '㏒':
            return log(base!) / ln10;
          case '𝓮':
            return pow(e, base!);
          default:
            break;
        }
      }
      exp = (ld[1] is List<dynamic>)
          ? resolveDynList(ld[1], ret: false)
          : vars[ld[1]] ?? ld[1];
    }
    if (bStr is num) {
      base = bStr;
    } else {
      bStr = vars[bStr] ?? bStr;
      if (bStr != '𝓮') {
        base = num.tryParse(bStr);
      }
      if (base == null) {
        return null;
      }
    }
    int iexp = 0;
    bool neg = false;
    for (int i = 0; i < exp.length; i++) {
      int k = powerNo.indexOf(exp[i]);
      if (k < 0) {
        return null;
      }
      if (k == 10) {
        if (i != 0) {
          return null;
        }
        neg = true;
      } else {
        iexp = iexp * 10 + k;
      }
    }
    iexp = neg ? iexp + -1 : iexp;
    return pow(base, iexp);
  }

  dynamic getVar(ExprVar ev) {
    var e = ev.expr[ev.pos++];
    if (e is List<dynamic>) {
      return resolveDynList(e);
    }
    if (e is String) {
      var r = (e[0] == '_') ? vars[e] : e;
      if (r is String) {
        var e1 = (ev.pos < ev.expr.length) ? ev.expr[ev.pos] : null;
        if (e1 is List<dynamic>) {
          r = (unaryOp.contains(e)) ? handleUnaryOp(e, e1) : handlePred(e, e1);
          ev.pos++;
        } else {
          r = handlePred(e, null);
        }
      }
      return r;
    }
    return e;
  }
}

class Clause {
  final String name;
  final String spec;
  final Map<String, dynamic> process;
  late Map<String, dynamic> vars;
  //Map<String, dynamic> rvars;
  //Map<String, dynamic>? clientVars;
  List<dynamic> preds = [];
  List<dynamic> varStack = [];
  String? type;
  String? argStr;
  List<dynamic>? inargs;

  Clause(this.name, this.spec, this.process);

  init() {
    vars = {};
    if (preds.isEmpty) {
      List<String> sl = spec.split('|');
      String predSpec;
      if (sl.length > 1) {
        predSpec = sl[1].trim();
        argStr = sl[0].trim();
        if ((argStr![0] == '∀') || (argStr![0] == '∃')) {
          type = argStr![0];
          argStr = argStr!.substring(1).trimLeft();
        }
        inargs = splitArgs(argStr!);
      } else {
        predSpec = spec.trim();
      }
      preds = splitPred(predSpec);
    }
    return preds.isNotEmpty;
  }

  bool match(String mtype, List<String>? margs, Map<String, dynamic> mVars) {
    init();
    //clientVars = null;
    if ((margs == null) || (margs.isEmpty)) {
      if (argStr == null) {
        return true;
      }
    } else if (argStr == null) {
      return false;
    }
    if ((mtype != type) && (type != null)) {
      return false;
    }
    List<dynamic> args = inargs!;
    if ((margs != null) && (margs.length != args.length)) {
      return false;
    }
    for (int i = 0; i < args.length; i++) {
      if (margs != null) {
        if ((margs[i] != args[i]) &&
            !((args[i][0] == '_') || (margs[i][0] == '_'))) {
          return false;
        }
        if (args[i][0] == '_') {
          if (margs[i][0] == '_') {
            vars[args[i]] = mVars[margs[i]];
          } else {
            vars[args[i]] = margs[i];
          }
        }
/*         if (margs[i][0] == '_') {
          clientVars ??= {};
          clientVars![margs[i]] = args[i];
        } */
      } else {
        if (args[i][0] != '_') {
          return false;
        }
        var v = mVars[args[i]];
        // if (v == null) {
        //   return false;
        // }
        vars[args[i]] = v;
/*         if ((v == nil) || (v == null)) {
          clientVars ??= {};
          clientVars![args[i]] = args[i];
        } */
      }
    }
    return true;
  }
}

List<String> splitArgs(String argStr) {
  List<String> args = argStr.split(',');
  for (int i = 0; i < args.length; i++) {
    String a = args[i].trim();
    if (a[0] == '(') {
      a = a.substring(1);
    } else if (a[a.length - 1] == ')') {
      a = a.substring(0, a.length - 1);
    }
    args[i] = a;
  }
  return args;
}

List<String> splitExpr(String exStr) {
  List<String> sl = exStr.split(re);
  List<String> rl = [];
  int i = 0;
//   int l = 0;
  for (String s in sl) {
    i += s.length;
    /*
    l = rl.length - 1;
    if ((l >= 0) &&
        (rl[l] == "-") &&
        isNumeric(s) &&
        ((l == 0) || checkNeg.contains(rl[l - 1]))) {
      s = '-' + s.trim();
      rl.removeLast();
    } */
    rl.add(s.trim());
    if (i < exStr.length) {
      rl.add(exStr[i]);
      i++;
    }
  }
  return rl;
}

List<dynamic> splitPred(String predSpec) {
  List<dynamic> predStack = [];
  List<String> bracStack = [];
  RegExp reb = RegExp(r"[\[({]");
  List<String> brac = predSpec.split(reb);
  reb = RegExp(r"[\])}]");
  int ketLen = 0;
  int bracLen = 0;
  List<dynamic> cp = [];
  int i = 0;
  for (String s in brac) {
    if ((predSpec[i] == '(') || (predSpec[i] == '[') || (predSpec[i] == '{')) {
      bracLen++;
      switch (predSpec[i]) {
        case '(':
          bracStack.add(')');
          break;
        case '[':
          bracStack.add(']');
          break;
        case '{':
          bracStack.add('}');
          break;
      }
      List<dynamic> acp = cp;
      cp = [];
      if (predSpec[i] == '[') {
        if (acp.isNotEmpty &&
            (acp.last is String) &&
            ((acp.last[0] == '_') || isAlphanumeric(acp.last))) {
          cp.add(acp.last);
          cp.add('@');
          acp.removeLast();
        } else {
          acp.add('ℒ');
        }
      }
      if (predSpec[i] == '{') {
        acp.add('ℳ');
      }
      if ((predSpec[i] == '(') &&
          (acp.isNotEmpty &&
              (acp.last is String) &&
              ((acp.last[0] == '_') || isAlphanumeric(acp.last)))) {
        cp.add(acp.last);
        acp.removeLast();
        acp.add('ƒ');
        cp.add(',');
        List<dynamic> icp = cp;
        cp = [];
        icp.add(cp);
        acp.add(icp);
      } else {
        acp.add(cp);
      }
      predStack.add(acp);
      i++;
    }
    if (s.isNotEmpty) {
      List<String> ket = s.split(reb);
      for (String sk in ket) {
/*         if (bracStack.isNotEmpty && (bracStack.last == '}') && sk.isNotEmpty) {
          List<String> items = sk.split(",");
          for (String item in items) {
            if (item.isNotEmpty && (!item.contains(":"))) {
              throw Exception("Invalid map: " + sk);
            }
          }
        } */
        if ((i < predSpec.length) &&
            ((predSpec[i] == ')') ||
                (predSpec[i] == ']') ||
                (predSpec[i] == '}'))) {
          ketLen++;
          if (bracStack.isEmpty) {
            throw Exception("Expect opening for " + predSpec[i] + " at " + s);
          }
          cp = predStack[predStack.length - 1];
          if (predSpec[i] != bracStack.last) {
            throw Exception("Expect " +
                bracStack.last +
                " but found " +
                predSpec[i] +
                " at " +
                s);
          } else {
            bracStack.removeLast();
          }
          predStack.removeLast();
          i++;
        }
        i += sk.length;
        if (sk.isNotEmpty) {
          // if (unaryOp.contains(sk.trim())) {
          //   cp.add(sk);
          // } else {
          List<String> skl = splitExpr(sk);
          for (String sks in skl) {
            sks = sks.trim();
            if (sks.isNotEmpty) {
              dynamic vs = int.tryParse(sks) ?? double.tryParse(sks);
              vs ??= (sks == "true")
                  ? true
                  : (sks == "false")
                      ? false
                      : sks;
              cp.add(vs);
            }
          }
        }
      }
    }
  }
  //List<dynamic> ucp = updatePredFunc(cp);
  if (bracStack.isNotEmpty) {
    throw Exception("Missing closing " + bracStack.last + " for " + predSpec);
  }
  if (bracLen != ketLen) {
    throw Exception("Brac length is " +
        bracLen.toString() +
        " and ket length is " +
        ketLen.toString());
  }
  return updatePredFunc(cp);
}

List<dynamic> updatePredFunc(List<dynamic> predList) {
  List<dynamic> newList = [];
  int plen = predList.length - 1;

  if (predList.contains(":")) {
    int i = 0;
    while (i < predList.length) {
      if (predList[i] == ',') {
        newList.add(',');
        i++;
      }
      if (predList[i + 1] != ':') {
        throw Exception("Invalid map: " +
            predList[i].toString() +
            predList[i + 1].toString());
      }
      List<dynamic> ml = [predList[i++], ',', predList[++i]];
      i++;
      while ((i < predList.length) && (predList[i] != ',')) {
        ml.add(predList[i++]);
      }
      newList.add(ml);
    }
    newList = updatePredFunc(newList);
    return newList;
  }

  for (int i = 0; i <= plen; i++) {
    var el = predList[i];
    int ai = i + 1;
    if ((el is String) &&
        (!re.hasMatch(el)) &&
        (i < plen) &&
        (predList[ai] is List<dynamic>)) {
      if ((el == 'ℳ') && (!predList[ai].contains(":"))) {
        throw Exception("Invalid map: " + predList[ai].toString());
      }
      List<dynamic> pl = updatePredFunc(predList[ai]);
      newList.add([el, pl]);
      i++;
    } else {
      if (el is List<dynamic>) {
        List<dynamic> pl = updatePredFunc(el);
        newList.add(pl);
      } else {
        if ((el is String) &&
            (el == '-') &&
            ((predList[i + 1] is int) || (predList[i + 1] is double)) &&
            ((i == 0) ||
                ((predList[i - 1] is String) &&
                    checkNeg.contains(predList[i - 1])))) {
          el = predList[i + 1] * -1;
          i++;
        }
        newList.add(el);
      }
    }
  }
  return newList;
}

bool checkApprox(var r1, var r2) {
  if (r1 == r2) {
    return true;
  }
  if (r1 is List<dynamic>) {
    if (r2 is List<dynamic>) {
      if (r1.length != r2.length) {
        return false;
      }
      for (int j = 0; j < r1.length; j++) {
        if (!r1.contains(r2[j])) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }
  return checkEqual(r1, r2);
}

bool checkEqual(var r1, var r2) {
  if (r1 == r2) {
    return true;
  }
  if (r1 is List<dynamic>) {
    if (r2 is List<dynamic>) {
      if (r1.length != r2.length) {
        return false;
      }
      for (int j = 0; j < r1.length; j++) {
        if (!checkEqual(r1[j], r2[j])) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  } else if (r1 is Map<String, dynamic>) {
    if (r2 is Map<String, dynamic>) {
      if (r1.length != r2.length) {
        return false;
      }
      List<dynamic> keys = r1.keys.toList();
      for (int j = 0; j < keys.length; j++) {
        var v2 = r2[keys[j]];
        if (v2 == null) {
          return false;
        }
        if (!checkEqual(r1[keys[j]], v2)) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }
  return false;
}
