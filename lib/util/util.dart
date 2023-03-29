import 'package:flutter/cupertino.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import '../builder/pattern.dart';
import '../model/locator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jiffy/jiffy.dart';

class Util {
  Util._();

  static clearImageCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  static int getImageCacheSize() {
    return imageCache.currentSize;
  }

  static Future<bool> clearSvgCache() async {
    return await DiskCache().clear();
  }

  static Future<int> getSvgCacheSize() async {
    int size = await DiskCache().cacheSize() ?? 0;
    return size;
  }
}

onShare(Map<String, dynamic> map) {
  String text = map["_text"];
  String? sub = map["_subject"];
  if (sub == null) {
    Share.share(text);
  } else {
    Share.share(text, subject: sub);
  }
}

setLocale() async {
  String l = model.map["userProfile"]["locale"]!;
  if (l == 'en') {
    await Jiffy.locale();
  } else {
    await Jiffy.locale(l);
  }
}

String getRenewDay(Map<String, dynamic> map) {
  bool nextMonth = map["_nextMonth"] ?? false;
  late String day = (nextMonth)
      ? Jiffy().add(months: 1).subtract(days: 1).yMMMMd
      : Jiffy().add(years: 1).subtract(days: 1).yMMMMd;
  //model.map["userProfile"]["renew"] = day;
  return day;
}

String numString(num n, {int dec = 2}) {
  String? c = model.map["lookup"]["NumSep"];
  String ns = "";
  String nns = "";
  if (n is int) {
    ns = n.toString();
    if ((n < 1000) || (c == null)) {
      return ns;
    }
    nns = c + ns.substring(ns.length - 3);
  } else if (n is double) {
    ns = n.toStringAsFixed(dec);
    if ((n < 1000.0) || (c == null)) {
      return ns;
    }
    int d = (dec == 0) ? 3 : 4;
    nns = c + ns.substring(ns.length - d - dec);
  }
  ns = ns.substring(0, ns.length - 3);
  while (ns.length > 3) {
    nns = c! + ns.substring(ns.length - 3) + nns;
  }
  nns = ns + nns;
  return nns;
}

processValue(Map<String, dynamic> map, dynamic value) {
  dynamic _pe = map["_processEvent"] ?? map["_onTap"];
  ProcessEvent? pe = (_pe is String) ? ProcessEvent(_pe) : _pe;
  if (pe == null) {
    return;
  }
  Agent a = model.appActions.getAgent("pattern");
  pe.map ??= map["_inMap"];
  if (value != null) {
    pe.map ??= {};
    pe.map!["_value"] = value;
  }
  a.process(pe);
}
