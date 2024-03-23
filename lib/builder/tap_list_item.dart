import 'package:flutter/material.dart';
import '../resources/basic_resources.dart';
import './get_pattern.dart';
import './pattern.dart';
import '../model/locator.dart';

class TapListItem extends StatelessWidget {
  final Map<String, dynamic> map;

  const TapListItem(this.map, {super.key});
  @override
  Widget build(BuildContext context) {
    debugPrint("Buidling list view");
    List<dynamic> itemRef = map["_itemRef"] as List<dynamic>;
    return FutureBuilder<List<dynamic>>(
      future: _getChildren(itemRef),
      builder: (context, snapshot) {
        if (snapshot.hasError) debugPrint(snapshot.error.toString());
        return snapshot.hasData
            ? _getWidget(context, itemRef, snapshot.data!)
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Future<List<dynamic>> _getChildren(List<dynamic> itemRef) async {
    if (model.jFiles.isNotEmpty) {
      map["_loading"] = true;
      await model.loadJFile();
    }
    List<dynamic> ppList = [];
    int index = 0;
    Function pf = model.appActions.getPattern(map["_childPattern"])!;
    Map<String, dynamic>? cmap = map["_childMap"];
    dynamic tevent = map["_onTap"];
    for (var item in itemRef) {
      Map<String, dynamic> lmap = {
        "_item": item,
        "_index": index,
      };
      if (cmap != null) {
        lmap.addAll(cmap);
      }
      if (tevent != null) {
        lmap["_onTap"] = tevent;
      }
      ProcessPattern p = await pf(lmap);
      ppList.add([p, lmap]);
      index++;
    }
    return ppList;
  }

  Widget _getWidget(
      BuildContext context, List<dynamic> itemRef, List<dynamic> ppList) {
    if (map["_crossAxisCount"] == null) {
      return ListView.builder(
        scrollDirection: map["_direction"] ?? Axis.vertical,
        padding: map["_padding"],
        shrinkWrap: map["_shrinkWrap"] ?? true,
        physics: (map["_noPhysics"] == true) ? null : bouncingScrollPhysics,
        itemCount: itemRef.length,
        itemBuilder: (context, index) => _itemBuilder(ppList[index]),
      );
    }
    SliverGridDelegate gd = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: map["_crossAxisCount"] as int,
      mainAxisSpacing: map["_mainAxisSpacing"] ?? 0.0,
      crossAxisSpacing: map["_crossAxisSpacing"] ?? 0.0,
      childAspectRatio: map["_childAspectRatio"] ?? 1.0,
    );
    return GridView.builder(
      gridDelegate: gd,
      scrollDirection: map["_direction"] ?? Axis.vertical,
      padding: map["_padding"],
      physics: map["_physics"],
      shrinkWrap: true,
      itemCount: itemRef.length,
      itemBuilder: (context, index) => _itemBuilder(ppList[index]),
    );
  }

  Widget _itemBuilder(List<dynamic> ld) {
    Map<String, dynamic> lmap = ld[1];
    ProcessPattern p = ld[0];
    if (lmap["_onTap"] == null) {
      return p.getWidget();
    }
    lmap["_child"] = p;
    return getTapItemPattern(lmap).getWidget();
  }

/*   Future<dynamic> repeatGet(Function pf, Map<String, dynamic> lmap) async {
    if (model.jFiles.isNotEmpty) {
      map["_loading"] = true;
      await model.loadJFile();
    } else if (model.jLoadingSet.isNotEmpty) {
      while (model.jLoadingSet.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      map["_loading"] = false;
    }
    return pf(lmap);
  }

  Widget returnWidget(ProcessPattern p, Map<String, dynamic> lmap) {
    if (lmap["_onTap"] == null) {
      return p.getWidget();
    }
    lmap["_child"] = p;

    return getTapItemPattern(lmap).getWidget();
  } */
}

class TapListItemPattern extends ProcessPattern {
  TapListItemPattern(super.map);
  @override
  Widget getWidget({String? name}) {
    map["_widget"] ??= TapListItem(map);
    return map["_widget"];
  }
}
