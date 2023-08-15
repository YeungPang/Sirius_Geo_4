import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../util/util.dart';
import '../../builder/special_pattern.dart';
import '../../resources/basic_resources.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../fonts.dart';

class SliderWidget extends StatefulWidget {
  final Map<String, dynamic> map;

  SliderWidget(this.map, {Key? key}) : super(key: key);

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> map;
  late Map<String, dynamic> _mv;
  late String _text;
  late double _start;
  late double _end;
  late double width;
  late double height;
  late String _ys;
  late String _suff;
  late String _scalet;
  late double _absoluteValue;
  late double _scaleValue;
  late double _ratio;
  int dec = 2;
  int _res = 0;

  @override
  void initState() {
    _reset();
    super.initState();
  }

  _reset() {
    map = widget.map;
    _mv = map["_mv"];
    _text = map["_text"];
    num n = map["_start"];
    _start = n.toDouble();
    n = map["_end"];
    _end = n.toDouble();
    width = model.scaleWidth;
    height = model.scaleHeight;
    _ys = model.map["text"]["yourSel"];
    _suff = map["_suffix"];
    dec = map["_scaleDec"] ?? dec;
    _scalet = numString(_start, dec: dec) + ' ' + _suff;
    _absoluteValue = 0.0;
    _scaleValue = 0.0;
    _ratio = (_end - _start) / 100.0;
    RxDouble _confirmNoti = resxController.getRx("confirm");
    _confirmNoti.value = 0.5;
    _mv["_state"] = "start";
  }

  @override
  Widget build(BuildContext context) {
    if (map != widget.map) {
      _reset();
    }
    return ValueListenableBuilder<int>(
      valueListenable: map["_sliderNoti"],
      builder: (BuildContext context, int value, Widget? child) => Stack(
        clipBehavior: Clip.none,
        children: _getStackChildren(value),
      ),
    );
  }

