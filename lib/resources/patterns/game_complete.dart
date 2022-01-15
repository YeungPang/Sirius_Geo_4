import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:sirius_geo_4/builder/pattern.dart';
import 'package:sirius_geo_4/model/locator.dart';
import 'package:sirius_geo_4/resources/fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

const String _fbUrl = 'fb://profile/';
const String _fbUrlFallback = 'https://www.facebook.com';

const String _twitterUrl = 'twitter://profile/';
const String _twitterUrlFallback = 'https://www.twitter.com';

const String _instaUrl = 'insta://profile/';
const String _instaUrlFallback = 'https://www.instagram.com';

const String _pIntrestUrlFallback = 'https://www.pinterest.com';

class GameComplete extends StatelessWidget {
  final Map<String, dynamic> map;
  final ScreenshotController _screenshotController = ScreenshotController();

  GameComplete(this.map);
  @override
  Widget build(BuildContext context) {
    dynamic ml = map["_gameCompleteList"];
    List<Widget> lw = (ml is List<Widget>)
        ? ml
        : (ml is List<dynamic>)
            ? getPatternWidgetList(ml)
            : null;

    return Screenshot(
        controller: _screenshotController,
        child: Align(
            alignment: Alignment.center,
            child: Card(
              elevation: 5,
              color: const Color(0xFFF5F6FA),
              child: Container(
                width: map["_width"],
                height: map["_height"],
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color(0xFFAEE1FC),
                  Color(0xFFD4ECF9),
                ])),
                child: Stack(
                  children: lw,
                ),
              ),
            )));
  }
}

Widget getScoreCard(
    String text, int points, Color c, Alignment a, double h, double w) {
  TextStyle sts = yourScoreStyle.copyWith(color: c);
  TextStyle bts = sts.copyWith(fontSize: 35);
  return SizedBox(
      height: h,
      width: w,
      child: Align(
          alignment: a,
          child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1)),
              child: Container(
                alignment: Alignment.center,
                width: w,
                height: w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(text, textAlign: TextAlign.center, style: sts),
                    Text(points.toString(),
                        textAlign: TextAlign.center, style: bts),
                  ],
                ),
              ))));
}

Widget getShareContainer(Map<String, dynamic> map) {
  String share = model.map["text"]["share"];
  String imagePath = map["_shareIcon"];
  return Container(
    alignment: Alignment.center,
    height: map["_shareHeight"],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Text(
            share,
            textAlign: TextAlign.center,
            style: choiceButnTxtStyle,
          ),
        ),
        GestureDetector(
            onTap: () {
              _takeScreenshot();
            },
            child: Container(
                child: Image(
              image: AssetImage(imagePath),
              height: 20.0,
              width: 20.0,
              color: const Color(0xFF1785C1),
            )))
      ],
    ),
  );
}

Widget socialMediaButtons() {
  return Container(
    margin: const EdgeInsets.only(top: 15, bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _launchSocial(_fbUrl, _fbUrlFallback);
          },
          child: Container(
              child: ClipOval(
            child: Image.asset(
              'assets/images/facebook.png',
              height: 40,
              width: 40,
            ),
          )),
        ),
        GestureDetector(
            onTap: () {
              _launchSocial(_twitterUrl, _twitterUrlFallback);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/twitter.png',
                  height: 40,
                  width: 40,
                ),
              ),
            )),
        GestureDetector(
            onTap: () {
              _launchSocial(_instaUrl, _instaUrlFallback);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/instagram.png',
                  height: 40,
                  width: 40,
                ),
              ),
            )),
        GestureDetector(
            onTap: () {
              _launchSocial(_pIntrestUrlFallback, _pIntrestUrlFallback);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/pinterest.png',
                  height: 40,
                  width: 40,
                ),
              ),
            )),
      ],
    ),
  );
}

final ScreenshotController _screenshotController = ScreenshotController();
void _takeScreenshot() async {
  _screenshotController.capture().then((Uint8List image) async {
    //Screenshot captured
    var _imageFile = image;

    //Getting path for directory
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    //Saving image to local
    File imgFile = File('$appDocumentsPath/screenshot.png');
    await imgFile.writeAsBytes(_imageFile);

    //sharing image over social apps
    Share.file("GameComplete", 'screenshot.png', _imageFile, 'image/png');
  }).catchError((onError) {
    print(onError);
  });
}

void _launchSocial(String url, String fallbackUrl) async {
  try {
    bool launched =
        await launch(url, forceSafariVC: false, forceWebView: false);
    if (!launched) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  } catch (e) {
    await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
  }
}

class GameCompletePattern extends ProcessPattern {
  GameCompletePattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    return GameComplete(map);
  }
}

class GameItemPattern extends ProcessPattern {
  GameItemPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String name}) {
    switch (map["_name"]) {
      case "scoreCard":
        return getScoreCard(map["_text"], map["_points"], map["_color"],
            map["_alignment"], map["_height"], map["_width"]);
      case "shareContainer":
        return getShareContainer(map);
      case "socialMediaButtons":
        return socialMediaButtons();
      default:
        break;
    }
    return null;
  }
}
