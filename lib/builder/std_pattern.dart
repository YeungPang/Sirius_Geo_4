import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './pattern.dart';

class ColumnPattern extends ProcessPattern {
  ColumnPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    dynamic ml = map["_children"];
    List<Widget>? lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    return Column(
        crossAxisAlignment:
            map["_crossAxisAlignment"] ?? CrossAxisAlignment.center,
        mainAxisAlignment: map["_mainAxisAlignment"] ?? MainAxisAlignment.start,
        mainAxisSize: map["_mainAxisSize"] ?? MainAxisSize.max,
        textBaseline: map["_textBaseline"],
        textDirection: map["_textDirection"],
        verticalDirection: map["_verticalDirection"] ?? VerticalDirection.down,
        children: lw!);
  }
}

class RowPattern extends ProcessPattern {
  RowPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    dynamic ml = map["_children"];
    List<Widget>? lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    return Row(
        key: map["_key"],
        crossAxisAlignment:
            map["_crossAxisAlignment"] ?? CrossAxisAlignment.center,
        mainAxisAlignment: map["_mainAxisAlignment"] ?? MainAxisAlignment.start,
        mainAxisSize: map["_mainAxisSize"] ?? MainAxisSize.max,
        textBaseline: map["_textBaseline"],
        textDirection: map["_textDirection"],
        verticalDirection: map["_verticalDirection"] ?? VerticalDirection.down,
        children: lw!);
  }
}

class WrapPattern extends ProcessPattern {
  WrapPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    dynamic ml = map["_children"];
    List<Widget>? lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    return Wrap(
        key: map["_key"],
        crossAxisAlignment:
            map["_crossAxisAlignment"] ?? WrapCrossAlignment.center,
        direction: map["_direction"] ?? Axis.horizontal,
        alignment: map["_alignment"] ?? WrapAlignment.start,
        runAlignment: map["_runAlignment"] ?? WrapAlignment.start,
        runSpacing: map["_runSpacing"] ?? 0.0,
        spacing: map["_spacing"] ?? 0.0,
        textDirection: map["_textDirection"],
        verticalDirection: map["_verticalDirection"] ?? VerticalDirection.down,
        clipBehavior: map["_clipBehavior"] ?? Clip.none,
        children: lw!);
  }
}

class ScaffolPattern extends ProcessPattern {
  ScaffolPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_body"]);
    Widget? a = getPatternWidget(map["_appBar"]);
    Widget? bs = getPatternWidget(map["_bottomSheet"]);
    Widget? bn = getPatternWidget(map["_bottomNavigationBar"]);
    Widget? d = getPatternWidget(map["_drawer"]);
    Widget? ed = getPatternWidget(map["_endDrawer"]);
    dynamic ml = map["_persistentFooterButtons"];
    List<Widget>? lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    return Scaffold(
      key: map["_key"],
      appBar: (a != null) ? a as AppBar : null,
      body: w,
      backgroundColor: map['_backgroundColor'],
      bottomNavigationBar: bn,
      bottomSheet: bs,
      drawer: d,
      drawerDragStartBehavior:
          map['_drawerDragStartBehavior'] ?? DragStartBehavior.start,
      endDrawer: ed,
      endDrawerEnableOpenDragGesture:
          map['_endDrawerEnableOpenDragGesture'] ?? true,
      extendBody: map['_extendBody'] ?? false,
      extendBodyBehindAppBar: map['_extendBodyBehindAppBar'] ?? false,
      floatingActionButton: map['_floatingActionButton'],
      floatingActionButtonAnimator: map['_floatingActionButtonAnimator'],
      floatingActionButtonLocation: map['_floatingActionButtonLocation'],
      persistentFooterButtons: lw,
      primary: map['_primary'] ?? true,
      resizeToAvoidBottomInset: map['_resizeToAvoidBottomInset'],
    );
  }
}

class AppBarPattern extends ProcessPattern {
  AppBarPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? f = getPatternWidget(map["_flexibleSpace"]);
    Widget? lg = getPatternWidget(map["_leading"]);
    Widget? t = getPatternWidget(map["_title"]);
    dynamic ml = map["_actions"];
    List<Widget>? lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    return AppBar(
      actions: lw,
      actionsIconTheme: map["_actionsIconTheme"],
      backgroundColor: map['_backgroundColor'],
      automaticallyImplyLeading: map['_automaticallyImplyLeading'] ?? true,
      bottom: map['_bottom'],
      bottomOpacity: map['_bottomOpacity'] ?? 1.0,
      centerTitle: map['_centerTitle'],
      elevation: map['_elevation'],
      excludeHeaderSemantics: map['_excludeHeaderSemantics'] ?? false,
      flexibleSpace: f,
      iconTheme: map['_iconTheme'],
      leading: lg,
      leadingWidth: map['_leadingWidth'],
      primary: map['_primary'] ?? true,
      shadowColor: map['_shadowColor'],
      shape: map['_shape'],
      title: t,
      titleSpacing: map['_titleSpacing'] ?? NavigationToolbar.kMiddleSpacing,
      titleTextStyle: map["_titleTextStyle"],
      toolbarTextStyle: map["_textStyle"],
      toolbarHeight: map['_toolbarHeight'] ?? kToolbarHeight,
      toolbarOpacity: map['_toolbarOpacity'] ?? 1.0,
    );
  }
}

