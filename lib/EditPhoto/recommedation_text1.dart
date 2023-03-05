import 'package:app/EditPhoto/text_widget.dart';
import 'package:app/EditPhoto/text_widget_icon.dart';
import 'package:flutter/cupertino.dart';

class RecommendationText1 extends StatelessWidget {
  const RecommendationText1(
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
              text: 'Enjoy Outdoor Activity',
              fontSize: 32,
              iconFilePath: 'assets/icons/outdoor_exercise.svg',
              defaultVariation: defaultVariation,
            )
          : TextWidget(
              text: 'Enjoy Outdoor Activity',
              fontSize: 32,
              defaultVariation: defaultVariation);
    } else {
      return iconOrNoIcon
          ? TextWidgetIcon(
              text: 'Wear Mask Outdoor',
              fontSize: 32,
              iconFilePath: 'assets/icons/uis_head-side-mask.svg',
              defaultVariation: defaultVariation,
            )
          : TextWidget(
              text: 'Wear Mask Outdoor',
              fontSize: 32,
              defaultVariation: defaultVariation);
    }
  }
}
