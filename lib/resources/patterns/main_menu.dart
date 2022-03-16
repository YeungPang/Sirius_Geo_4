import 'package:flutter/material.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/resources/basic_resources.dart';
import 'package:sirius_geo_4/resources/fonts.dart';

Widget topicWidget(Map<String, dynamic> map) {
  double h = map["_height"];
  double w = map["_width"];
  String img = map["_img"] ?? 'assets/images/world.png';
  if (img == 'learn') {
    img = "assets/images/LearningJourney.png";
  }
  Text subtitle = (map["_knowYourWorld"] != null)
      ? Text(
          map["_knowYourWorld"],
          style: smallSemiTextStyle.copyWith(color: Colors.white),
        )
      : Text(
          map["_subtitle"],
          style: topicTxtStyle,
        );
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
                img,
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
                      margin: EdgeInsets.only(top: size10),
                      child: subtitle,
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
