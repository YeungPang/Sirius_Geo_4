import 'package:flutter/material.dart';
import './form_pattern.dart';
import './pattern.dart';
import './std_pattern.dart';
import './special_pattern.dart';
import './tap_list_item.dart';
import './webview_pattern.dart';
import '../resources/app_model.dart';
import '../resources/basic_resources.dart';
import '../resources/fonts.dart';
import '../resources/s_g_icons.dart';
import './item_search.dart';
import 'package:json_theme/json_theme.dart';

BoxDecoration? getDecoration(String image) {
  return ThemeDecoder.decodeBoxDecoration({
    "image": {
      "image": {"assetName": image, "type": "asset"},
      "fit": "cover"
    }
  }, validate: false);
}

ProcessPattern getColumnPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_children",
    "_crossAxisAlignment",
    "_mainAxisAlignment",
    "_mainAxisSize",
    "_textBaseline",
    "_textDirection",
    "_verticalDirection"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ColumnPattern(map);
}

ProcessPattern getRowPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_children",
    "_crossAxisAlignment",
    "_mainAxisAlignment",
    "_mainAxisSize",
    "_textBaseline",
    "_textDirection",
    "_verticalDirection"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return RowPattern(map);
}

ProcessPattern getWrapPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_children",
    "_crossAxisAlignment",
    "_direction",
    "_runAlignment",
    "_alignment",
    "_runSpacing",
    "_spacing",
    "_textDirection",
    "_verticalDirection",
    "_clipBehavior"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return WrapPattern(map);
}

ProcessPattern getScaffolPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_key",
    "_body",
    "_appBar",
    "_bottomSheet",
    "_bottomNavigationBar",
    "_drawer",
    "_textDirection",
    "_endDrawer",
    "_backgroundColor",
    "_drawerDragStartBehavior",
    "_endDrawerEnableOpenDragGesture",
    "_primary",
    "_extendBody",
    "_extendBodyBehindAppBar",
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ScaffolPattern(map);
}

ProcessPattern getAppBarPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_actions",
    "_actionsIconTheme",
    "_backgroundColor",
    "_bottom",
    "_bottomOpacity",
    "_centerTitle",
    "_elevation",
    "_excludeHeaderSemantics",
    "_flexibleSpace",
    "_leading",
    "_leadingWidth",
    "_primary",
    "_shadowColor",
    "_shape",
    "_title",
    "_titleSpacing",
    "_titleTextStyle",
    "_textStyle",
    "_toolbarHeight",
    "_toolbarOpacity"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return AppBarPattern(map);
}

ProcessPattern getTextPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_text",
    "_locale",
    "_maxLines",
    "_textOverflow",
    "_semanticsLabel",
    "_softWrap",
    "_strutStyle",
    "_textStyle",
    "_textAlign",
    "_textDirection",
    "_textHeightBehavior",
    "_textScaleFactor",
    "_textWidthBasis"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return TextPattern(map);
}

ProcessPattern getDividerPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_color",
    "_endIndent",
    "_indent",
    "_height",
    "_thickness",
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return DividerPattern(map);
}

ProcessPattern getImageAssetPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_name",
    "_actionsIconTheme",
    "_scale",
    "_width",
    "_height",
    "_color",
    "_colorBlendMode",
    "_boxFit",
    "_alignment",
    "_repeat",
    "_centerSlice",
    "_matchTextDirection",
    "_filterQuality"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ImageAssetPattern(map);
}

ProcessPattern getSVGAssetPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = ["_name", "_height"];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return SVGAssetPattern(map);
}

ProcessPattern getStackPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_children",
    "_alignment",
    "_clipBehavior",
    "_stackFit",
    "_textDirection"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return StackPattern(map);
}

ProcessPattern getContainerPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_child",
    "_color",
    "_alignment",
    "_clipBehavior",
    "_boxConstraints",
    "_decoration",
    "_margin",
    "_padding",
    "_transform",
    "_width",
    "_height"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ContainerPattern(map);
}

ProcessPattern getSingleChildScrollViewPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_child",
    "_controller",
    "_dragStartBehavior",
    "_clipBehavior",
    "_scrollPhysics",
    "_primary",
    "_restorationId",
    "_padding",
    "_reverse",
    "_scrollDirection"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return SingleChildScrollViewPattern(map);
}

