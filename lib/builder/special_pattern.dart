import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:get/get.dart';
import './pattern.dart';
import './std_pattern.dart';
import '../model/locator.dart';
import '../resources/basic_resources.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:screenshot/screenshot.dart';

class Bubble extends StatelessWidget {
  final Map<String, dynamic> map;

  const Bubble(this.map, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    model.context = context;
    dynamic ml = map["_bubbleBox"];
    List<Widget> lw = (ml! is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    Widget? w = getPatternWidget(map["_bubbleArrow"]);
    return Align(
        alignment: map["_align"],
        child: Material(
            type: MaterialType.transparency,
            child: SizedBox(
                height: map["_bubbleHeight"],
                width: map["_boxWidth"],
                child: Stack(children: [
                  Align(
                    alignment: map["_boxAlign"],
                    child: Container(
                        height: map["_boxHeight"],
                        decoration: map["_boxDecoration"] ?? RCDecoration),
                  ),
                  Align(alignment: map["_arrowAlign"], child: w),
                  Align(
                      alignment: map["_boxAlign"],
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(size10),
                          child: SizedBox(
                            height: map["_boxHeight"],
                            child: Column(
                              mainAxisAlignment: map["_mainAxisAlignment"] ??
                                  MainAxisAlignment.start,
                              children: lw,
                            ),
                          )))
                ]))));
  }
}

class BubblePattern extends ProcessPattern {
  BubblePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    if (map["_widget"] == null) {
      map["_widget"] = Bubble(map);
    }
    return map["_widget"];
  }
}

class DraggablePattern extends ProcessPattern {
  DraggablePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? c = getPatternWidget(map["_child"]);
    Widget? f = getPatternWidget(map["_feedback"]);
    Widget? d = getPatternWidget(map["_childWhenDragging"]);
    return Draggable(
        data: map["_data"],
        onDragStarted: () {
          ProcessEvent? action = map["_dragStarted"];
          if (action != null) {
            model.appActions.doFunction(action.name, action.map, action.map);
          }
        },
        child: c!,
        feedback: Opacity(
          child: f ?? c,
          opacity: 0.7,
        ),
        childWhenDragging: d ?? c);
  }
}

class DragTargetPattern extends ProcessPattern {
  DragTargetPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? c = getPatternWidget(map["_target"]);
    return DragTarget(
      onWillAccept: (data) {
        return true;
      },
      onAccept: (data) {
        ProcessEvent? dropAction = map["_dropAction"];
        if (dropAction != null) {
          String? key = map["_key"];
          if (key != null) {
            map[key] = data;
          }
          Map<String, dynamic> dmap = {};
          if ((data != null) && (data is Map<String, dynamic>)) {
            dmap.addAll(data);
          }
          if (dropAction.map != null) {
            dmap.addAll(dropAction.map!);
          }
          model.appActions.doFunction(dropAction.name, dmap, dropAction.map);
        }
      },
      builder: (context, incoming, rejected) {
        return c!;
      },
    );
  }
}

class ImageBanner extends StatelessWidget {
  final String name;
  final double height;

  const ImageBanner(this.name, {this.height = 200.0, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(height: height * sizeScale),
        decoration: const BoxDecoration(color: Colors.grey),
        child: Image.asset(
          name,
          fit: BoxFit.cover,
        ));
  }
}

class ImageBannerPattern extends ProcessPattern {
  ImageBannerPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return (map["_widget"] ??=
        ImageBanner(map["_name"]!, height: map["_height"]));
  }
}

class InTextField extends StatelessWidget {
  final Map<String, dynamic> map;

