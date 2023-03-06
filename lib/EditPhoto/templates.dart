import 'dart:ui';

import 'package:app/EditPhoto/recommedation_text2.dart';

import 'PhotoEditor.dart';
import 'aqi_widget.dart';
import 'aqi_widget_emoji.dart';

final template1 = [
  OverlaidWidget()
    ..widget = const AqiWidget(
      aqi: 80,
      defaultVariation: 1,
    )
    ..position = Offset(0.1, 0.2),
  OverlaidWidget()
    ..widget = const AqiWidgetEmoji(
      aqi: 80,
      defaultVariation: 1,
    )
    ..position = Offset(0.1, 0.2),
  OverlaidWidget()
    ..widget = const RecommendationText2(
      aqi: 40,
      defaultVariation: 0,
      iconOrNoIcon: true,
    )
    ..position = Offset(0.1, 0.5),
];

final template2 = [
  OverlaidWidget()
    ..widget = const AqiWidget(
      aqi: 80,
      defaultVariation: 1,
    )
    ..position = Offset(0.1, 0.2),
  OverlaidWidget()
    ..widget = const AqiWidgetEmoji(
      aqi: 80,
      defaultVariation: 1,
    )
    ..position = Offset(0.1, 0.2),
  OverlaidWidget()
    ..widget = const RecommendationText2(
      aqi: 40,
      defaultVariation: 0,
      iconOrNoIcon: true,
    )
    ..position = Offset(0.1, 0.5),
];