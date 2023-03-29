import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirius_geo_4/util/util.dart';
import './pattern.dart';
import '../model/locator.dart';
import '../resources/basic_resources.dart';
import '../resources/fonts.dart';

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
              close(context, str);
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
      child: Column(
        children: children,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
      onTap: () async {
        // GlobalKey key = map["_key"];
        // BuildContext bc = (key == null) ? context : key.currentContext;
        onSearch(map);
      },
      highlightColor: map["_highlightColor"],
    );
  }
}

onSearch(Map<String, dynamic> map) async {
  SearchDelegate<String>? sd = map["_searchDelegate"];
  Future<String?> f = showSearch<String>(
      context: Get.context!, delegate: sd ?? ItemSearch(map));
  f.then((r) => handleResult(Get.context!, r!));
}

void handleResult(BuildContext context, String r) {
  List<String> sl = r.split(";");
  Map<String, dynamic> _map = {
    "_processEvent": ProcessEvent("processSearch", map: {"_res": sl})
  };
  processValue(_map, null);
}

class SearchButtonPattern extends ProcessPattern {
  SearchButtonPattern(Map<String, dynamic> map) : super(map);

  @override
  Widget getWidget({String? name}) {
    return SearchButton(map);
  }
}
