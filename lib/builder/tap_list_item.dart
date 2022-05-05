import 'package:flutter/material.dart';
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
        physics: map["_physics"],
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
    ProcessEvent? tevent = map["_onTap"];
    if (tevent != null) {
      lmap["_onTap"] = tevent;
    }
    ProcessPattern p = pf(lmap);

    if (lmap["_onTap"] == null) {
      return p.getWidget();
    }
    lmap["_child"] = p;

    return getTapItemPattern(lmap).getWidget();
  }
}

class TapListItemPattern extends ProcessPattern {
  TapListItemPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    map["_widget"] ??= TapListItem(map);
    return map["_widget"];
  }
}