  List<Widget> _getStackChildren(int r) {
    _res = r;
    List<Widget> cl = [
      Container(
          height: model.scaleHeight * 0.25,
          width: model.scaleWidth * 0.9,
          margin: EdgeInsets.only(bottom: size10),
          child: Card(
              elevation: 4 * sizeScale,
              color: colorMap["btnBlueGradEnd"],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size20),
              ),
              margin: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size20),
                  gradient: blueGradient,
                ),
                child: (r > 0) ? _percentCard() : _sliderCard(),
              )))
    ];
    _buildAnswer(cl);
    return cl;
  }

  Widget _sliderCard() {
    return Container(
      height: height * 0.195,
      width: width * 0.9,
      margin: EdgeInsets.all(size10),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(size20)),
        elevation: 2,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: width * 0.04, top: height * 0.02),
                child: Text(
                  _ys,
                  style: sliderBoldTextStyle,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: width * 0.04,
                ),
                child: Text(
                  _scalet,
                  style: sliderTextStyle,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: width * 0.04, top: height * 0.01),
                child: Text(
                  _text,
                  style: sliderSmallTextStyle,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: width * 0.01,
                ),
                child: FlutterSlider(
                  values: [_absoluteValue],
                  step: const FlutterSliderStep(
                      isPercentRange: false, step: 0.01),
                  max: 100,
                  min: 0,
                  handlerHeight: size20,
                  handlerWidth: size20,
                  handler: FlutterSliderHandler(
                    child: Container(
                      child: Image.asset('assets/images/slider_circle.png'),
                    ),
                  ),
                  trackBar: const FlutterSliderTrackBar(
                      activeTrackBar: BoxDecoration(gradient: blueGradient)),
                  onDragging: (handlerIndex, lowerValue, upperValue) {
                    if (_mv["_state"] != "edited") {
                      RxDouble _confirmNoti = resxController.getRx("confirm");
                      _confirmNoti.value = 1.0;
                      _mv["_state"] = "edited";
                    }
                    setState(() {
                      _absoluteValue = lowerValue;
                      _scaleValue = lowerValue * _ratio;
                      double sv = _scaleValue + _start;
                      _scalet = numString(sv, dec: dec) + ' ' + _suff;
                      _mv["_in1"] = sv;
                    });
                  },
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: width * 0.04, right: size10),
                  child: Row(
                    children: [
                      Text(
                        numString(_start, dec: dec) + ' ' + _suff,
                        style: sliderSmallTextStyle,
                      ),
                      const Spacer(),
                      Text(
                        numString(_end, dec: dec) + ' ' + _suff,
                        style: sliderSmallTextStyle,
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _percentCard() {
    //reset = true;
    return Container(
        height: height * 0.195,
        width: width * 0.9,
        margin: EdgeInsets.all(size10),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size20)),
          elevation: 2,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _getPercentWidgets(),
            ),
          ),
        ));
  }

  List<Widget> _getPercentWidgets() {
    double diff = 0.0;
    Color? c;
    if (_res == 1) {
      String rs = _mv["_resStatus"];
      c = (rs == "g")
          ? colorMap["correct"]
          : (rs == "o")
              ? colorMap["almost"]
              : colorMap["incorrect"];
      double ans = _mv["_ans1"];
      diff = ans - _scaleValue - _start;
    }
    return [
      Container(
        margin: EdgeInsets.only(left: width * 0.04, top: height * 0.02),
        child: Text(
          _ys,
          style: sliderBoldTextStyle,
        ),
      ),
      Container(
        margin: EdgeInsets.only(
          left: width * 0.04,
        ),
        child: Text(
          _scalet,
          style: sliderTextStyle,
        ),
      ),
      Container(
        margin: EdgeInsets.only(left: width * 0.04, top: height * 0.01),
        child: (_res != 1)
            ? Text(
                _text,
                style: sliderSmallTextStyle,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _text,
                    style: sliderSmallTextStyle,
                  ),
                  Text(
                    numString(diff, dec: dec) + ' ' + _suff,
                    style: sliderSmallTextStyle.copyWith(color: c),
                  )
                ],
              ),
      ),
      Container(
        margin: EdgeInsets.only(left: width * 0.03, top: 4 * sizeScale),
        child: (_res == 1) ? _getResultIndicator(diff) : _getPerIndicator(),
      ),
      Container(
          margin: EdgeInsets.only(
              left: width * 0.04, top: 4 * sizeScale, right: size10),
          child: Row(
            children: [
              Text(
                numString(_start, dec: dec) + ' ' + _suff,
                style: sliderSmallTextStyle,
              ),
              const Spacer(),
              Text(
                numString(_end, dec: dec) + ' ' + _suff,
                style: sliderSmallTextStyle,
              ),
            ],
          )),
    ];
  }

  _buildAnswer(List<Widget> cl) {
    if ((_res != 0) && (_res != 2)) {
      _buildSliderResult();
      Widget aw = Positioned(
        top: height * 0.024,
        left: width * 0.69,
        child: _mv["_res1"],
      );
      cl.add(aw);
    }
  }

  Widget _getResultIndicator(double diff) {
    String rs = _mv["_resStatus"];
    LinearGradient lg = (rs == "g")
        ? greenGradient
        : (rs == "o")
            ? orangeGradient
            : redGradient;
    if (diff == 0.0) {
      return _getPerIndicator();
    }
    double pos = (diff > 0.0) ? _scaleValue : _scaleValue + diff;
    pos = pos * width * 0.75 / _ratio / 100.0;
    double w = (diff.abs() * width * 0.75 / _ratio / 100.0);
    //pos = 2.0;
    debugPrint("pos: " + pos.toString());
    debugPrint("width:" + w.toString());
    return Container(
        height: 5,
        width: width * 0.75,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size10),
            color: Colors.grey.shade200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _getLengthContainer(pos, blueGradient),
            _getLengthContainer(w, lg)
          ],
        ));
  }

  LinearPercentIndicator _getPerIndicator() {
    double lineHeight = 5.0 * sizeScale;
    return LinearPercentIndicator(
      width: width * 0.75,
      animation: true,
      lineHeight: lineHeight,
      animationDuration: 1,
      percent: _scaleValue / _ratio / 100,
      barRadius: Radius.circular(lineHeight * 0.5),
      // progressColor: Colors.green,
      linearGradient: blueGradient,
    );
  }

  Widget _getLengthContainer(double w, LinearGradient lg) {
    return Container(
      width: w,
      height: 5.0 * sizeScale,
      decoration: BoxDecoration(
          gradient: lg,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size10),
              bottomLeft: Radius.circular(size10))),
    );
  }

  _buildSliderResult() {
    Color? c = (_mv["_resStatus"] == "g")
        ? colorMap["correct"]
        : (_mv["_resStatus"] == "o")
            ? colorMap["almost"]
            : colorMap["incorrect"];
    TextStyle ts = sliderTextStyle.copyWith(color: c);
    List<Widget> wl = [
      Text(
        numString(_mv["_ans1"], dec: dec) + ' ' + _suff,
        style: ts,
      ),
    ];
    Map<String, dynamic> m1 = {
      "resColor": c,
      "resCol": Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: wl,
          ))
    };
    Widget w1 = _buildSliderResValue(m1);
    Widget ansC = Container(
      width: 60.0 * sizeScale,
      height: 16.0 * sizeScale,
      //margin: EdgeInsets.only(left: 15.0),
      color: Colors.white,
      alignment: const Alignment(-0.9, 0.0),
      child: Text(
        model.map["text"]["Answer"],
        style: ts,
      ),
    );

    Widget ansW = Align(alignment: const Alignment(-0.3, -1.0), child: ansC);
    double w = 0.213333 * model.scaleWidth;
    double h = 0.0738916 * model.scaleHeight;
    _mv["_res1"] = SizedBox(
        width: w,
        height: h,
        child: OverflowBox(
            maxWidth: 180.0 * sizeScale,
            child: Stack(alignment: Alignment.topLeft, children: [w1, ansW])));
  }

  Widget _buildSliderResValue(Map<String, dynamic> map) {
    Map<String, dynamic> amap = {
      "_elevation": 4.0 * sizeScale,
      "_cardRadius": size20,
      "_height": 0.086207 * model.scaleHeight,
      "_width": 0.453333 * model.scaleWidth,
      "_margin": EdgeInsets.only(top: size10),
      "_btnBRadius": size20,
      "_color": Colors.white,
      "_borderColor": map["resColor"],
      "_child": map["resCol"]
    };
    //map.addAll(amap);
    Widget cb = ColorButton(amap);
    Map<String, dynamic> cmap = {};
    cmap.addAll(amap);
    cmap["_child"] = cb;
    return CardPattern(cmap).getWidget();
  }
}

class SliderPattern extends ProcessPattern {
  SliderPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return SliderWidget(map);
  }
}