class TextPattern extends ProcessPattern {
  TextPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return Text(
      map["_text"],
      locale: map["_locale"],
      maxLines: map["_maxLines"],
      overflow: map["_textOverflow"],
      semanticsLabel: map["_semanticsLabel"],
      softWrap: map["_softWrap"],
      strutStyle: map["_strutStyle"],
      style: map["_textStyle"],
      textAlign: map["_textAlign"],
      textDirection: map["_textDirection"],
      textHeightBehavior: map["_textHeightBehavior"],
      textScaleFactor: map["_textScaleFactor"],
      textWidthBasis: map["_textWidthBasis"],
    );
  }
}

class ImageAssetPattern extends ProcessPattern {
  ImageAssetPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return Image.asset(map["_name"],
        bundle: map["_bundle"],
        frameBuilder: map["_frameBuilder"],
        errorBuilder: map["_errorBuilder"],
        semanticLabel: map["_semanticLabel"],
        excludeFromSemantics: map["_excludeFromSemantics"] ?? false,
        scale: map["_scale"],
        width: map["_width"],
        height: map["_height"],
        color: map["_color"],
        colorBlendMode: map["_colorBlendMode"],
        fit: map["_boxFit"],
        alignment: map["_alignment"] ?? Alignment.center,
        repeat: map["_repeat"] ??= ImageRepeat.noRepeat,
        centerSlice: map["_centerSlice"],
        matchTextDirection: map["_matchTextDirection"] ?? false,
        gaplessPlayback: map["_gaplessPlayback"] ?? false,
        isAntiAlias: map["_isAntiAlias"] ?? false,
        package: map["_package"],
        filterQuality: map["_filterQuality"] ?? FilterQuality.low,
        cacheWidth: map["_cacheWidth"],
        cacheHeight: map["_cacheHeight"]);
  }
}

class SVGAssetPattern extends ProcessPattern {
  SVGAssetPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return SvgPicture.asset(
      map["_name"],
      height: map["_height"],
    );
  }
}

class StackPattern extends ProcessPattern {
  StackPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    dynamic ml = map["_children"];
    List<Widget>? lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    return Stack(
        children: lw!,
        alignment: map["_alignment"] ?? AlignmentDirectional.topStart,
        clipBehavior: map["_clipBehavior"] ?? Clip.hardEdge,
        fit: map["_stackFit"] ?? StackFit.loose,
        textDirection: map["_textDirection"]);
  }
}

class ContainerPattern extends ProcessPattern {
  ContainerPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
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

class SingleChildScrollViewPattern extends ProcessPattern {
  SingleChildScrollViewPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return SingleChildScrollView(
        key: map["_key"],
        child: w,
        clipBehavior: map["_clipBehavior"] ?? Clip.hardEdge,
        controller: map["_controller"],
        dragStartBehavior: map["_dragStartBehavior"] ?? DragStartBehavior.start,
        padding: map["_padding"],
        physics: map["_scrollPhysics"],
        primary: map["_primary"],
        restorationId: map["_restorationId"],
        reverse: map["_reverse"] ?? false,
        scrollDirection: map["_scrollDirection"] ?? Axis.vertical);
  }
}

class GridViewPattern extends ProcessPattern {
  GridViewPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    dynamic ml = map["_children"];
    List<Widget>? lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    return GridView.count(
      key: map["_key"],
      scrollDirection: map["_scrollDirection"] ?? Axis.vertical,
      reverse: map["_reverse"] ?? false,
      controller: map["_controller"],
      primary: map["_primary"],
      physics: map["_physics"],
      shrinkWrap: map["_shrinkWrap"] ?? false,
      padding: map["_padding"],
      crossAxisCount: map["_crossAxisCount"],
      mainAxisSpacing: map["_mainAxisSpacing"] ?? 0.0,
      crossAxisSpacing: map["_crossAxisSpacing"] ?? 0.0,
      childAspectRatio: map["_childAspectRatio"] ?? 1.0,
      addAutomaticKeepAlives: map["_addAutomaticKeepAlives"] ?? true,
      addRepaintBoundaries: map["_addRepaintBoundaries"] ?? true,
      addSemanticIndexes: map["_addSemanticIndexes"] ?? true,
      cacheExtent: map["_cacheExtent"],
      children: lw!,
      semanticChildCount: map["_semanticChildCount"],
      dragStartBehavior: map["_dragStartBehavior"] ?? DragStartBehavior.start,
      keyboardDismissBehavior: map["_keyboardDismissBehavior"] ??
          ScrollViewKeyboardDismissBehavior.manual,
      restorationId: map["_restorationId"],
      clipBehavior: map["_clipBehavior"] ?? Clip.hardEdge,
    );
  }
}

