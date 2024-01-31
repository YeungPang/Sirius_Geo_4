import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../agent/config_agent.dart';
import '../agent/db_agent.dart';
import '../agent/version_agent.dart';
import '../builder/pattern.dart';
import '../instance_manager.dart';

class MainModel {
  final String path = "models/";
  final String mainModelName = "geo.json";
  final int dbVersion = 1;
  final String dbName = "prototype4.db";
  final String dbTable =
      "CREATE TABLE Cache(id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP, name TEXT NOT NULL, model TEXT NOT NULL);";
  final String dbindex = "CREATE INDEX idx_cache_name ON Cache(name);";
  late DataBaseAgent dbAgent;
  bool skipDB = true;
  bool isLocal = false;
  Map<String, dynamic> modelTimestamp = {};

  DataBaseAgent get dba => dbAgent;

  double screenHeight = 812.0;
  double screenWidth = 375.0;
  late double appBarHeight;

  late double fontScale;
  late double sizeScale;
  late double scaleHeight;
  late double scaleWidth;
  late double size5;
  late double size10;
  late double size20;

  final apkVersion = "0.17";

  late AppActions appActions;

  BuildContext? context;

  Map<String, dynamic> stateData = {};
  Map<String, dynamic> map = {};

  List<List<dynamic>> stack = [];

  int _count = 0;

  int get count => _count;

  final VersionAgent versionAgent = VersionAgent();
  List<String> jFiles = [];
  List<String> get jsonFiles => jFiles;
  List<String> jLoadedFiles = [];
  Set<String> jLoadingSet = {};

  Widget? currScreen;
  Widget? get currentScreen => currScreen;

  setCurrScreen(Widget screen) {
    currScreen = screen;
  }

  addJFile(String fname) {
    if (fname[0] == "[") {
      List<String> lf = fname.substring(1, fname.length - 1).split(",");
      for (String f in lf) {
        String fn = f.trim();
        if (!jFiles.contains(fn)) {
          jFiles.add(fn);
        }
      }
    } else {
      String fn = fname.trim();
      if (!jFiles.contains(fn)) {
        jFiles.add(fn);
      }
    }
  }

  resetJsonFile() {
    jFiles = [];
  }

  addCount() {
    _count++;
  }

  Future<String> loadString(String fname) async {
    int it = 0;
    String jsonStr = "";
    while (it < 3) {
      it++;
      try {
        final httpAssetFuture = InstanceManager().assetRequest(fname);
        // NB: We can't use response.body below because it uses response charset (which we don't return) defaulting to latin1.
        jsonStr = await httpAssetFuture
            .timeout(const Duration(seconds: 30))
            .then((response) => utf8.decode(response.bodyBytes))
            .then((String jsonStr) =>
                InstanceManager().decryptTransparentAsset(jsonStr));
        break;
      } on TimeoutException catch (_) {
        jsonStr = "";
      } catch (ex) {
        rethrow;
      }
    }
    return jsonStr;
  }

  Future<String> getLocalJson(dynamic context) async {
    String fname = path + ((context is String) ? context : mainModelName);
    if (skipDB) {
      return await rootBundle.loadString(fname);
    }
    List<Map<String, dynamic>> dbData = await dbAgent.query("Cache", {
      "where": "name = ?",
      "list": [fname]
    });
    late String model;
    if (dbData.isEmpty) {
      // DateTime now = DateTime.now();
      // final DateTime utcNow = now.toUtc();
      // final int timestamp = utcNow.millisecondsSinceEpoch;
      model = await rootBundle.loadString(fname);
      await dbAgent.insert("Cache", {"name": fname, "model": model});
    } else {
      var tsdt = dbData[0]["timestamp"];
      int ts = tsdt is int
          ? tsdt
          : DateTime.parse(tsdt).millisecondsSinceEpoch ~/ 1000;
      int nts = modelTimestamp[fname] ?? 0;
      if (ts >= nts) {
        model = dbData[0]["model"];
      } else {
        model = await rootBundle.loadString(fname);
        var data = {"model": model, "timestamp": nts};
        var id = dbData[0]["id"];
        await dbAgent
            .update("Cache", {"data": data, "where": "id = ?", "id": id});
      }
    }
    //await Future.delayed(const Duration(milliseconds: 500));
    return model;
    //return DefaultAssetBundle.of(context).loadString(mainModelName);
  }

  Future<String> getJson(dynamic context) async {
    if (isLocal) {
      return getLocalJson(context);
    }
    String fname = path + ((context is String) ? context : mainModelName);
    late String model;
    if (skipDB) {
      dbAgent.deleteDB();
      model = await loadString(fname);
    } else {
      List<Map<String, dynamic>> dbData = await dbAgent.query("Cache", {
        "where": "name = ?",
        "list": [fname]
      });
      if (dbData.isEmpty) {
        // DateTime now = DateTime.now();
        // final DateTime utcNow = now.toUtc();
        // final int timestamp = utcNow.millisecondsSinceEpoch;
        model = await loadString(fname);
        await dbAgent.insert("Cache", {"name": fname, "model": model});
      } else {
        Map<String, dynamic>? foundModel = InstanceManager().models.firstWhere(
            (m) => fname == m['filename'],
            orElse: () => <String, dynamic>{});
        int nts = foundModel.isEmpty ? 0 : foundModel["timestamp"] ?? 0;
        var tsdt = dbData[0]["timestamp"];
        int ts = tsdt is int
            ? tsdt
            : DateTime.parse(tsdt).millisecondsSinceEpoch ~/ 1000;
        if (ts >= nts) {
          model = dbData[0]["model"];
        } else {
          model = await loadString(fname);
          var data = {"model": model, "timestamp": nts};
          var id = dbData[0]["id"];
          await dbAgent
              .update("Cache", {"data": data, "where": "id = ?", "id": id});
        }
      }
    }
    //await Future.delayed(const Duration(milliseconds: 500));
    return model;
    //return DefaultAssetBundle.of(context).loadString(mainModelName);
  }