ProcessPattern getGridViewPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_scrollDirection",
    "_reverse",
    "_controller",
    "_primary",
    "_physics",
    "_shrinkWrap",
    "_padding",
    "_crossAxisCount",
    "_mainAxisSpacing",
    "_crossAxisSpacing",
    "_childAspectRatio",
    "_addAutomaticKeepAlives",
    "_addRepaintBoundaries",
    "_cacheExtent",
    "_children",
    "_semanticChildCount",
    "_dragStartBehavior",
    "_keyboardDismissBehavior",
    "_restorationId",
    "_clipBehavior"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return GridViewPattern(map);
}

ProcessPattern getIndexedStackPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_children",
    "_notifier",
    "_alignment",
    "_clipBehavior",
    "_sizing",
    "_textDirection"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return IndexedStackPattern(map);
}

ProcessPattern getValueStackPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_notifier",
    "_alignment",
    "_clipBehavior",
    "_stackFit",
    "_textDirection"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ValueStackPattern(map);
}

ProcessPattern getCenterPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = ["_child", "_heightFactor", "_widthFactor"];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return CenterPattern(map);
}

ProcessPattern getTextFieldPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_autocorrect",
    "_autofocus",
    "_textController",
    "_enabled",
    "_textStyle",
    "_showCursor",
    "_maxLines",
    "_expands",
    "_onSubmitted",
    "_keyboardType",
    "_inputBorder",
    "_icon",
    "_hintText",
    "_hintStyle",
    "_labelText",
    "_labelStyle",
    "_prefixIcon",
    "_suffixIcon",
    "_filled",
    "_fillColor",
    "_padding"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return TextFieldPattern(map);
}

ProcessPattern getListViewPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_scrollDirection",
    "_reverse",
    "_controller",
    "_primary",
    "_physics",
    "_shrinkWrap",
    "_padding",
    "_addAutomaticKeepAlives",
    "_addRepaintBoundaries",
    "_cacheExtent",
    "_children",
    "_semanticChildCount",
    "_dragStartBehavior",
    "_keyboardDismissBehavior",
    "_restorationId",
    "_clipBehavior"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ListViewPattern(map);
}

ProcessPattern getSizedBoxPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = ["_child", "_width", "_height"];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return SizedBoxPattern(map);
}

ProcessPattern getBubblePattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_bubbleBox",
    "_align",
    "_bubbleHeight",
    "_boxWidth",
    "_boxAlign",
    "_boxHeight",
    "_arrowAlign",
    "_bubbleArrow",
    "_mainAxisAlignment"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return BubblePattern(map);
}

ProcessPattern getDraggablePattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = ["_child", "_feedback", "_childWhenDragging", "_data"];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return DraggablePattern(map);
}

ProcessPattern getDragTargetPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = ["_target", "_dropAction", "_key"];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return DragTargetPattern(map);
}

ProcessPattern getImageBannerPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_name": pmap["_name"],
    "_height": pmap["_height"]
  };
  return ImageBannerPattern(map);
}

ProcessPattern getInTextFieldPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_autocorrect",
    "_autofocus",
    "_textEditingController",
    "_enabled",
    "_textStyle",
    "_showCursor",
    "_maxLines",
    "_expands",
    "_onSubmitted",
    "_keyboardType",
    "_inputBorder",
    "_icon",
    "_hintText",
    "_hintStyle",
    "_labelText",
    "_labelStyle",
    "_prefixIcon",
    "_suffixIcon",
    "_filled",
    "_fillColor",
    "_padding",
    "_key",
    "_complete",
    "_clear",
    "_incomplete",
    "_retainFocus",
    "_textNoti"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  map["_parent"] = pmap;
  return InTextFieldPattern(map);
}

ProcessPattern? getValueTextPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_notifier": pmap["_notifier"],
    "_converter": pmap["_converter"]
  };
  ValueNotifier? notifier = map["_notifier"];
  if (notifier == null) {
    return null;
  }
  var value = notifier.value;
  if (value is String) {
    return ValueTextPattern<String>(map);
  } else if (value is Map<String, dynamic>) {
    return ValueTextPattern<Map<String, dynamic>>(map);
  } else if (value is int) {
    return ValueTextPattern<int>(map);
  } else if (value is Pattern) {
    return ValueTextPattern<Pattern>(map);
  } else if (value is List<Pattern>) {
    return ValueTextPattern<List<Pattern>>(map);
  } else if (value is double) {
    return ValueTextPattern<double>(map);
  } else if (value is bool) {
    return ValueTextPattern<bool>(map);
  } else if (value is List<int>) {
    return ValueTextPattern<List<int>>(map);
  }
  return null;
}

