import 'package:flutter/material.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/resources/fonts.dart';

Widget topicWidget(Map<String, dynamic> map) {
  double h = map["_height"];
  double w = map["_width"];
  return Container(
    height: h,
    decoration: map["_decoration"],
    child: Stack(children: [
      Image.asset(
        'assets/images/top_background_circles.png',
      ),
      SizedBox(
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              child: Image.asset(
                'assets/images/world.png',
                width: w * 0.4,
                height: h * 0.94,
              ),
            ),
            Container(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: h * 0.3),
                      child: Text(
                        map["_topicSelection"],
                        style: topicTxtStyle,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        map["_knowYourWorld"],
                        style: smallTextStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      )
    ]),
  );
}

class TopicPattern extends ProcessPattern {
  TopicPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    map["_widget"] ??= topicWidget(map);
    return map["_widget"];
  }
}