  Future<Map<String, dynamic>> getMap(BuildContext context) async {
    String jsonStr = "";
    if (isLocal) {
      jsonStr = await getLocalJson(context);
    } else {
      final profileFuture = InstanceManager().loadProfileData(); // [0]
      final jsonFuture = getJson(context); // [1]
      final profileAndJson = await Future.wait(
          [profileFuture, jsonFuture]); // Wait for both to complete
      jsonStr = profileAndJson[1];
      if (jsonStr.isNotEmpty && !jsonStr.endsWith('}')) {
        throw Exception("Unable to dynamically replace profile in model JSON");
      }
      String profileStr = profileAndJson[0];
      if (profileStr.isEmpty || (profileStr == '{}')) {
        profileStr = '''{
        "appVersion": "",
        "userToken": "",
        "reset": true,
        "lang": "English (UK)",
        "locale": "de",
        "configLives": 5,
        "lives": 5,
        "liveTimestamp": 0,
        "progress": [],
        "versions": "0.0",
        "userType": "User",
        "timestamp": 1636410287,
        "lastsync": 1627510285,
        "renew": ""
    }''';
      }

      jsonStr =
          '${jsonStr.substring(0, jsonStr.length - 1)}, "userProfile": $profileStr}';
    }
    map = json.decode(jsonStr);
    stateData["map"] = map;
    Map<String, dynamic> facts = map["patterns"]["facts"];
    facts["apkVersion"] = apkVersion;
    skipDB = map["noCache"] ?? false;
    String ljfiles = map["loadJson"] ?? "";
    if (ljfiles.isNotEmpty) {
      addJFile(ljfiles);
    }
    await loadJFile();
    return map;
  }

  Future<String> getFileString(String fn) async {
    if (jLoadingSet.contains(fn)) {
      while (jLoadingSet.contains(fn)) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return "";
    }
    jLoadingSet.add(fn);
    String jstr = await getJson(fn);
    jLoadingSet.remove(fn);
    return jstr;
  }

  Future<bool> loadJFile() async {
    if (jFiles.isEmpty) {
      if (jLoadingSet.isNotEmpty) {
        while (jLoadingSet.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      return true;
    }
    List<String> jf = jFiles;
    jFiles = [];
    for (String jFile in jf) {
      if (!jLoadedFiles.contains(jFile)) {
        String jsonStr = await getFileString(jFile);
        if (jsonStr.isNotEmpty) {
          Map<String, dynamic> nmap = json.decode(jsonStr);
          nmap = splitLines(nmap);
          map["patterns"]["facts"].addAll(nmap);
          jLoadedFiles.add(jFile);
        }
      }
    }
    return true;
  }

  init(BuildContext context) {
    dbAgent = DataBaseAgent(
        version: dbVersion, dbName: dbName, dbtable: dbTable, dbindex: dbindex);
    if (isLocal) {
      DateTime now = DateTime.now();
      final DateTime utcNow = now.toUtc();
      final int timestamp = utcNow.millisecondsSinceEpoch ~/ 1000;
      modelTimestamp = {
        mainModelName: timestamp,
        "assets/models/geo1.json": timestamp,
        "assets/models/geo3.json": timestamp
      };
    }
    stateData.addAll({"cache": {}, "logical": {}, "user": {}});
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    double sr = screenWidth / screenHeight;
    scaleHeight = 683.42857;
    scaleWidth = 411.42857;
    double scr = scaleWidth / scaleHeight;
    double r = ((sr - scr) / scr).abs();
    if ((sr < scr) && (scaleHeight < screenHeight)) {
      sizeScale = screenWidth / scaleWidth;
      scaleHeight = screenHeight;
      scaleWidth = screenWidth;
    } else if (r <= 0.1) {
      sizeScale = screenHeight / scaleHeight;
      scaleHeight = screenHeight;
      scaleWidth = screenHeight * scr;
    } else {
      if (screenWidth >= scaleWidth) {
        if (screenHeight > scaleHeight) {
          sizeScale = screenHeight / scaleHeight;
          scaleWidth = screenHeight * scr;
          scaleHeight = screenHeight;
        } else {
          double sh = scaleHeight * 2.0 / 3.0;
          if (screenHeight >= sh) {
            sizeScale = 1.0;
          } else {
            sizeScale = screenHeight / scaleHeight;
            scaleHeight = screenHeight * 3.0 / 2.0;
            scaleWidth = scaleHeight * scr;
          }
        }
      } else {
        sizeScale = screenWidth / scaleWidth;
        scaleWidth = screenWidth;
        scaleHeight = scaleWidth / scr;
      }
    }
    fontScale = sizeScale;
    appBarHeight = scaleHeight * 0.9 / 10.6;
    debugPrint("Screen width: $screenWidth");
    debugPrint("Screen height: $screenHeight");
    debugPrint("Scale width: $scaleWidth");
    debugPrint("Scale height: $scaleHeight");

    size5 = 5.0 * sizeScale;
    size10 = 10.0 * sizeScale;
    size20 = 20.0 * sizeScale;
  }
}
