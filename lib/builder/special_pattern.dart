import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/builder/std_pattern.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/resources/basic_resources.dart';
import 'package:dotted_border/dotted_border.dart';

class NaviScope extends StatelessWidget {
  final Map<String, dynamic> map;

  const NaviScope(this.map, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget w = getPatternWidget(map["_child"]);
    return WillPopScope(
        onWillPop: () async {
/*           if (controller.model.fsm["gameOver"]) {
            Navigator.of(context).pop(true);
            return true;
          } */
          final value = await showDialog<bool>(
              context: context, builder: (context) => _build(context));
          return value == true;
        },
        child: w);
  }

  Widget _build(BuildContext context) {
    ProcessPattern dialogPat = map["_dialog"];
    Widget dialog = (dialogPat != null) ? getPatternWidget(dialogPat) : null;
    return dialog ??
        AlertDialog(
          content: Text(map["_textExit"]),
          actions: <Widget>[
            TextButton(
              child: Text(map["_textNo"]),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(map["_textYesExit"]),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
  }
}

class NaviScopePattern extends ProcessPattern {
  NaviScopePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    return NaviScope(map);
  }
}

class Bubble extends StatelessWidget {
  final Map<String, dynamic> map;

  const Bubble(this.map, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    model.context = context;
    dynamic ml = map["_bubbleBox"];
    List<Widget> lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    Widget w = getPatternWidget(map["_bubbleArrow"]);
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
                        decoration: shadowRCDecoration),
                  ),
                  Align(alignment: map["_arrowAlign"], child: w),
                  Align(
                      alignment: map["_boxAlign"],
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: map["_boxHeight"],
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.end,
                              children: lw,
                            ),
                          )))
                ]))));
  }
}

class BubblePattern extends ProcessPattern {
  BubblePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    if (map["_widget"] == null) {
      map["_widget"] = Bubble(map);
    }
    return map["_widget"];
  }
}

class DraggablePattern extends ProcessPattern {
  DraggablePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget c = getPatternWidget(map["_child"]);
    Widget f = getPatternWidget(map["_feedback"]);
    Widget d = getPatternWidget(map["_childWhenDragging"]);
    return Draggable(
        data: map["_data"],
        onDragStarted: () {
          ProcessEvent action = map["_dragStarted"];
          if (action != null) {
            model.appActions.doFunction(action.name, action.map, action.map);
          }
        },
        child: c,
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
  Widget getWidget({String name}) {
    Widget c = getPatternWidget(map["_target"]);
    return DragTarget(
      onWillAccept: (data) {
        return true;
      },
      onAccept: (data) {
        ProcessEvent dropAction = map["_dropAction"];
        if (dropAction != null) {
          String key = map["_key"];
          if (key != null) {
            map[key] = data;
          }
          Map<String, dynamic> dmap = {};
          dmap.addAll(data);
          if (dropAction.map != null) {
            dmap.addAll(dropAction.map);
          }
          model.appActions.doFunction(dropAction.name, dmap, dropAction.map);
        }
      },
      builder: (context, incoming, rejected) {
        return c;
      },
    );
  }
}

class ImageBanner extends StatelessWidget {
  final String name;
  final double height;

  const ImageBanner({@required this.name, this.height = 200.0, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(height: height),
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
  Widget getWidget({String name}) {
    map["_widget"] ??=
        ImageBanner(name: map["_name"] as String, height: map["_height"]);
  }
}

class InTextField extends StatelessWidget {
  final Map<String, dynamic> map;

  InTextField(this.map, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController tc = map["_textEditingController"];
    // Map<String, dynamic> pMap;
    // pMap = map["_parent"];
    // if (pMap != null) {
    //   pMap["_textEditingController"] = tc;
    // }
    Widget p = getPatternWidget(map["_prefixIcon"]);
    Widget s = getPatternWidget(map["_suffixIcon"]);
    Widget ic = getPatternWidget(map["icon"]);
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
      ProcessEvent actions = map["_complete"];
      if (actions != null) {
        model.appActions.doFunction(actions.name, actions.map, actions.map);
      }
      bool clear = map["_clear"] ?? false;
      if (clear) {
        tc.clear();
      }
    } else {
      ProcessEvent actions = map["_incomplete"];
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
  Widget getWidget({String name}) {
    return InTextField(map);
  }
}

class ValueText<T> extends StatelessWidget {
  final Map<String, dynamic> map;

  const ValueText(this.map, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: map["_notifier"],
      builder: (BuildContext context, T value, Widget child) =>
          _getListnerWidget(value),
    );
  }

  Widget _getListnerWidget(T value) {
    Function f = map["_converter"];
    map["_text"] = (f != null) ? f(value, map) : value.toString();
    ProcessPattern p = TextPattern(map);
    map["widget"] = p.getWidget();
    return map["widget"];
  }
}

class ValueTextPattern<T> extends ProcessPattern {
  ValueTextPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    return ValueText<T>(map);
  }
}

class ValueChildContainer extends StatelessWidget {
  final Map<String, dynamic> map;

  const ValueChildContainer(this.map, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProcessPattern>(
      valueListenable: map["_childNoti"],
      builder: (BuildContext context, ProcessPattern value, Widget child) =>
          _getContainer(value),
    );
  }