ProcessPattern getValueChildContainerPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_childNoti",
    "_color",
    "_alignment",
    "_clipBehavior",
    "_boxConstraints",
    "_decoration",
    "_margin",
    "_padding",
    "_transform",
    "_width",
    "_height"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ValueChildContainerPattern(map);
}

ProcessPattern getTapItemPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_child": pmap["_child"],
    "_onTap": pmap["_onTap"],
    "_tapAction": pmap["_tapAction"]
  };
  return TapItemPattern(map);
}

ProcessPattern getBadgePattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = ["_child", "_badgeContext", "_badgeColor", "_showBadge"];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return BadgePattern(map);
}

ProcessPattern getAlignPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = ["_child", "_alignment", "_heightFactor", "_widthFactor"];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return AlignPattern(map);
}

ProcessPattern getClipRRectPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_child": pmap["_child"],
    "_borderRadius": pmap["_borderRadius"]
  };
  return ClipRRectPattern(map);
}

ProcessPattern getCardPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_child",
    "_cardColor",
    "_shadowColor",
    "_clipBehavior",
    "_elevation",
    "_shape",
    "_margin",
    "_borderOnForeground",
    "_cardRadius"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return CardPattern(map);
}

ProcessPattern getPaddingPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_child": pmap["_child"],
    "_padding": pmap["_padding"]
  };
  return PaddingPattern(map);
}

ProcessPattern getExpandedPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {"_child": pmap["_child"], "_flex": pmap["_flex"]};
  return ExpandedPattern(map);
}

ProcessPattern getFittedBoxPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = ["_child", "_fit", "_alignment", "_clip"];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return FittedBoxPattern(map);
}

ProcessPattern getSizedBoxExpandPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {"_child": pmap["_child"]};
  return SizedBoxExpandPattern(map);
}

ProcessPattern getValueOpacityPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_child": pmap["_child"],
    "_notifier": pmap["_notifier"]
  };
  return ValueOpacityPattern(map);
}

ProcessPattern getScrollLayoutPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {"_child": pmap["_child"]};
  return ScrollLayoutPattern(map);
}

ProcessPattern getDottedBorderPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_child",
    "_radius",
    "_dashPattern",
    "_strokeWidth",
    "_dottedColor"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return DottedBorderPattern(map);
}

// ProcessPattern getContextPattern(Map<String, dynamic> pmap) {
//   Map<String, dynamic> map = {
//     "_child": pmap["_child"],
//     "_context": pmap["_context"]
//   };
//   map["_parent"] = pmap;
//   return ContextPattern(map);
// }

ProcessPattern getInteractiveViewerPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_child",
    "_scaleEnabled",
    "_panEnabled",
    "_minScale",
    "_maxScale"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return InteractiveViewerPattern(map);
}

ProcessPattern getWillPopScopeActionsPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_child": pmap["_child"],
    "_backActions": pmap["_backActions"]
  };
  return WillPopScopeActionsPattern(map);
}

ProcessPattern getColorButtonPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_child",
    "_btnBRadius",
    "_beginColor",
    "_endColor",
    "_color",
    "_borderColor",
    "_borderWidth",
    "_noShadow",
    "_cbAlignment",
    "_height",
    "_width",
    "_gradient",
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ColorButtonPattern(map);
}

ProcessPattern? getValueTypeListenerPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_notifier": pmap["_notifier"],
    "_notifierKey": pmap["_notifierKey"],
    "_child": pmap["_child"]
  };
  ValueNotifier? notifier = map["_notifier"];
  if (notifier == null) {
    return null;
  }
  var value = notifier.value;
  if (value is String) {
    return ValueTypeListenerPattern<String>(map);
  } else if (value is Map<String, dynamic>) {
    return ValueTypeListenerPattern<Map<String, dynamic>>(map);
  } else if (value is int) {
    return ValueTypeListenerPattern<int>(map);
  } else if (value is ProcessPattern) {
    return ValueTypeListenerPattern<ProcessPattern>(map);
  } else if (value is List<dynamic>) {
    return ValueTypeListenerPattern<List<dynamic>>(map);
  } else if (value is Widget) {
    return ValueTypeListenerPattern<Widget>(map);
  } else if (value is List<Widget>) {
    return ValueTypeListenerPattern<List<Widget>>(map);
  } else if (value is double) {
    return ValueTypeListenerPattern<double>(map);
  } else if (value is bool) {
    return ValueTypeListenerPattern<bool>(map);
  } else if (value is List<int>) {
    return ValueTypeListenerPattern<List<int>>(map);
  }
  return null;
}

