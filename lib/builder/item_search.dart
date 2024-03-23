import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../util/util.dart';
import './pattern.dart';
import '../model/locator.dart';
import '../resources/basic_resources.dart';
import '../resources/fonts.dart';

final Map<String, dynamic> fileElem = model.map["fileElem"];

class ItemSearch extends SearchDelegate<String> {
  final Map<String, dynamic> map;
  String label = model.map["text"]["search"];
  List<dynamic>? searchTypes;
  List<String>? itemList;
  //List<dynamic>? searchList;
  List<String>? refList;

  ItemSearch(this.map);

  @override
  String get searchFieldLabel => _getLabel();

  // @override
  // ThemeData appBarTheme(BuildContext context) {
  //   return Theme.of(context);
  // }
  String _getLabel() {
    if ((searchTypes != null) || (map["_searchTypes"] == null)) {
      return label;
    }
    if (searchTypes == null) {
      searchTypes = map["_searchTypes"];
      label = searchTypes![0];
    }
    return label;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    List<Widget>? iw = (map["_actions"] != null)
        ? getPatternWidgetList(map["_actions"])
        : null;
    if (iw != null) {
      return iw;
    }
    return (map["_searchTypes"] == null)
        ? [
            IconButton(
                onPressed: () {
                  query = '';
                },
                icon: const Icon(Icons.clear)),
          ]
        : [
            IconButton(
                onPressed: () {
                  query = '';
                },
                icon: const Icon(Icons.clear)),
            const VerticalDivider(
              color: Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                label = "Pressed 1";
                query = '';
              },
            )
          ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, "");
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context, true);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context, false);
  }

  Widget _buildList(BuildContext context, bool closeIt) {
    Map<String, dynamic> itemMap = model.map["search"];
    itemList = itemMap.keys.toList();
    refList = [];
    //map["_searchElemList"] = model.map["match"]["element"];
    final suggestions = itemList!.where((element) {
      return element.toString().toLowerCase().contains(query.toLowerCase());
    });
    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(suggestions.elementAt(index)),
            onTap: () {
              query = suggestions.elementAt(index);
              String str = itemMap[query];
              //if (closeIt) {
              close(context, str + ";_title:" + query);
              //}
            },
          );
        });
  }
}

class SearchButton extends StatelessWidget {
  final Map<String, dynamic> map;

  const SearchButton(this.map, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Icon ic = map["_searchIcon"] ??
        Icon(
          Icons.search,
          size: 20.0 * sizeScale,
          color: const Color(0xFF00344F),
        );
    String text = model.map["text"]["search"];
    TextStyle textStyle = map["_textStyle"] ?? iconSmallTextStyle;
    List<Widget> children = [ic, Text(text, style: textStyle)];
    return InkWell(
      onTap: () async {
        // GlobalKey key = map["_key"];
        // BuildContext bc = (key == null) ? context : key.currentContext;
        onSearch(map);
      },
      highlightColor: map["_highlightColor"],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
    );
  }
}

onSearch(Map<String, dynamic> map) async {
  dynamic d = model.map["search"];
  if (d == null) {
    String? fn = fileElem["search"];
    if (fn == null) {
      return;
    }
    String jstr = await model.getJson(fn);
    if (jstr.isNotEmpty) {
      Map<String, dynamic> nmap = json.decode(jstr);
      model.map.addAll(nmap);
    } else {
      return;
    }
  }
  SearchDelegate<String>? sd = map["_searchDelegate"];
  Future<String?> f = showSearch<String>(
      context: Get.context!, delegate: sd ?? ItemSearch(map));
  f.then((r) => handleResult(Get.context!, r!));
}

void handleResult(BuildContext context, String? r) async {
  if ((r == null) || (r.isEmpty)) {
    return;
  }
  String? title;
  bool load = false;
  List<dynamic> sl = r.split(";").map((e) {
    List<String> ls = e.split(":");
    String ls0 = ls[0];
    if (ls0 == "_title") {
      title = ls[1];
      return null;
    }
    List<dynamic> ld = [ls0, int.tryParse(ls[1])];
    String? fs = fileElem[ls0];
    if (fs != null) {
      if (!model.jLoadedFiles.contains(fs)) {
        model.addJFile(fs);
        load = true;
      }
    }
    dynamic d = ld;
    return d;
  }).toList();
  if (sl[sl.length - 1] == null) {
    sl.removeLast();
  }
  if (load) {
    await model.loadJFile();
  }
  Map<String, dynamic> map_ = {
    "_processEvent":
        ProcessEvent("processSearch", map: {"_itemList": sl, "_title": title})
  };
  processValue(map_, null);
}

class SearchButtonPattern extends ProcessPattern {
  SearchButtonPattern(Map<String, dynamic> map) : super(map);

  @override
  Widget getWidget({String? name}) {
    return SearchButton(map);
  }
}
