import 'package:flutter/material.dart';
import '../resources/basic_resources.dart';
import './get_pattern.dart';
import './pattern.dart';
import '../model/locator.dart';

class TapListItem extends StatelessWidget {
  final Map<String, dynamic> map;

  const TapListItem(this.map, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    debugPrint("Buidling list view");
    List<dynamic> itemRef = map["_itemRef"] as List<dynamic>;
    if (map["_crossAxisCount"] == null) {
      return ListView.builder(
        scrollDirection: map["_direction"] ?? Axis.vertical,
        padding: map["_padding"],
        shrinkWrap: map["_shrinkWrap"] ?? true,
        physics: (map["_noPhysics"] == true) ? null : bouncingScrollPhysics,
        itemCount: itemRef.length,
        itemBuilder: (context, index) => _itemBuilder(itemRef[index], index),
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
      itemBuilder: (context, index) => _itemBuilder(itemRef[index], index),
    );
  }

  Widget _itemBuilder(dynamic item, int index) {
    Map<String, dynamic> lmap = {
      "_item": item,
      "_index": index,
    };
    Function pf = model.appActions.getPattern(map["_childPattern"])!;
    Map<String, dynamic>? cmap = map["_childMap"];
    if (cmap != null) {
      lmap.addAll(cmap);
    }
    dynamic tevent = map["_onTap"];
    if (tevent != null) {
      lmap["_onTap"] = tevent;
    }
    dynamic p = pf(lmap);
    if (p is ProcessPattern) {
      return returnWidget(p, lmap);
    }
    return FutureBuilder<dynamic>(
        future: repeatGet(pf, lmap),
        builder: (context, snapshot) {
          if (snapshot.hasError) debugPrint(snapshot.error.toString());

          return snapshot.hasData
              ? returnWidget(snapshot.data!, lmap)
              : const Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Future<dynamic> repeatGet(Function pf, Map<String, dynamic> lmap) async {
    if (model.jFiles.isNotEmpty) {
      await model.loadJFile();
    }
    return pf(lmap);
  }

  Widget returnWidget(ProcessPattern p, Map<String, dynamic> lmap) {
    if (lmap["_onTap"] == null) {
      return p.getWidget();
    }
    lmap["_child"] = p;

    return getTapItemPattern(lmap).getWidget();
  }
}

class TapListItemPattern extends ProcessPattern {
  TapListItemPattern(super.map);
  @override
  Widget getWidget({String? name}) {
    map["_widget"] ??= TapListItem(map);
    return map["_widget"];
  }
}