  const InTextField(this.map, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController tc = map["_textEditingController"];
    // Map<String, dynamic> pMap;
    // pMap = map["_parent"];
    // if (pMap != null) {
    //   pMap["_textEditingController"] = tc;
    // }
    Widget? p = getPatternWidget(map["_prefixIcon"]);
    Widget? s = getPatternWidget(map["_suffixIcon"]);
    Widget? ic = getPatternWidget(map["icon"]);
    return TextField(
      autocorrect: map["_autocorrect"] ?? true,
      autofocus: map["_autofocus"] ?? true,
      controller: tc,
      onEditingComplete: () => _completeEdit(tc, context),
      enabled: map["_enabled"] ?? true,
      style: map["_textStyle"],
      showCursor: map["_showCursor"],
      maxLines: map["_maxLines"] ?? 1,
      expands: map["_expands"] ?? false,
      onSubmitted: map["_onSubmitted"],
      // onTap: () {
      //   FocusScope.of(context).requestFocus(FocusNode());
      // },
      keyboardType: map["_keyboardType"],
      decoration: InputDecoration(
        border: map["_inputBorder"],
        icon: ic,
        hintText: map["_hintText"],
        hintStyle: map["_hintStyle"],
        labelText: map["_labelText"],
        labelStyle: map["_labelStyle"],
        prefixIcon: p,
        suffixIcon: s,
        filled: map["_filled"],
        fillColor: map["_fillColor"],
        contentPadding: map["_padding"],
      ),
    );
  }

  _completeEdit(TextEditingController tc, BuildContext context) {
    String text = tc.text.toString();
    if (text.isNotEmpty) {
      ProcessEvent? actions = map["_complete"];
      if (actions != null) {
        model.appActions.doFunction(actions.name, actions.map, actions.map);
      }
      bool clear = map["_clear"] ?? false;
      if (clear) {
        tc.clear();
      }
    } else {
      ProcessEvent? actions = map["_incomplete"];
      if (actions != null) {
        model.appActions.doFunction(actions.name, actions.map, actions.map);
      }
    }
    bool retainFocus = map["_retainFocus"] ?? false;
    if (retainFocus) {
      FocusScope.of(context).requestFocus();
    } else {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }
}

class InTextFieldPattern extends ProcessPattern {
  InTextFieldPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return InTextField(map);
  }
}

class ValueText<T> extends StatelessWidget {
  final Map<String, dynamic> map;

  const ValueText(this.map, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: map["_notifier"],
      builder: (BuildContext context, T value, Widget? child) =>
          _getListenerWidget(value),
    );
  }

  Widget _getListenerWidget(T value) {
    Function? f = map["_converter"];
    map["_text"] = (f != null) ? f(value, map) : value.toString();
    ProcessPattern p = TextPattern(map);
    map["widget"] = p.getWidget();
    return map["widget"];
  }
}

class ValueTextPattern<T> extends ProcessPattern {
  ValueTextPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return ValueText<T>(map);
  }
}

class ValueChildContainer extends StatelessWidget {
  final Map<String, dynamic> map;

  const ValueChildContainer(this.map, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProcessPattern>(
      valueListenable: map["_childNoti"],
      builder: (BuildContext context, ProcessPattern value, Widget? child) =>
          _getContainer(value),
    );
  }

  Widget _getContainer(ProcessPattern value) {
    Widget? w = getPatternWidget(value);
    return Container(
        child: w,
        color: map["_color"],
        alignment: map["_alignment"],
        clipBehavior: map["_clipBehavior"] ?? Clip.none,
        constraints: map["_boxConstraints"],
        decoration: map["_decoration"],
        foregroundDecoration: map["_foregroundDecoration"],
        width: map["_width"],
        height: map["_height"],
        margin: map["_margin"],
        padding: map["_padding"],
        transform: map["_transform"]);
  }
}

class ValueChildContainerPattern extends ProcessPattern {
  ValueChildContainerPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return ValueChildContainer(map);
  }
}

class TapItem extends StatelessWidget {
  final Map<String, dynamic> map;

  const TapItem(this.map, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget? w = getPatternWidget(map["_child"]);
    return GestureDetector(onTap: () => _onTap(context, map), child: w);
  }
}

tapAction(Map<String, dynamic> map) {
  _onTap(Get.context, map);
}