/* ProcessPattern getSvgPaintPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_svgPaintNoti",
    "_shapes",
    "_confirmNoti",
    "_selPaint",
    "_ansPaint",
    "_showSelLabel",
    "_ansIndex",
    "_offsetWidth",
    "_offsetHeight",
    "_boxWidth",
    "_boxHeight",
    "_background",
    "_selIndex",
    "_selLabel"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  map["_parent"] = pmap;
  return SvgPaintPattern(map);
} */

ProcessPattern getTapListItemPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_child",
    "_direction",
    "_reverse",
    "_controller",
    "_physics",
    "_shrinkWrap",
    "_padding",
    "_crossAxisCount",
    "_mainAxisSpacing",
    "_crossAxisSpacing",
    "_childAspectRatio",
    "_onTap",
    "_childPattern",
    "_childMap",
    "_itemRef"
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return TapListItemPattern(map);
}

ProcessPattern getIconPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_icon": pmap["_icon"],
    "_iconSize": pmap["_iconSize"],
    "_iconColor": pmap["_iconColor"]
  };
  return IconPattern(map);
}

ProcessPattern getIconButtonPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_icon",
    "_iconSize",
    "_iconColor",
    "_onTap",
    "_tapAction",
    "_key",
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return IconButtonPattern(map);
}

ProcessPattern getFlexiblePattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {"_fit": pmap["_fit"], "_flex": pmap["_flex"]};
  return FlexiblePattern(map);
}

ProcessPattern getOpacityPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_child": pmap["_child"],
    "_opacity": pmap["_opacity"]
  };
  return OpacityPattern(map);
}

ProcessPattern getWebViewPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_url": pmap["_url"],
    "_scriptMode": pmap["_scriptMode"],
    "_mv": pmap["_mv"],
  };
  return WebViewPattern(map);
}

ProcessPattern getSearchButtonPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_itemList": pmap["_itemList"],
    "_clear": pmap["_clear"],
    "_searchIcon": pmap["_searchIcon"],
    "_searchDelegate": pmap["_searchDelegate"],
    "_highlightColor": pmap["_highlightColor"],
    "_textStyle": pmap["_textStyle"],
  };
  return SearchButtonPattern(map);
}

ProcessPattern getIconTextPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_textStyle",
    "_text",
    "_icon",
    "_iconSize",
    "_iconColor",
    "_highlightColor",
    "_mainAxisAlignment",
    "_gap",
    "_horiz",
    "_hoverColor",
    "_onTap",
    "_key",
    "_tapAction",
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  if (pmap["_bar"] != null) {
    map["_iconSize"] = 20.0 * sizeScale;
    if (map["_iconColor"] == null) {
      map["_iconColor"] = const Color(0xFF00344F);
    }
    if (map["_textStyle"] == null) {
      map["_textStyle"] = iconSmallTextStyle;
    }
  }
  return IconTextPattern(map);
}

ProcessPattern getVisiblePattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_child": pmap["_child"],
    "_visible": pmap["_visible"]
  };
  return VisiblePattern(map);
}

ProcessPattern getObxPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_child": pmap["_child"],
    "_valueName": pmap["_valueName"],
    "_valueKey": pmap["_valueKey"],
  };
  return ObxPattern(map);
}

ProcessPattern getRichTextPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_textSpan": pmap["_textSpan"],
    "_textAlign": pmap["_textAlign"],
  };
  return RichTextPattern(map);
}

ProcessPattern getOverflowBoxPatternn(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_child": pmap["_child"],
    "_alignment": pmap["_alignment"],
    "_height": pmap["_height"],
    "_width": pmap["_width"],
  };
  return OverflowBoxPattern(map);
}

ProcessPattern getObxProcessPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_processName": pmap["_processName"],
  };
  return ObxProcessPattern(map);
}

