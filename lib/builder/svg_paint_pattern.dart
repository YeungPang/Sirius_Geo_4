import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/resources/basic_resources.dart';

class SvgPaint extends StatelessWidget {
  final Map<String, dynamic> map;

  SvgPaint(this.map);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> _mv = map["_mv"];
    bool moved = false;
    ValueNotifier<Offset> notifier = _mv["_svgPaintNoti"];
    return Listener(
      //onPointerDown: (e) => notifier.value = e.localPosition,
      onPointerMove: (e) => moved = true,
      onPointerUp: (e) => moved ? moved = false : rebuild(_mv, notifier, e),
      child: CustomPaint(
        painter: SvgPainter(map, map["_shapes"], notifier, _mv),
        child: const SizedBox.expand(),
      ),
    );
  }

  Offset toLocal(BuildContext context, Offset position) {
    RenderBox renderBox = context.findRenderObject();
    return renderBox.globalToLocal(position);
  }

  rebuild(Map<String, dynamic> _mv, ValueNotifier<Offset> notifier, e) {
    notifier.value = e.localPosition;
    if (_mv["_state"] != "selected") {
      ValueNotifier<double> confirmNoti = _mv["_confirmNoti"];
      confirmNoti.value = 1.0;
      _mv["_state"] = "selected";
      Offset o = e.localPosition;
      _mv["_offSetLocal"] = Offset(o.dx.toInt().toDouble(), o.dy);
    }
  }
}

class ShapeText {
  final String _label;
  final double _fontSize;
  final String _fontFamily;
  final Color _color;

  ShapeText(this._label, this._fontSize, this._fontFamily, this._color);
}

class Shape {
  Shape(strPath, this._inx, this._shapeText, this._paint, this._borderPaint)
      : _path = parseSvgPathData(strPath);

  /// transforms a [_path] into [_transformedPath] using given [matrix]
  void transform(Matrix4 matrix) =>
      _transformedPath = _path.transform(matrix.storage);

  final Path _path;
  Path _transformedPath;
  final Paint _paint;
  final Paint _borderPaint;
  final ShapeText _shapeText;
  final int _inx;
}

class SvgPainter extends CustomPainter {
  final ValueNotifier<Offset> _notifier;
  final Map<String, dynamic> _mv;
  final Map<String, dynamic> map;
  Size _size = Size.zero;
  final List<Shape> shapes;
  Paint selPaint;
  Paint ansPaint;

  SvgPainter(this.map, this.shapes, this._notifier, this._mv)
      : super(repaint: _notifier);

  @override
  void paint(Canvas canvas, Size size) {
    selPaint = _mv["_selPaint"];
    ansPaint = _mv["_ansPaint"];
    //bool showLabel = map["showLabel"] ?? false;
    bool showSelLabel = map["_showSelLabel"] ?? false;
    String ansLabel = _mv["_ansLabel"];
    double offsetWidth = map["_offsetWidth"] ?? 0.0;
    double offsetHeight = map["_offsetHeight"] ?? 0.0;
    // double offsetWidth = 0.0;
    // double offsetHeight = 0.0;

    if (size != _size) {
      _size = size;
      final fs = applyBoxFit(BoxFit.contain, size, size);
//          BoxFit.contain, Size(map["_boxWidth"], map["_boxHeight"]), size);
      final r = Alignment.center
          .inscribe(fs.destination, Offset(offsetWidth, offsetHeight) & size);
      final matrix = Matrix4.translationValues(r.left, r.top, 0)
        ..scale(fs.destination.width / fs.source.width);
      for (var shape in shapes) {
        shape.transform(matrix);
      }
      print('new size: $_size');
    }

    canvas
      ..clipRect(Offset(offsetWidth, offsetHeight) & size)
      ..drawColor(_mv["_background"], BlendMode.src);

    bool hasSelection = false;
    for (var shape in shapes) {
      final path = shape._transformedPath;
      final selected = path.contains(_notifier.value);
      Paint paint = (shape._shapeText._label == ansLabel)
          ? _mv["_ansPaint"]
          : ((selPaint != null) && selected)
              ? selPaint
              : shape._paint;
      canvas.drawPath(path, paint);
      if (selected) {
        _mv["_selIndex"] = shape._inx;
        _mv["_selLabel"] = shape._shapeText._label;
        hasSelection = true;
      }

      canvas.drawPath(path, shape._borderPaint);

      if (selected && showSelLabel) {
        final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
          fontSize: shape._shapeText._fontSize,
          fontFamily: shape._shapeText._fontFamily,
        ))
          ..pushStyle(ui.TextStyle(
            color: shape._shapeText._color,
            shadows: kElevationToShadow[1] + kElevationToShadow[2],
          ))
          ..addText(shape._shapeText._label);
        final paragraph = builder.build()
          ..layout(ui.ParagraphConstraints(width: size.width));
        canvas.drawParagraph(paragraph,
            _notifier.value.translate(0, -1 * shape._shapeText._fontSize));
      }
    }
    if (!hasSelection) {
      if (_mv["_state"] == "selected") {
        _mv["_state"] = "unselected";
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

initSvgPainter(Map<String, dynamic> map) {
  Map<String, dynamic> _mv = map["_mv"];
  _mv["_selPaint"] = Paint()
    ..color = colorMap[map["_selColor"]]
    ..style = PaintingStyle.fill;
  _mv["_ansPaint"] = Paint()
    ..color = colorMap[map["_ansColor"]]
    ..style = PaintingStyle.fill;
  if (map["_shapeColor"] != null) {
    map["_shapePaint"] = Paint()
      ..color = colorMap[map["_shapeColor"]]
      ..style = PaintingStyle.fill;
  }
  _mv["_background"] = colorMap[map["_backgroundColor"]];
  if (map["_selLabelColor"] != null) {
    _mv["_selLabelColor"] = colorMap[map["_selLabelColor"]];
  }
  map["_borderPaint"] = Paint()
    ..color = colorMap[map["_borderColor"]]
    ..strokeWidth = map["_borderStroke"] ?? 3.0
    ..style = PaintingStyle.stroke;
}

class SvgPaintPattern extends ProcessPattern {
  SvgPaintPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    return SvgPaint(map);
  }
}