  Widget _getContainer(ProcessPattern value) {
    Widget w = getPatternWidget(value);
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
  Widget getWidget({String name}) {
    return ValueChildContainer(map);
  }
}

class TapItem extends StatelessWidget {
  final Map<String, dynamic> map;

  TapItem(this.map, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget w = getPatternWidget(map["_child"]);
    return GestureDetector(onTap: () => _onTap(context, map), child: w);
  }

  _onTap(BuildContext context, Map<String, dynamic> itemMap) {
    ProcessEvent actionMap = map["_onTap"];
    if (actionMap != null) {
      model.context = context;
      model.appActions
          .doFunction(actionMap.name, map["_tapAction"], actionMap.map);
      //controller.model.context = null;
    }
  }
}

class TapItemPattern extends ProcessPattern {
  TapItemPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    return TapItem(map);
  }
}

class BadgePattern extends ProcessPattern {
  BadgePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
    Widget bw = getPatternWidget(map["_badgeContext"]);
    return Badge(
      badgeContent: bw,
      badgeColor: map["_badgeColor"],
      showBadge: map["_showBadge"] ?? true,
      padding: const EdgeInsets.all(0.0),
      child: w,
    );
  }
}

class AlignPattern extends ProcessPattern {
  AlignPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
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
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
    return ClipRRect(
      borderRadius: map["_borderRadius"],
      child: w,
    );
  }
}

class CardPattern extends ProcessPattern {
  CardPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
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
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
    return Padding(
      padding: map["_padding"],
      child: w,
    );
  }
}

class ExpandedPattern extends ProcessPattern {
  ExpandedPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
    return Expanded(
      flex: map["_flex"] ?? 1,
      child: w,
    );
  }
}

class FittedBoxPattern extends ProcessPattern {
  FittedBoxPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
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
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
    return SizedBox.expand(
      child: w,
    );
  }
}

class FlexiblePattern extends ProcessPattern {
  FlexiblePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
    return Flexible(
      fit: map["_fit"] ?? FlexFit.loose,
      flex: map["_flex"] ?? 1,
      child: w,
    );
  }
}

class ValueOpacityPattern extends ProcessPattern {
  ValueOpacityPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    return ValueListenableBuilder<double>(
      valueListenable: map["_notifier"],
      builder: (BuildContext context, double value, Widget child) => Opacity(
        child: getPatternWidget(map["_child"]),
        opacity: value,
      ),
    );
  }
}

class ScrollLayoutPattern extends ProcessPattern {
  ScrollLayoutPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
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
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
    double r = map["_radius"];
    return DottedBorder(
      dashPattern: map["_dashPattern"] ?? [4, 2],
      strokeWidth: map["_strokeWidth"] ?? 1,
      radius: (r != null) ? Radius.circular(r) : null,
      borderType: (r != null) ? BorderType.RRect : null,
      color: map["_dottedColor"],
      child: w,
    );
  }
}

// class WrappedContext extends StatelessWidget {
//   final Map<String, dynamic> map;

//   const WrappedContext(this.map, {Key key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     Map<String, dynamic> pmap = map["_parent"];
//     Widget w = getPatternWidget(map["_child"]);
//     pmap["_context"] = context;
//     return w;
//   }
// }

// class ContextPattern extends ProcessPattern {
//   ContextPattern(Map<String, dynamic> map) : super(map);
//   @override
//   Widget getWidget({String name}) {
//     return WrappedContext(map);
//   }
// }

class InteractiveViewerPattern extends ProcessPattern {
  InteractiveViewerPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
    return InteractiveViewer(
      scaleEnabled: map["_scaleEnabled"] ?? true,
      panEnabled: map["_panEnabled"] ?? true,
      constrained: false,
      minScale: map["_minScale"] ?? 0.1,
      maxScale: map["_maxScale"] ?? 4,
      child: w,
    );
  }
}

class WillPopScopeActionsPattern extends ProcessPattern {
  WillPopScopeActionsPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    Widget w = getPatternWidget(map["_child"]);
    return WillPopScope(
      onWillPop: () async {
        ProcessEvent actions = map["_backActions"];
        if (actions != null) {
          model.appActions.getAgent("action").process(actions);
        }
        return true;
      },
      child: w,
    );
  }
}

class ColorButton extends StatelessWidget {
  final Map<String, dynamic> map;

  const ColorButton(this.map, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double borderRadius = map["_btnBRadius"] ?? 10.0;
    Widget w = getPatternWidget(map["_child"]);
    Gradient g = (map["_beginColor"] == null)
        ? null
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [map["_beginColor"], map["_endColor"]]);
    Color c = map["_color"] as Color;
    BoxBorder b = (map["_borderColor"] == null)
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
                color: Colors.grey[400],
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
  Widget getWidget({String name}) {
    return ColorButton(map);
  }
}

class ValueTypeListener<T> extends StatelessWidget {
  final Map<String, dynamic> map;

  const ValueTypeListener(this.map, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: map["_notifier"],
      builder: (BuildContext context, T value, Widget child) =>
          _getListnerWidget(value),
    );
  }

  Widget _getListnerWidget(T value) {
    ProcessPattern child = map["_child"];
    String key = map["_notifierKey"];
    key ??= (value is List<dynamic>) ? "_children" : "_child";
    child.map[key] = value;
    return getPatternWidget(child);
  }
}

class ValueTypeListenerPattern<T> extends ProcessPattern {
  ValueTypeListenerPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    return ValueTypeListener<T>(map);
  }
}
