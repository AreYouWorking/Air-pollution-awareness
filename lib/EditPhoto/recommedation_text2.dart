import 'package:app/EditPhoto/text_widget.dart';
import 'package:app/EditPhoto/text_widget_icon.dart';
import 'package:flutter/cupertino.dart';

class RecommendationText2 extends StatelessWidget {
  const RecommendationText2(
      {super.key,
      required this.aqi,
      required this.defaultVariation,
      required this.iconOrNoIcon});

  final int aqi;
  final int defaultVariation;
  final bool iconOrNoIcon;

  @override
  Widget build(BuildContext context) {
    return _getTextBasedOnAqi(aqi);
  }

  Widget _getTextBasedOnAqi(int aqi) {
    if (aqi <= 50) {
      return iconOrNoIcon
          ? TextWidgetIcon(
              text: 'Fresh air',
              fontSize: 32,
              iconFilePath: 'assets/icons/air-rounded.svg',
              defaultVariation: defaultVariation,
            )
          : TextWidget(
              text: 'Fresh Air',
              fontSize: 32,
              defaultVariation: defaultVariation);
    } else {
      return iconOrNoIcon
          ? TextWidgetIcon(
              text: 'Avoid Outdoor Exercise',
              fontSize: 32,
              iconFilePath: 'assets/icons/material-symbols_exercise.svg',
              defaultVariation: defaultVariation,
            )
          : TextWidget(
              text: 'Avoid Outdoor Exercise',
              fontSize: 32,
              defaultVariation: defaultVariation);
    }
  }
}