_onTap(BuildContext? context, Map<String, dynamic> map) {
  dynamic onTap = map["_onTap"];
  String? func;
  dynamic m;
  Map<String, dynamic>? _map;
  if (onTap is Map<String, dynamic>) {
    func = onTap["_func"];
    m = onTap["_tapAction"];
    _map = onTap["_map"];
  } else if (onTap is ProcessEvent) {
    func = onTap.name;
    m = map["_tapAction"];
    _map = onTap.map;
  }
  if (func != null) {
    GlobalKey? key = map["_key"];
    if (m is Map<String, dynamic>) {
      dynamic rxName = m["_rxName"];
      double op = (rxName == null) ? 1.0 : resxController.getRxValue(rxName);
      if (op <= 0.5) {
        return;
      }
    }
    if ((context != null) || (key != null)) {
      model.context = (key == null) ? context : key.currentContext;
    }
    model.appActions.doFunction(func, m, _map);
  }
}

class TapItemPattern extends ProcessPattern {
  TapItemPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return TapItem(map);
  }
}

class BadgePattern extends ProcessPattern {
  BadgePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    Widget? bw = getPatternWidget(map["_badgeContext"]);
    return badges.Badge(
      position: badges.BadgePosition.topEnd(end: 0),
      badgeContent: bw,
      badgeStyle: badges.BadgeStyle(
        badgeColor: map["_badgeColor"] ?? Colors.white,
        padding: const EdgeInsets.all(0.0),
      ),
      showBadge: map["_showBadge"] ?? true,
      child: w,
    );
  }
}

class AlignPattern extends ProcessPattern {
  AlignPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return Align(
      alignment: map["_alignment"] ?? Alignment.center,
      heightFactor: map["_heightFactor"],
      widthFactor: map["_widthFactor"],
      child: w,
    );
  }
}

class ClipRRectPattern extends ProcessPattern {
  ClipRRectPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return ClipRRect(
      borderRadius: map["_borderRadius"],
      child: w,
    );
  }
}

class CardPattern extends ProcessPattern {
  CardPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return Card(
      color: map["_cardColor"],
      shadowColor: map["_shadowColor"],
      elevation: map["_elevation"],
      shape: map["_shape"] ??
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(map["_cardRadius"] ?? 4.0)),
      borderOnForeground: map["_borderOnForeground"] ?? true,
      margin: map["_margin"],
      clipBehavior: map["_clipBehavior"],
      child: w,
    );
  }
}

class PaddingPattern extends ProcessPattern {
  PaddingPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return Padding(
      padding: map["_padding"],
      child: w,
    );
  }
}

class ExpandedPattern extends ProcessPattern {
  ExpandedPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return Expanded(
      flex: map["_flex"] ?? 1,
      child: w!,
    );
  }
}

class FittedBoxPattern extends ProcessPattern {
  FittedBoxPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return FittedBox(
      fit: map["_fit"] ?? BoxFit.contain,
      alignment: map["_alignment"] ?? Alignment.center,
      clipBehavior: map["_clip"] ?? Clip.hardEdge,
      child: w,
    );
  }
}

class SizedBoxExpandPattern extends ProcessPattern {
  SizedBoxExpandPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return SizedBox.expand(
      child: w,
    );
  }
}

class FlexiblePattern extends ProcessPattern {
  FlexiblePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return Flexible(
      fit: map["_fit"] ?? FlexFit.loose,
      flex: map["_flex"] ?? 1,
      child: w!,
    );
  }
}

class ValueOpacityPattern extends ProcessPattern {
  ValueOpacityPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return ValueListenableBuilder<double>(
      valueListenable: map["_notifier"],
      builder: (BuildContext context, double value, Widget? child) => Opacity(
        child: getPatternWidget(map["_child"]),
        opacity: value,
      ),
    );
  }
}

class ObxOpacityPattern extends ProcessPattern {
  ObxOpacityPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    String rxName = map["_rxName"];
    return Obx(() {
      return Opacity(
        child: getPatternWidget(map["_child"]),
        opacity: resxController.getRxValue(rxName),
      );
    });
  }
}

