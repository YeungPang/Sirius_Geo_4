import 'package:flutter/cupertino.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
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
