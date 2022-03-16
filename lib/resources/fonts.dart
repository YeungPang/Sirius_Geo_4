import 'package:flutter/material.dart';
import 'package:sirius_geo_4/model/locator.dart';

final fontScale = model.fontScale;

final fsize24 = 24.0 * fontScale;
final fsize22 = 22.0 * fontScale;
final fsize20 = 20.0 * fontScale;
final fsize18 = 18.0 * fontScale;
final fsize16 = 16.0 * fontScale;
final fsize14 = 14.0 * fontScale;
final fsize12 = 12.0 * fontScale;
final fsize10 = 10.0 * fontScale;
final fsize8 = 8.0 * fontScale;

final w300 = (fontScale <= 0.7) ? FontWeight.w200 : FontWeight.w300;
final w400 = (fontScale <= 0.75) ? FontWeight.w300 : FontWeight.w400;
final w500 = (fontScale <= 0.6)
    ? FontWeight.w300
    : ((fontScale <= 0.8) ? FontWeight.w400 : FontWeight.w500);
final w600 = (fontScale <= 0.6)
    ? FontWeight.w400
    : ((fontScale <= 0.8) ? FontWeight.w500 : FontWeight.w600);
final w700 = (fontScale <= 0.6)
    ? FontWeight.w500
    : ((fontScale <= 0.8) ? FontWeight.w600 : FontWeight.w700);
final w900 = (fontScale <= 0.6)
    ? FontWeight.w700
    : ((fontScale <= 0.8) ? FontWeight.w800 : FontWeight.w900);

const Color textColorDark = Colors.black;
const Color textColorLight = Colors.white;
const Color textColorAccent = Colors.red;
const Color textColorFaint = Color.fromRGBO(125, 125, 125, 1.0);
const Color blueGrey = Colors.blueGrey;

final defaultPaddingHorizontal = 12.0 * model.sizeScale;

const String fontNameAN = 'Lato';

final TextStyle appBarTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w300,
  fontSize: fsize16,
  color: Colors.white,
);

final TextStyle titleTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w300,
  fontSize: fsize22,
  color: textColorDark,
);

final TextStyle subTitleTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w300,
  fontSize: fsize16,
  color: textColorAccent,
);

final TextStyle captionTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w300,
  fontSize: fsize12,
  color: textColorDark,
);

final TextStyle normalTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize16,
  color: const Color(0xFF999FAE),
);

final TextStyle normalSTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize14,
  color: const Color(0xFF999FAE),
);

final TextStyle smallTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w300,
  fontSize: fsize12,
  color: const Color(0xFF1785C1),
);

final TextStyle mediumNormalTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize16,
  color: textColorDark,
);

final TextStyle smallSemiTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize12,
  color: const Color(0xFF00344F),
);

final TextStyle controlButtonTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w600,
  fontSize: fsize16,
  color: Colors.white,
);

final TextStyle sliderTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w700,
  letterSpacing: 0.25,
  fontSize: fsize16,
  color: const Color(0xFF00344F),
);

final TextStyle sliderSmallTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  letterSpacing: 0.25,
  fontSize: fsize10,
  color: const Color(0xFF00344F),
);

final TextStyle iconSmallTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  letterSpacing: 0.25,
  fontSize: fsize8,
  color: const Color(0xFF00344F),
);

final TextStyle sliderBoldTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w700,
  fontSize: fsize12,
  color: const Color(0xFF00344F),
);

final TextStyle questionTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w400,
  fontSize: fsize24,
  color: const Color(0xFF00344F),
);

final TextStyle choiceButnTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize16,
  color: const Color(0xFF1785C1),
);

final TextStyle dragButnTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize16,
  color: const Color(0xFF00344F),
);

final TextStyle faintTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize16,
  color: textColorFaint,
);

final TextStyle selButnTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize16,
  color: Colors.white,
);

final TextStyle incorrTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize16,
  color: const Color(0xFFF76F71),
);

final TextStyle resTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize12,
  color: const Color(0xFF999FAE),
);

final TextStyle bannerTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w700,
  fontSize: fsize24,
  color: Colors.white,
);

final TextStyle corrTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w500,
  fontSize: fsize16,
  color: const Color(0xFF4DC591),
);

final TextStyle complTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w900,
  fontSize: fsize20,
  color: const Color(0xFF1785C1),
);

final TextStyle yourScoreStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w700,
  fontSize: fsize12,
  color: const Color(0xFF4DC591),
);

final TextStyle topicTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w700,
  fontSize: fsize22,
  color: Colors.white,
);

final TextStyle viewMoreStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w700,
  decoration: TextDecoration.underline,
  fontSize: fsize12,
  color: const Color(0xFF999FAE),
);

final TextStyle legendStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: w700,
  fontSize: fsize12,
  color: Colors.black,
);

final Map<String, TextStyle> textStyle = {
  "AppBarTextStyle": appBarTextStyle,
  "BannerTxtStyle": bannerTxtStyle,
  "CaptionTextStyle": captionTextStyle,
  "ChoiceButnTxtStyle": choiceButnTxtStyle,
  "ControlButtonTextStyle": controlButtonTextStyle,
  "CorrTxtStyle": corrTxtStyle,
  "DragButnTxtStyle": dragButnTxtStyle,
  "IncorrTxtStyle": incorrTxtStyle,
  "MediumNormalTextStyle": mediumNormalTextStyle,
  "QuestionTextStyle": questionTextStyle,
  "ResTxtStyle": resTxtStyle,
  "SelButnTxtStyle": selButnTxtStyle,
  "SliderBoldTextStyle": sliderBoldTextStyle,
  "SliderSmallTextStyle": sliderSmallTextStyle,
  "SliderTextStyle": sliderTextStyle,
  "SmallSemiTextStyle": smallSemiTextStyle,
  "SmallTextStyle": smallTextStyle,
  "SubTitleTextStyle": subTitleTextStyle,
  "TopicTxtStyle": topicTxtStyle,
  "TitleTextStyle": titleTextStyle,
  "ViewMoreStyle": viewMoreStyle,
};