class ScrollLayoutPattern extends ProcessPattern {
  ScrollLayoutPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: w,
          ),
        ),
      );
    });
  }
}

class DottedBorderPattern extends ProcessPattern {
  DottedBorderPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    double? r = map["_radius"];
    return DottedBorder(
      dashPattern: map["_dashPattern"] ?? [4, 2],
      strokeWidth: map["_strokeWidth"] ?? 1,
      radius: (r != null) ? Radius.circular(r) : const Radius.circular(0),
      borderType: (r != null) ? BorderType.RRect : BorderType.Rect,
      color: map["_dottedColor"],
      child: w!,
    );
  }
}

class InteractiveViewerPattern extends ProcessPattern {
  InteractiveViewerPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return InteractiveViewer(
      scaleEnabled: map["_scaleEnabled"] ?? true,
      panEnabled: map["_panEnabled"] ?? true,
      constrained: false,
      minScale: map["_minScale"] ?? 0.1,
      maxScale: map["_maxScale"] ?? 4,
      child: w!,
    );
  }
}

class WillPopScopeActionsPattern extends ProcessPattern {
  WillPopScopeActionsPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return WillPopScope(
      onWillPop: () async {
        ProcessEvent? actions = map["_backActions"];
        if (actions != null) {
          model.appActions.getAgent("action").process(actions);
        }
        return true;
      },
      child: w!,
    );
  }
}

class ColorButton extends StatelessWidget {
  final Map<String, dynamic> map;

  const ColorButton(this.map, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double borderRadius = map["_btnBRadius"] ?? size10;
    Widget? w = getPatternWidget(map["_child"]);
    var grad = map["_gradient"];
    if (grad is String) {
      grad = resources[grad];
    }
    Gradient? g = grad ??
        ((map["_beginColor"] == null)
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [map["_beginColor"], map["_endColor"]]));
    Color? c = map["_color"];
    BoxBorder? b = (map["_borderColor"] == null)
        ? null
        : Border.all(
            color: map["_borderColor"], width: map["_borderWidth"] ?? 1.0);

    BoxDecoration box = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: b,
      color: c,
      gradient: g,
      boxShadow: (map["_noShadow"] != null)
          ? null
          : [
              BoxShadow(
                color: Colors.grey[400]!,
                offset: const Offset(
                  2, // Move to right 10  horizontally
                  2, // Move to bottom 10 Vertically
                ),
              )
            ],
    );
    return Container(
      alignment: map["_cbAlignment"] ?? Alignment.center,
      height: map["_height"],
      width: map["_width"],
      decoration: box,
      child: w,
    );
  }
}

class ColorButtonPattern extends ProcessPattern {
  ColorButtonPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return ColorButton(map);
  }
}

class ValueTypeListener<T> extends StatelessWidget {
  final Map<String, dynamic> map;

  const ValueTypeListener(this.map, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: map["_notifier"],
      builder: (BuildContext context, T value, Widget? child) =>
          _getListenerWidget(value),
    );
  }

  Widget _getListenerWidget(T value) {
    ProcessPattern child = map["_child"];
    String? key = map["_notifierKey"];
    key ??= (value is List<dynamic>) ? "_children" : "_child";
    child.map[key] = value;
    return getPatternWidget(child)!;
  }
}

class ValueTypeListenerPattern<T> extends ProcessPattern {
  ValueTypeListenerPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return ValueTypeListener<T>(map);
  }
}

class IconButtonWidget extends StatelessWidget {
  final Map<String, dynamic> map;

  const IconButtonWidget(this.map, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var icv = map["_icon"];
    Widget? w;
    if (icv is String) {
      Function iepf = model.appActions.getPattern("Icon")!;
      ProcessPattern pp = iepf(map);
      w = pp.getWidget();
    } else {
      w = getPatternWidget(icv);
    }
    Icon ic = w! as Icon;
    return IconButton(
      icon: ic,
      onPressed: () => _onTap(context, map),
    );
  }
}

