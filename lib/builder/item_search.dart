import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './pattern.dart';
import '../model/locator.dart';
import '../resources/basic_resources.dart';
import '../resources/fonts.dart';

class ItemSearch extends SearchDelegate<String> {
  final Map<String, dynamic> map;
  List<String>? itemList;
  //List<dynamic>? searchList;
  List<String>? refList;

  ItemSearch(this.map);

  @override
  List<Widget> buildActions(BuildContext context) {
    Widget? iw = getPatternWidget(map["_clear"]);
    if (iw != null) {
      return [iw];
    }
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
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
    itemList ??= map["_itemList"];
    if (itemList == null) {
      itemList = [];
      refList = [];
      var itemStr = model.map["search"];
      String iStr = (itemStr is List<dynamic>) ? itemStr.join() : itemStr;
      List<dynamic> searchList = iStr.split(";");
      for (String element in searchList) {
        if (element.isNotEmpty) {
          List<String> sl = element.toString().split("⇒");
          itemList!.add(sl[0]);
          refList!.add(sl[1]);
        }
      }
      //map["_searchElemList"] = model.map["match"]["element"];
    }
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
              int inx = itemList!.indexOf(query);
              //if (closeIt) {
              close(context, refList![inx]);
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
/*     return IconButton(
        // onPressed: () async {
        //   final String r = await showSearch(
        //       context: context, delegate: sd ?? ItemSearch(map));
        onPressed: () async {
          GlobalKey key = map["_key"];
          BuildContext bc = (key == null) ? context : key.currentContext;
          Future<String> f = showSearch<String>(
              context: context, delegate: sd ?? ItemSearch(map));
          f.then((r) => handleResult(bc, r));
          // String r = "Continents";
          //model.appActions.doFunction("found", r, map["_searchElemList"]);
        },
        icon: ic ?? const Icon(Icons.search));
 */
  }
}

onSearch(Map<String, dynamic> map) async {
  SearchDelegate<String>? sd = map["_searchDelegate"];
  Future<String?> f = showSearch<String>(
      context: Get.context!, delegate: sd ?? ItemSearch(map));
  f.then((r) => handleResult(Get.context!, r!));
  // String r = "Continents";
  //model.appActions.doFunction("found", r, map["_searchElemList"]);
}

void handleResult(BuildContext context, String r) {
  model.context = context;
  List<String> sl = r.split(":");
  Map<String, dynamic> config = model.map["config"];
  Map<String, dynamic> elem = config[sl[0]];
  int? inx = int.tryParse(sl[1]);
  if (inx != null) {
    String iStr = elem["elemList"][inx];
    String iHeader = elem["header"];
    List<dynamic> input = [iHeader, iStr];
    Map<String, dynamic> imap = {};
    model.appActions.doFunction("mapPat", input, imap);

    input = [elem, iStr];
    List<dynamic> itemRef =
        model.appActions.doFunction("dataList", input, null);
    Map<String, dynamic> itemRefMap = config[imap["_ref"]];

    Map<String, dynamic> vars = {
      "_itemRef": itemRef,
      "_itemRefMap": itemRefMap,
      "_title": imap["_name"],
      "_progId": imap["_progId"],
      "_PassScore": imap["_PassScore"]
    };
    model.appActions.doFunction("route", elem["pattern"], vars);
  }
}

class SearchButtonPattern extends ProcessPattern {
  SearchButtonPattern(Map<String, dynamic> map) : super(map);

  @override
  Widget getWidget({String? name}) {
    return SearchButton(map);
  }
}