ProcessPattern getPositionedPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_child",
    "_top",
    "_bottom",
    "_left",
    "_right",
    "_height",
    "_width",
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return PositionedPattern(map);
}

ProcessPattern getListTilePattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_key",
    "_leading",
    "_title",
    "_subtitle",
    "_trailing",
    "_isThreeLine",
    "_selected",
    "_selectedColor",
    "_selectedTileColor",
    "_iconColor",
    "_textColor",
    "_tileColor",
    "_contentPadding",
    "_enabled",
    "_focusColor",
    "_hoverColor",
    "_autofocus",
    "_onLongPress",
    "_onTap",
    "_tapAction",
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return ListTilePattern(map);
}

ProcessPattern getDropdownButtonPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {};
  List<String> nl = [
    "_type",
    "_value",
    "_items",
    "_cacheName",
    "_rxName",
    "_fsmName",
    "_hint",
    "_textStyle",
    "_icon",
    "_iconSize",
    "_inMap",
  ];
  for (String s in nl) {
    dynamic d = pmap[s];
    if (d != null) {
      map[s] = d;
    }
  }
  return DropdownButtonPattern(map);
}

ProcessPattern getProgressTextPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_text": pmap["_text"],
    "_textStyle": pmap["_textStyle"],
  };
  return ProgressTextPattern(map);
}

ProcessPattern getFormPattern(Map<String, dynamic> pmap) {
  Map<String, dynamic> map = {
    "_formFields": pmap["_formFields"],
    "_formData": pmap["_formData"],
  };
  return FormPattern(map);
}

const Map<String, Function> getPrimePattern = {
  "Align": getAlignPattern,
  "AppBar": getAppBarPattern,
  "Badge": getBadgePattern,
  "Bubble": getBubblePattern,
  "Card": getCardPattern,
  "Center": getCenterPattern,
  "ClipRRect": getClipRRectPattern,
  "ColorButton": getColorButtonPattern,
  "Column": getColumnPattern,
  "Container": getContainerPattern,
  "Divider": getDividerPattern,
  "DottedBorder": getDottedBorderPattern,
  "Draggable": getDraggablePattern,
  "DragTarget": getDragTargetPattern,
  "DropdownButton": getDropdownButtonPattern,
  "Form": getFormPattern,
  "ProgressText": getProgressTextPattern,
  "Expanded": getExpandedPattern,
  "FittedBox": getFittedBoxPattern,
  "Flexible": getFlexiblePattern,
  "GridView": getGridViewPattern,
  "Icon": getIconPattern,
  "IconButton": getIconButtonPattern,
  "IconText": getIconTextPattern,
  "ImageAsset": getImageAssetPattern,
  "ImageBanner": getImageBannerPattern,
  "IndexedStack": getIndexedStackPattern,
  "InteractiveViewer": getInteractiveViewerPattern,
  "InTextField": getInTextFieldPattern,
  "ListTile": getListTilePattern,
  "ListView": getListViewPattern,
  "Obx": getObxPattern,
  "ObxProcess": getObxProcessPattern,
  "Opacity": getOpacityPattern,
  "OverflowBox": getOverflowBoxPatternn,
  "Padding": getPaddingPattern,
  "Positioned": getPositionedPattern,
  "RichText": getRichTextPattern,
  "Row": getRowPattern,
  "Scaffold": getScaffolPattern,
  "ScrollLayout": getScrollLayoutPattern,
  "SearchButton": getSearchButtonPattern,
  "SingleChildScrollView": getSingleChildScrollViewPattern,
  "SizedBox": getSizedBoxPattern,
  "SizedBoxExpand": getSizedBoxExpandPattern,
  "Stack": getStackPattern,
  "SVGAsset": getSVGAssetPattern,
  "SvgPaint": getSvgPaintPattern,
  "TapItem": getTapItemPattern,
  "TapListItem": getTapListItemPattern,
  "Text": getTextPattern,
  "TextField": getTextFieldPattern,
  "ValueChildContainer": getValueChildContainerPattern,
  //"ValueStack": getValueStackPattern,
  //"ValueOpacity": getValueOpacityPattern,
  "ValueText": getValueTextPattern,
  "ValueTypeListener": getValueTypeListenerPattern,
  "Visible": getVisiblePattern,
  "WebView": getWebViewPattern,
  //"WillPopScopeActions": getWillPopScopeActionsPattern,
  "Wrap": getWrapPattern,
};