class IconButtonPattern extends ProcessPattern {
  IconButtonPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return IconButtonWidget(map);
  }
}

class IconTextWidget extends StatelessWidget {
  final Map<String, dynamic> map;

  const IconTextWidget(this.map, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var icv = map["_icon"];
    Widget? w;
    if (icv is String) {
      Function iepf = model.appActions.getPattern("Icon")!;
      ProcessPattern pp = iepf(map);
      w = pp.getWidget();
    } else {
      w = getPatternWidget(icv);
    }

    bool isHoriz = map["_horiz"] ?? false;
    Widget? gap = (map["_gap"] == null) ? null : getPatternWidget(map["_gap"]);
    List<Widget> children = (gap == null)
        ? [
            w!,
            Text(
              map["_text"],
              style: map["_textStyle"],
              textAlign: TextAlign.center,
            )
          ]
        : [
            gap,
            w!,
            gap,
            Text(
              map["_text"],
              style: map["_textStyle"],
              textAlign: TextAlign.center,
            )
          ];
    MainAxisAlignment ma = map["_mainAxisAlignment"] ??
        ((gap == null)
            ? MainAxisAlignment.spaceAround
            : MainAxisAlignment.start);
    return InkWell(
      child: isHoriz
          ? Row(
              children: children,
              mainAxisAlignment: ma,
            )
          : Column(
              children: children,
              mainAxisAlignment: ma,
            ),
      onTap: () => _onTap(context, map),
      highlightColor: map["_highlightColor"],
      hoverColor: map["_hoverColor"],
    );
  }
}

class IconTextPattern extends ProcessPattern {
  IconTextPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return IconTextWidget(map);
  }
}

class VisiblePattern extends ProcessPattern {
  VisiblePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return Visibility(
      child: getPatternWidget(map["_child"])!,
      visible: map["_visible"],
    );
  }
}

class ObxPattern extends ProcessPattern {
  ObxPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    ProcessPattern child = map["_child"];
    return Obx(() {
      String rxName = map["_valueName"];
      dynamic value = resxController.getRxValue(rxName);
      String key = map["_valueKey"] ??
          ((value is List<dynamic>) ? "_children" : "_child");
      child.map[key] = value;
      return getPatternWidget(child)!;
    });
  }
}

class ObxProcessPattern extends ProcessPattern {
  ObxProcessPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return Obx(() {
      String rxName = map["_processName"];
      ProcessEvent event = resxController.getRxValue(rxName);
      Agent a = model.appActions.getAgent("pattern");

      var p = a.process(event);

      if (p is ProcessPattern) {
        return p.getWidget();
      }
      return p as Widget;
    });
  }
}

class DropdownButtonWidget extends StatefulWidget {
  final Map<String, dynamic> map;
  const DropdownButtonWidget(this.map, {Key? key}) : super(key: key);

  @override
  _DropdownButtonWidgetState createState() => _DropdownButtonWidgetState();
}

class _DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  late Map<String, dynamic> map;
  late String type;
  dynamic _value;
  late List<dynamic> _items;
  dynamic _hint;
  dynamic rxName;
  dynamic csName;
  dynamic fsmName;
  dynamic _icon;
  dynamic _iconSize;
  dynamic _style;
  dynamic _inMap;

  @override
  void initState() {
    map = widget.map;
    type = map["_type"] ?? "string";
    _value = map["_value"];
    _items = map["_items"];
    _hint = map["_hint"];
    rxName = map["_rxName"];
    csName = map["_cacheName"];
    fsmName = map["_fsmName"];
    _icon = map["_icon"] ?? const Icon(Icons.arrow_drop_down);
    _iconSize = map["_iconSize"] ?? 24.0;
    _style = map["_textStyle"];
    _inMap = map["_inMap"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (type == "string") {
      return DropdownButton<String>(
        items: _items.map((e) {
          return DropdownMenuItem<String>(value: e, child: Text(e));
        }).toList(),
        value: _value,
        onChanged: (newValue) => _onChange(newValue),
        hint: (_hint != null)
            ? Text(
                _hint,
                style: _style,
              )
            : null,
        style: _style,
        icon: _icon,
        iconSize: _iconSize,
      );
    }
    return DropdownButton<Widget>(
      items: _items.map((e) {
        return DropdownMenuItem<Widget>(
          value: e,
          child: e,
        );
      }).toList(),
      value: _value,
      onChanged: (newValue) => _onChange(newValue),
      hint: (_hint != null)
          ? Text(
              _hint,
              style: _style,
            )
          : null,
      style: _style,
      icon: _icon,
      iconSize: _iconSize,
    );
  }

  _onChange(newValue) {
    setState(() {
      _value = newValue;
    });
    if (csName != null) {
      resxController.setCache(csName, newValue);
    }
    if (rxName != null) {
      resxController.setRxValue(rxName, newValue);
    }
    if (fsmName != null) {
      Map<String, dynamic> m = _inMap ?? {};
      m['_value'] = newValue;
      model.appActions.doFunction("fsmEvent", fsmName, m);
    }
  }
}

