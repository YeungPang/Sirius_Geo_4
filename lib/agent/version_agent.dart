import 'dart:convert';
import 'dart:core';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class VersionAgent {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late SharedPreferences prefs;
  Map<String, dynamic>? cachedMap;
  late Map<String, dynamic> map;

  Future<Map<String, dynamic>> getMap(String jsonStr) async {
    prefs = await _prefs;
    map = json.decode(jsonStr);
    String? cached =
        prefs.containsKey("cachedMap") ? prefs.getString("cachedMap") : null;
    if (cached != null) {
      cachedMap = json.decode(cached);
      int mts = map["versionTimestamp"] ?? 0;
      Map<String, dynamic> up = cachedMap!["userProfile"];
      int cts = up["timestamp"];
      if (mts > cts) {
        bool reset = map["userProfile"]["reset"];
        if (reset) {
          up = map["userProfile"];
        } else {
          map["userProfile"] = up;
        }
        up["timestamp"] = mts;
        cachedMap = null;
      } else {
        _updateMap(cachedMap!);
        map["userProfile"] = up;
      }
    } else {
      map["userProfile"]["timestamp"] = map["versionTimestamp"];
    }
    String ustr = "{}"; //await _testUserSyncUp();
    if (ustr != "{}") {
      Map<String, dynamic> umap = json.decode(ustr);
      Map<String, dynamic> up = map["userProfile"];
      if (umap["userProfile"] != null) {
        up = umap["userProfile"];
        map["userProfile"] = up;
      }
      up["timestamp"] = umap["versionTimestamp"];
      if (cachedMap == null) {
        cachedMap = umap;
        cachedMap!["userProfile"] = up;
      } else {
        Map<String, dynamic>? um = umap["addAll"];
        if (um != null) {
          Map<String, dynamic>? cm = cachedMap!["addAll"];
          if (cm == null) {
            cachedMap!["addAll"] = um;
          } else {
            cm.addAll(um);
          }
        }
        um = umap["overwrite"];
        if (um != null) {
          Map<String, dynamic>? cm = cachedMap!["overwrite"];
          if (cm == null) {
            cachedMap!["overwrite"] = um;
          } else {
            _update(cm, um, false);
          }
        }
        um = umap["append"];
        if (um != null) {
          Map<String, dynamic>? cm = cachedMap!["append"];
          if (cm == null) {
            cachedMap!["append"] = um;
          } else {
            _update(cm, um, true);
          }
        }
        cachedMap!["userProfile"] = up;
      }
      _updateMap(umap);
      cacheMap();
    }
    if (cachedMap == null) {
      saveProfile();
    }
    return map;
  }

  _updateMap(Map<String, dynamic> update) {
    Map<String, dynamic>? umap = update["addAll"];
    if (umap != null) {
      map.addAll(umap);
    }
    umap = update["overwrite"];
    if (umap != null) {
      _update(map, umap, false);
    }
    umap = update["append"];
    if (umap != null) {
      _update(map, umap, true);
    }
  }

  _update(Map<String, dynamic> omap, Map<String, dynamic> umap, bool append) {
    umap.forEach((key, value) {
      var v = omap[key];
      if (v == null) {
        omap[key] = value;
      } else if ((v is Map<String, dynamic>) &&
          (value is Map<String, dynamic>)) {
        _update(v, value, append);
      } else if (append && ((v is List<dynamic>) && (value is List<dynamic>))) {
        v.addAll(value);
      } else {
        omap[key] = value;
      }
    });
  }

  cacheMap() async {
    if (cachedMap != null) {
      String cmap = json.encode(cachedMap);
      prefs.setString("cachedMap", cmap);
    }
  }

  saveProfile() async {
    cachedMap ??= {};
    cachedMap!["userProfile"] = map["userProfile"];
    cacheMap();
  }

  removeCachedMap() async {
    prefs.remove("cachedMap");
  }

  Future<String> _testUserSyncUp() async {
    Map<String, dynamic> umap = map["userProfile"];
    String ustr = await rootBundle.loadString("assets/models/update.json");
    Map<String, dynamic> update = json.decode(ustr);
    int utimestamp = umap["timestamp"];
    int updatets = update["versionTimestamp"];
    if (updatets > utimestamp) {
      return ustr;
    }
    ustr = await rootBundle.loadString("assets/models/update2.json");
    update = json.decode(ustr);
    updatets = update["versionTimestamp"];
    if (updatets > utimestamp) {
      return ustr;
    }
    return "{}";
  }
}
