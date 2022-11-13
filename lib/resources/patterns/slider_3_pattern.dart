import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../builder/special_pattern.dart';
import '../../resources/basic_resources.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../fonts.dart';

class ThreeSliderWidget extends StatefulWidget {
  final Map<String, dynamic> map;

  ThreeSliderWidget(this.map);
  @override
  _ThreeSliderWidgetState createState() => _ThreeSliderWidgetState();
}

class _ThreeSliderWidgetState extends State<ThreeSliderWidget>
    with SingleTickerProviderStateMixin {
  //final _key = new GlobalKey<_SliderWidgetState>();
  double height = 0.0;
  double width = 0.0;
  int _res = 0;
  bool _isSwitched = false;
  late AnimationController rotationController;
  List<Map<String, dynamic>> _scale = [{}, {}, {}];
  double _absoluteValue = 0.0;
  double _ratio12 = 0.0;
  double _ratio13 = 0.0;
  String _ys = "";
  late Map<String, dynamic> _mv;
  late Map<String, dynamic> map;

  //bool reset = false;

  @override
  void initState() {
    rotationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    height = model.scaleHeight;
    width = model.scaleWidth;
    _reset();
    super.initState();
  }

  _reset() {
    map = widget.map;
    _scale[0]["text"] = map["_text1"];
    _scale[1]["text"] = map["_text2"];
    _scale[2]["text"] = map["_text3"];
    _scale[0]["start"] = map["_start1"];
    _scale[1]["start"] = map["_start2"];
    _scale[2]["start"] = map["_start3"];
    _scale[0]["end"] = map["_end1"];
    _scale[1]["end"] = map["_end2"];
    _scale[2]["end"] = map["_end3"];
    num n = map["_ratio12"];
    _ratio12 = n.toDouble();
    n = map["_ratio13"];
    _ratio13 = n.toDouble();
    _scale[0]["s"] = map["_suffix1"];
    _scale[1]["s"] = map["_suffix2"];
    _scale[2]["s"] = map["_suffix3"];
    _ys = model.map["text"]["yourSel"];
    _scale[0]["r"] = (_scale[0]["end"] - _scale[0]["start"]) / 100.0;
    _scale[1]["r"] = (_scale[1]["end"] - _scale[1]["start"]) / 100.0;
    _scale[2]["r"] = (_scale[2]["end"] - _scale[2]["start"]) / 100.0;
    _mv = map["_mv"];
    _absoluteValue = 0.0;
    _isSwitched = false;
    _scale[0]["value"] = 0.0;
    _scale[1]["value"] = 0.0;
    _scale[2]["value"] = 0.0;
    _scale[0]["t"] = _scale[0]["start"].toString() + _scale[0]["s"];
    _scale[1]["t"] = _scale[1]["start"].toString() + _scale[1]["s"];
    _scale[2]["t"] = _scale[2]["start"].toString() + _scale[2]["s"];
    RxDouble _confirmNoti = resxController.getRx("confirm");
    _confirmNoti.value = 0.5;
    _mv["_state"] = "start";
    _res = 0;
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
    if ((_res != r) && (r == 0)) {
      _reset();
      //reset = false;
    }
    _res = r;
    List<Widget> cl = [
      Container(
          height: height * 0.6,
          width: width * 0.9,
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
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (_res > 0) ? _percentCard() : _sliderCard(),
                        Center(
                          child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 0.5)
                                  .animate(rotationController),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                child: InkWell(
                                  onTap: () {
                                    if (_res == 0) {
                                      setState(() {
                                        if (_isSwitched) {
                                          _isSwitched = false;
                                          _absoluteValue = _scale[0]["value"] /
                                              _scale[0]["r"];
                                          rotationController.forward(from: 0.0);
                                        } else {
                                          _isSwitched = true;
                                          _absoluteValue = _scale[1]["value"] /
                                              _scale[1]["r"];
                                          rotationController.reverse(from: 1.0);
                                        }
                                      });
                                    }
                                  },
                                  child: Image.asset(
                                    'assets/images/switch.png',
                                    height: height * 0.05,
                                    width: height * 0.05,
                                  ),
                                ),
                              )),
                        ),
                        _selectionCard(),
                      ],
                    ),
                  )))),
    ];
    _buildAnswer(cl);
    return cl;
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
              children:
                  _isSwitched ? _getPercentWidgets(1) : _getPercentWidgets(0),
            ),
          ),
        ));
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
                  _isSwitched ? _scale[1]["t"] : _scale[0]["t"],
                  style: sliderTextStyle,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: width * 0.04, top: height * 0.01),
                child: Text(
                  _isSwitched ? _scale[1]["text"] : _scale[0]["text"],
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
                      if (_isSwitched) {
                        _scale[1]["value"] = lowerValue * _scale[1]["r"];
                        _scale[0]["value"] = _scale[1]["value"] / _ratio12;
                        if (_scale[0]["value"] > _scale[0]["end"]) {
                          _scale[0]["value"] = _scale[0]["end"];
                        }
                        _scale[2]["value"] = _scale[0]["value"] * _ratio13;
                      } else {
                        _scale[0]["value"] = lowerValue * _scale[0]["r"];
                        _scale[1]["value"] = _scale[0]["value"] * _ratio12;
                        _scale[2]["value"] = _scale[0]["value"] * _ratio13;
                      }
                      double sv = _scale[1]["value"] + _scale[1]["start"];
                      _scale[1]["t"] = sv.toStringAsFixed(2) + _scale[1]["s"];
                      sv = _scale[0]["value"] + _scale[0]["start"];
                      _mv["_in1"] = sv;
                      _scale[0]["t"] = sv.toStringAsFixed(2) + _scale[0]["s"];
                      sv = _scale[2]["value"] + _scale[2]["start"];
                      _scale[2]["t"] = sv.toStringAsFixed(2) + _scale[2]["s"];
                    });
                  },
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: width * 0.04, right: size10),
                  child: Row(
                    children: [
                      Text(
                        _isSwitched
                            ? _scale[1]["start"].toString() + _scale[1]["s"]
                            : _scale[0]["start"].toString() + _scale[0]["s"],
                        style: sliderSmallTextStyle,
                      ),
                      const Spacer(),
                      Text(
                        _isSwitched
                            ? _scale[1]["end"].toString() + _scale[1]["s"]
                            : _scale[0]["end"].toString() + _scale[0]["s"],
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

  Widget _selectionCard() {
    List<Widget> colList = _getPercentWidgets(_isSwitched ? 0 : 1);
    colList.add(
      Container(
        color: Colors.grey.shade700,
        height: 1,
        margin: EdgeInsets.only(top: size10),
      ),
    );
    colList.addAll(_getPercentWidgets(2));
    return Container(
      height: height * 0.3,
      width: width * 0.9,
      margin: EdgeInsets.only(left: size10, right: size10, top: 4 * sizeScale),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(size20)),
        elevation: 2,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: colList,
          ),
        ),
      ),
    );
  }

  List<Widget> _getPercentWidgets(int i) {
    double diff = 0.0;
    Color? c;
    if (_res == 1) {
      String rs = _mv["_resStatus"];
      c = (rs == "g")
          ? colorMap["correct"]
          : (rs == "o")
              ? colorMap["almost"]
              : colorMap["incorrect"];
      num n = _mv["_ans" + (i + 1).toString()];
      double ans = n.toDouble();
      diff = ans - _scale[i]["value"] - _scale[i]["start"];
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
          _scale[i]["t"],
          style: sliderTextStyle,
        ),
      ),
      Container(
        margin: EdgeInsets.only(left: width * 0.04, top: height * 0.01),
        child: (_res != 1)
            ? Text(
                _scale[i]["text"],
                style: sliderSmallTextStyle,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _scale[i]["text"],
                    style: sliderSmallTextStyle,
                  ),
                  Text(
                    diff.toStringAsFixed(2) + _scale[i]["s"],
                    style: sliderSmallTextStyle.copyWith(color: c),
                  )
                ],
              ),
      ),
      Container(
        margin: EdgeInsets.only(left: width * 0.03, top: 4 * sizeScale),
        child: (_res == 1) ? _getResultIndicator(i, diff) : _getPerIndicator(i),
      ),
      Container(
          margin: EdgeInsets.only(
              left: width * 0.04, top: 4 * sizeScale, right: size10),
          child: Row(
            children: [
              Text(
                _scale[i]["start"].toString() + _scale[i]["s"],
                style: sliderSmallTextStyle,
              ),
              const Spacer(),
              Text(
                _scale[i]["end"].toString() + _scale[i]["s"],
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
        child: _isSwitched ? _mv["_res2"] : _mv["_res1"],
      );
      cl.add(aw);
      aw = Positioned(
        top: height * 0.29,
        left: width * 0.69,
        child: _isSwitched ? _mv["_res1"] : _mv["_res2"],
      );
      cl.add(aw);
      aw = Positioned(
        top: height * 0.44,
        left: width * 0.69,
        child: _mv["_res3"],
      );
      cl.add(aw);
    }
  }

  Widget _getResultIndicator(int i, double diff) {
    String rs = _mv["_resStatus"];
    LinearGradient lg = (rs == "g")
        ? greenGradient
        : (rs == "o")
            ? orangeGradient
            : redGradient;
    if (diff == 0.0) {
      return _getPerIndicator(i);
    }
    double pos = (diff > 0.0) ? _scale[i]["value"] : _scale[i]["value"] + diff;
    pos = pos * width * 0.75 / _scale[i]["r"] / 100.0;
    double w = (diff.abs() * width * 0.75 / _scale[i]["r"] / 100.0);
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

  LinearPercentIndicator _getPerIndicator(int i) {
    return LinearPercentIndicator(
      width: width * 0.75,
      animation: true,
      lineHeight: 5.0 * sizeScale,
      animationDuration: 1,
      percent: _scale[i]["value"] / _scale[i]["r"] / 100,
      linearStrokeCap: LinearStrokeCap.roundAll,
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
        _mv["_ans1"].toString() + map["_suffix1"],
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
    wl = [
      Text(
        _mv["_ans2"].toString() + map["_suffix2"],
        style: ts,
      ),
    ];
    m1["resCol"] = Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 18.0 * sizeScale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: wl,
        ));
    Widget w2 = _buildSliderResValue(m1);
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
    _mv["_res2"] = SizedBox(
        width: w,
        height: h,
        child: OverflowBox(
            maxWidth: 180.0 * sizeScale,
            child: Stack(alignment: Alignment.topLeft, children: [w2, ansW])));
    wl = [
      Text(
        _mv["_ans3"].toString() + map["_suffix3"],
        style: ts,
      ),
    ];
    m1["resCol"] = Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: size20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: wl,
        ));
    _mv["_res3"] = SizedBox(
        width: w,
        height: h,
        child: OverflowBox(
            maxWidth: 180.0 * sizeScale,
            child: Stack(
                alignment: Alignment.topLeft,
                children: [_buildSliderResValue(m1), ansW])));
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

class ThreeSliderPattern extends ProcessPattern {
  ThreeSliderPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    return ThreeSliderWidget(map);
  }
}
