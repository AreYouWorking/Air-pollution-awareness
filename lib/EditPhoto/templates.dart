import 'dart:ui';

import 'package:app/EditPhoto/recommendation_text1.dart';
import 'package:app/EditPhoto/recommendation_text2.dart';
import 'package:app/EditPhoto/text_widget_icon.dart';
import 'package:flutter/cupertino.dart';

import 'PhotoEditor.dart';
import 'aqi_widget.dart';
import 'aqi_widget_emoji.dart';

enum WidgetVariation { whiteNoBg, blackNoBg, whiteBg, blackBg }

Offset alignTopLeft(
    double leftOffsetPx, double topOffsetPx, Size containerSize) {
  double dx = leftOffsetPx / containerSize.width;
  double dy = topOffsetPx / containerSize.height;
  return Offset(dx, dy);
}

Offset alignTopRight(double rightOffsetPx, double topOffsetPx,
    double widgetWidth, Size containerSize) {
  double dx =
      (containerSize.width - widgetWidth - rightOffsetPx) / containerSize.width;
  double dy = topOffsetPx / containerSize.height;
  return Offset(dx, dy);
}

Offset alignBottomLeft(
    double leftOffsetPx, double bottomOffsetPx, Size containerSize) {
  double dx = leftOffsetPx / containerSize.width;
  double dy = (containerSize.height - bottomOffsetPx) / containerSize.height;
  return Offset(dx, dy);
}

Offset alignBottomRight(double rightOffsetPx, double bottomOffsetPx,
    double widgetWidth, Size containerSize) {
  double dx =
      (containerSize.width - widgetWidth - rightOffsetPx) / containerSize.width;
  double dy = (containerSize.height - bottomOffsetPx) / containerSize.height;
  return Offset(dx, dy);
}

Offset alignTopCenter(
    double topOffsetPx, double widgetWidth, Size containerSize) {
  double dx =
      ((containerSize.width / 2.0) - (widgetWidth / 2.0)) / containerSize.width;
  double dy = topOffsetPx / containerSize.height;
  return Offset(dx, dy);
}

Offset alignBottomCenter(
    double bottomOffsetPx, double widgetWidth, Size containerSize) {
  double dx =
      ((containerSize.width / 2.0) - (widgetWidth / 2.0)) / containerSize.width;
  double dy = (containerSize.height - bottomOffsetPx) / containerSize.height;
  return Offset(dx, dy);
}

