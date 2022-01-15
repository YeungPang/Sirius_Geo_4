import 'package:flutter/material.dart';

const largeTextSize = 22.0;
const mediumTextSize = 16.0;
const smallTextSize = 12.0;

const Color textColorDark = Colors.black;
const Color textColorLight = Colors.white;
const Color textColorAccent = Colors.red;
const Color textColorFaint = Color.fromRGBO(125, 125, 125, 1.0);
const Color blueGrey = Colors.blueGrey;

const defaultPaddingHorizontal = 12.0;

const String fontNameAN = 'Lato';

const appBarTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w300,
  fontSize: mediumTextSize,
  color: Colors.white,
);

const titleTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w300,
  fontSize: largeTextSize,
  color: textColorDark,
);

const subTitleTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w300,
  fontSize: mediumTextSize,
  color: textColorAccent,
);

const captionTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w300,
  fontSize: smallTextSize,
  color: textColorDark,
);

const normalTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: mediumTextSize,
  color: Color(0xFF999FAE),
);

const normalSTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: 14,
  color: Color(0xFF999FAE),
);

const smallTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w300,
  fontSize: 12,
  color: Color(0xFF1785C1),
);

const mediumNormalTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: mediumTextSize,
  color: textColorDark,
);

const smallSemiTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: 12,
  color: Color(0xFF00344F),
);

const controlButtonTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w600,
  fontSize: mediumTextSize,
  color: Colors.white,
);

const sliderTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.25,
  fontSize: 16,
  color: Color(0xFF00344F),
);

const sliderSmallTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.25,
  fontSize: 10,
  color: Color(0xFF00344F),
);

const sliderBoldTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w700,
  fontSize: 12,
  color: Color(0xFF00344F),
);

const questionTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w400,
  fontSize: 24,
  color: Color(0xFF00344F),
);

const choiceButnTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: mediumTextSize,
  color: Color(0xFF1785C1),
);

const dragButnTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: mediumTextSize,
  color: Color(0xFF00344F),
);

const selButnTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: mediumTextSize,
  color: Colors.white,
);

const incorrTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: mediumTextSize,
  color: Color(0xFFF76F71),
);

const resTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: 12.0,
  color: Color(0xFF999FAE),
);

const bannerTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w700,
  fontSize: 24.0,
  color: Colors.white,
);

const corrTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w500,
  fontSize: mediumTextSize,
  color: Color(0xFF4DC591),
);

const complTextStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w900,
  fontSize: 20,
  color: Color(0xFF1785C1),
);

const yourScoreStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w700,
  fontSize: 12,
  color: Color(0xFF4DC591),
);

const topicTxtStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w700,
  fontSize: largeTextSize,
  color: Colors.white,
);

const viewMoreStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w700,
  decoration: TextDecoration.underline,
  fontSize: smallTextSize,
  color: Color(0xFF999FAE),
);

const legendStyle = TextStyle(
  fontFamily: fontNameAN,
  fontWeight: FontWeight.w700,
  fontSize: smallTextSize,
  color: Colors.black,
);

const Map<String, TextStyle> textStyle = {
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
  "TitleTextStyle": titleTextStyle,
  "ViewMoreStyle": viewMoreStyle,
};