class DropdownButtonPattern extends ProcessPattern {
  DropdownButtonPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return DropdownButtonWidget(map);
  }
}

class ProgressText extends StatelessWidget {
  final Map<String, dynamic> map;

  const ProgressText(this.map, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic text = map["_text"];
    Widget pind = const Center(
      child: CircularProgressIndicator(),
    );
    Widget w;
    if (text == null) {
      w = pind;
    } else {
      w = Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          pind,
          Text(
            text,
            style: map["_textStyle"],
          )
        ],
      );
    }
    return w;
  }
}

class ProgressTextPattern extends ProcessPattern {
  ProgressTextPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return ProgressText(map);
  }
}

class ListTileWidget extends StatelessWidget {
  final Map<String, dynamic> map;

  const ListTileWidget(this.map, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? t = getPatternWidget(map["_title"]);
    Widget? l = getPatternWidget(map["_leading"]);
    Widget? s = getPatternWidget(map["_subtitle"]);
    Widget? r = getPatternWidget(map["_trailing"]);
    return ListTile(
      key: map["_key"],
      leading: l,
      title: t,
      subtitle: s,
      trailing: r,
      isThreeLine: map["_isThreeLine"] ?? false,
      shape: map["_shape"],
      selected: map["_selected"] ?? false,
      selectedColor: map["_selectedColor"],
      selectedTileColor: map["_selectedTileColor"],
      iconColor: map["_iconColor"],
      textColor: map["_textColor"],
      tileColor: map["_tileColor"],
      contentPadding: map["_contentPadding"],
      enabled: map["_enabled"] ?? true,
      focusColor: map["_focusColor"],
      hoverColor: map["_hoverColor"],
      autofocus: map["_autofocus"] ?? false,
      onLongPress: map["_onLongPress"],
      onTap: () => _onTap(context, map),
    );
  }
}

class ListTilePattern extends ProcessPattern {
  ListTilePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return ListTileWidget(map);
  }
}

class ScreenShotPattern extends ProcessPattern {
  final ScreenshotController _screenshotController = ScreenshotController();

  ScreenShotPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    resxController.setCache(map["_screenName"]!, _screenshotController);
    Widget? w = getPatternWidget(map["_child"]);
    return Screenshot(child: w!, controller: _screenshotController);
  }
}

class CupertinoSwitchPattern extends ProcessPattern {
  CupertinoSwitchPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    bool s = map["_switch"];
    dynamic tColor = map["_trackColor"];
    if (tColor is String) {
      tColor = colorMap[tColor];
    }
    tColor ??= Colors.grey;
    dynamic aColor = map["_activeColor"];
    if (aColor is String) {
      aColor = colorMap[aColor];
    }
    aColor ??= Colors.blue;
    return CupertinoSwitch(
        trackColor: tColor,
        activeColor: aColor,
        value: s,
        onChanged: (newValue) {
          map["_switch"] = newValue;
          _onTap(null, map);
        });
  }
}