List<List<OverlaidWidget>> buildTemplates(
    int aqi, String location, Size editingAreaSize) {
  AqiWidgetEmoji aqiWhiteNoBgEmoji = AqiWidgetEmoji(
    aqi: aqi,
    defaultVariation: WidgetVariation.whiteNoBg,
  );

  AqiWidgetEmoji aqiBlackNoBgEmoji = AqiWidgetEmoji(
    aqi: aqi,
    defaultVariation: WidgetVariation.blackNoBg,
  );

  AqiWidget aqiBlackNoBg = AqiWidget(
    aqi: aqi,
    fontSize: 64,
    defaultVariation: WidgetVariation.blackNoBg,
  );

  AqiWidget aqiBlackNoBgSmall = AqiWidget(
    aqi: aqi,
    fontSize: 56,
    defaultVariation: WidgetVariation.blackNoBg,
  );

  RecommendationText1 recommendText1WhiteNoBgIcon = RecommendationText1(
    aqi: aqi,
    fontSize: 32,
    defaultVariation: WidgetVariation.whiteNoBg,
    iconOrNoIcon: true,
  );

  RecommendationText2 recommendText2WhiteNoBgIcon = RecommendationText2(
    aqi: aqi,
    fontSize: 32,
    defaultVariation: WidgetVariation.whiteNoBg,
    iconOrNoIcon: true,
  );

  RecommendationText1 recommendText1BlackNoBgNoIconSmall = RecommendationText1(
    aqi: aqi,
    fontSize: 22,
    defaultVariation: WidgetVariation.blackNoBg,
    iconOrNoIcon: false,
  );

  RecommendationText2 recommendText2BlackNoBgNoIconSmall = RecommendationText2(
    aqi: aqi,
    fontSize: 22,
    defaultVariation: WidgetVariation.blackNoBg,
    iconOrNoIcon: false,
  );

  RecommendationText1 recommendText1BlackNoBg = RecommendationText1(
    aqi: aqi,
    fontSize: 32,
    defaultVariation: WidgetVariation.blackNoBg,
    iconOrNoIcon: false,
  );

  RecommendationText2 recommendText2BlackNoBg = RecommendationText2(
    aqi: aqi,
    fontSize: 32,
    defaultVariation: WidgetVariation.blackNoBg,
    iconOrNoIcon: false,
  );

  TextWidgetIcon locationWhite = TextWidgetIcon(
      text: location,
      fontSize: 20,
      iconFilePath: 'assets/icons/near_me_FILL1_wght400_GRAD0_opsz48.svg',
      defaultVariation: WidgetVariation.whiteNoBg);

  TextWidgetIcon locationBlack = TextWidgetIcon(
      text: location,
      fontSize: 20,
      iconFilePath: 'assets/icons/near_me_FILL1_wght400_GRAD0_opsz48.svg',
      defaultVariation: WidgetVariation.blackNoBg);

  return [
    [
      // template1
      OverlaidWidget()
        ..widget = locationWhite
        ..position = alignTopRight(
            20, 20, locationWhite.textSize().width + 40, editingAreaSize),
      OverlaidWidget()
        ..widget = aqiWhiteNoBgEmoji
        ..position = alignBottomLeft(20, 200, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText1WhiteNoBgIcon
        ..position = alignBottomLeft(20, 100, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText2WhiteNoBgIcon
        ..position = alignBottomLeft(20, 50, editingAreaSize),
    ],
    [
      // template2
      OverlaidWidget()
        ..widget = locationWhite
        ..position = alignTopRight(
            20, 20, locationWhite.textSize().width + 40, editingAreaSize),
      OverlaidWidget()
        ..widget = aqiWhiteNoBgEmoji
        ..position = alignTopLeft(20, 70, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText1WhiteNoBgIcon
        ..position = alignTopLeft(20, 170, editingAreaSize),

      OverlaidWidget()
        ..widget = recommendText2WhiteNoBgIcon
        ..position = alignTopLeft(20, 220, editingAreaSize),
    ],
    [
      // template3
      OverlaidWidget()
        ..widget = locationBlack
        ..position = alignTopRight(
            20, 20, locationBlack.textSize().width + 40, editingAreaSize),
      OverlaidWidget()
        ..widget = aqiBlackNoBgSmall
        ..position = alignBottomLeft(10, 100, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText1BlackNoBgNoIconSmall
        ..position = alignBottomLeft(
            aqiBlackNoBgSmall.textSize().width + 20, 100, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText2BlackNoBgNoIconSmall
        ..position = alignBottomLeft(
            aqiBlackNoBgSmall.textSize().width + 20, 70, editingAreaSize),
    ],
    [
      //   // TODO: template4
    ],
    [
      // template5
      OverlaidWidget()
        ..widget = aqiBlackNoBgSmall
        ..position = alignTopLeft(10, 50, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText1BlackNoBgNoIconSmall
        ..position = alignTopLeft(
            aqiBlackNoBgSmall.textSize().width + 20, 50, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText2BlackNoBgNoIconSmall
        ..position = alignTopLeft(
            aqiBlackNoBgSmall.textSize().width + 20, 80, editingAreaSize),
      OverlaidWidget()
        ..widget = locationBlack
        ..position = alignBottomRight(
            20, 40, locationBlack.textSize().width + 40, editingAreaSize),
    ],
    [
      // template6
      OverlaidWidget()
        ..widget = aqiBlackNoBgSmall
        ..position = alignTopCenter(
            50, aqiBlackNoBgSmall.textSize().width, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText1BlackNoBg
        ..position = alignTopCenter(
            120, recommendText1BlackNoBg.textSize().width, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText2BlackNoBg
        ..position = alignTopCenter(
            170, recommendText2BlackNoBg.textSize().width, editingAreaSize),
      OverlaidWidget()
        ..widget = locationBlack
        ..position = alignBottomRight(
            20, 40, locationBlack.textSize().width + 40, editingAreaSize),
    ],
    [
      // template7
      OverlaidWidget()
        ..widget = locationBlack
        ..position = alignTopRight(
            20, 20, locationBlack.textSize().width + 40, editingAreaSize),
      OverlaidWidget()
        ..widget = aqiBlackNoBg
        ..position = alignBottomCenter(
            200, aqiBlackNoBg.textSize().width, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText1BlackNoBg
        ..position = alignBottomCenter(
            100, recommendText1BlackNoBg.textSize().width, editingAreaSize),
      OverlaidWidget()
        ..widget = recommendText2BlackNoBg
        ..position = alignBottomCenter(
            50, recommendText2BlackNoBg.textSize().width, editingAreaSize),
    ],
    [
      // template8
      OverlaidWidget()
        ..widget = locationBlack
        ..position = alignTopRight(
            20, 20, locationBlack.textSize().width + 40, editingAreaSize),
      OverlaidWidget()
        ..widget = aqiBlackNoBgEmoji
        ..position = alignBottomLeft(20, 100, editingAreaSize),
    ],
    [
      // TODO: template9
    ],
  ];
}