class IndexedStackPattern extends ProcessPattern {
  IndexedStackPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    dynamic ml = map["_children"];
    List<Widget>? lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    return ValueListenableBuilder<int>(
      valueListenable: map["_notifier"],
      builder: (BuildContext context, int value, Widget? child) => IndexedStack(
          children: lw!,
          alignment: map["_alignment"] ?? AlignmentDirectional.topStart,
          sizing: map["_sizing"] ?? StackFit.loose,
          index: value,
          textDirection: map["_textDirection"]),
    );
  }
}

class ValueStackPattern extends ProcessPattern {
  ValueStackPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: map["_notifier"],
      builder: (BuildContext context, List<dynamic> children, Widget? child) =>
          Stack(
              children: getPatternWidgetList(children),
              alignment: map["_alignment"] ?? AlignmentDirectional.topStart,
              clipBehavior: map["_clipBehavior"] ?? Clip.hardEdge,
              fit: map["_stackFit"] ?? StackFit.loose,
              textDirection: map["_textDirection"]),
    );
  }
}

class CenterPattern extends ProcessPattern {
  CenterPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return Center(
        child: w,
        heightFactor: map["_heightFactor"],
        key: map["_key"],
        widthFactor: map["_widthFactor"]);
  }
}

class TextFieldPattern extends ProcessPattern {
  TextFieldPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? p = getPatternWidget(map["_prefixIcon"]);
    Widget? s = getPatternWidget(map["_suffixIcon"]);
    return TextField(
      autocorrect: map["_autocorrect"] ?? true,
      autofocus: map["_autofocus"] ?? false,
      controller: map["_textController"],
      enabled: map["_enabled"] ?? true,
      style: map["_textStyle"],
      showCursor: map["_showCursor"],
      maxLines: map["_maxLines"] ?? 1,
      expands: map["_expands"] ?? false,
      onSubmitted: map["_onSubmitted"],
      keyboardType: map["_keyboardType"],
      decoration: InputDecoration(
        border: map["_inputBorder"],
        icon: map["_icon"],
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
}

class ListViewPattern extends ProcessPattern {
  ListViewPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    dynamic ml = map["_children"];
    List<Widget>? lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;
    return ListView(
      key: map["_key"],
      scrollDirection: map["_scrollDirection"] ?? Axis.vertical,
      reverse: map["_reverse"] ?? false,
      controller: map["_controller"],
      primary: map["_primary"],
      physics: map["_physics"],
      shrinkWrap: map["_shrinkWrap"] ?? true,
      padding: map["_padding"],
      addAutomaticKeepAlives: map["_addAutomaticKeepAlives"] ?? true,
      addRepaintBoundaries: map["_addRepaintBoundaries"] ?? true,
      addSemanticIndexes: map["_addSemanticIndexes"] ?? true,
      cacheExtent: map["_cacheExtent"],
      children: lw!,
      semanticChildCount: map["_semanticChildCount"],
      dragStartBehavior: map["_dragStartBehavior"] ?? DragStartBehavior.start,
      keyboardDismissBehavior: map["_keyboardDismissBehavior"] ??
          ScrollViewKeyboardDismissBehavior.manual,
      restorationId: map["_restorationId"],
      clipBehavior: map["_clipBehavior"] ?? Clip.hardEdge,
    );
  }
}

class SizedBoxPattern extends ProcessPattern {
  SizedBoxPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return SizedBox(
      child: w,
      height: map["_height"],
      width: map["_width"],
    );
  }
}

class OpacityPattern extends ProcessPattern {
  OpacityPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return Opacity(opacity: map["_opacity"], child: w);
  }
}

class RichTextPattern extends ProcessPattern {
  RichTextPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return RichText(
      text: map["_textSpan"],
      textAlign: map["_textAlign"] ?? TextAlign.start,
    );
  }
}

class OverflowBoxPattern extends ProcessPattern {
  OverflowBoxPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return OverflowBox(
      child: w,
      alignment: map["_alignment"] ?? Alignment.center,
      maxHeight: map["_height"],
      maxWidth: map["_width"],
    );
  }
}

class PositionedPattern extends ProcessPattern {
  PositionedPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    Widget? w = getPatternWidget(map["_child"]);
    return Positioned(
      child: w!,
      top: map["_top"],
      bottom: map["_bottom"],
      left: map["_left"],
      right: map["_right"],
      height: map["_height"],
      width: map["_width"],
    );
  }
}

class DividerPattern extends ProcessPattern {
  DividerPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return Divider(
      color: map["_color"],
      endIndent: map["_endIndent"],
      indent: map["_indent"],
      height: map["_height"],
      thickness: map["_thickness"],
    );
  }
}
