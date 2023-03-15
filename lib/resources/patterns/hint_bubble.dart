import 'package:flutter/material.dart';
import '../../builder/pattern.dart';
import '../../model/locator.dart';
import '../../builder/get_pattern.dart';
import '../basic_resources.dart';
import '../fonts.dart';
import '../s_g_icons.dart';

ProcessPattern getHintBubble(Map<String, dynamic> map) {
  Map<String, dynamic> imap = {
    "_height": map["_bubbleSize"],
    "_name": map["_assetName"],
    "_boxFit": BoxFit.cover
  };
  Function pf = getPrimePattern["ImageAsset"]!;
  map["_bubbleArrow"] = pf(imap);
  List<dynamic> hintBox = [
    getHintBanner(map),
    getHints(map["_hint"]),
    getPrevNext(map),
  ];
  map["_bubbleBox"] = hintBox;
  pf = getPrimePattern["Bubble"]!;
  return pf(map);
}

Widget getHints(String hints) {
  return Expanded(
      child: Container(
    alignment: const Alignment(-0.8, 0.0),
    child: Text(
      hints,
      style: corrTxtStyle,
    ),
  ));
}

Widget getHintBanner(Map<String, dynamic> map) {
  double boxWidth = map["_boxWidth"];
  return Container(
      height: map["_bannerHeight"],
      width: boxWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorMap["correct"]!, colorMap["correctGradEnd"]!]),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(size10),
          topLeft: Radius.circular(size10),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 7,
          ),
          Expanded(
            child: Text(
              map["_hintText"],
              style: selButnTxtStyle,
            ),
          ),
          GestureDetector(
            onTap: () {
              model.appActions.doFunction("mvc", [map["_onCancel"]], map);
            },
            child: Row(
              children: [
                const Text('   '),
                Icon(
                  SGIcons.cancel,
                  size: 16 * sizeScale,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(
            width: size10,
          ),
        ],
      ));
}

Widget getPrevNext(Map<String, dynamic> map) {
  bool hasPrev = map["_hasPrev"];
  bool last = map["_last"];
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      height: map["_bannerHeight"],
      width: map["_boxWidth"],
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: const Alignment(-0.6, 0.0),
            child: !hasPrev
                ? const Text('  ')
                : GestureDetector(
                    onTap: () {
                      model.appActions.doFunction("mvc", [map["_onPrev"]], map);
                    },
                    child: Row(
                      children: [
                        space5,
                        Icon(
                          Icons.arrow_back_ios,
                          size: 16 * sizeScale,
                          color: const Color(0xFFBDBDBD),
                        ),
                        Text(
                          map["_prevHint"],
                          style: dragButnTxtStyle,
                        ),
                      ],
                    ),
                  ),
          ),
          Align(
              alignment: const Alignment(0.6, 0.0),
              child: last
                  ? /* GestureDetector(
                      onTap: () {
                        model.appActions
                            .doFunction("mvc", [map["_onTryTeachMode"]], map);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.all(
                            Radius.circular(size10),
                          ),
                          border: Border.all(
                            color: colorMap["btnBlue"]!,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            map["_tryTeachMode"],
                            style: choiceButnTxtStyle,
                          ),
                        ),
                      ),
                    ) */
                  SizedBox(width: size10)
                  : GestureDetector(
                      onTap: () {
                        model.appActions
                            .doFunction("mvc", [map["_onNext"]], map);
                      },
                      child: Row(
                        children: [
                          Text(
                            map["_nextHint"],
                            style: faintTxtStyle,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16 * sizeScale,
                            color: const Color(0xFFBDBDBD),
                          ),
                          space5
                        ],
                      ),
                    )),
        ],
      ),
    ),
  );
}
