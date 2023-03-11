import 'package:app/EditPhoto/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TextWidgetIcon extends StatefulWidget {
  const TextWidgetIcon(
      {super.key,
      required this.text,
      required this.fontSize,
      required this.iconFilePath,
      required this.defaultVariation});

  final String text;
  final double fontSize;
  final String iconFilePath;
  final WidgetVariation defaultVariation;

  Size textSize() {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: GoogleFonts.oswald(
                fontWeight: FontWeight.w700, fontSize: fontSize, height: 1)),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  State<TextWidgetIcon> createState() => _TextWidgetIconState();
}

class _TextWidgetIconState extends State<TextWidgetIcon> {
  int _tapCount = 0;
  final EdgeInsets _padding = const EdgeInsets.fromLTRB(12, 16, 12, 12);

  List<Widget> _variations = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _variations = [whiteNoBg(), blackNoBg(), whiteBg(), blackBg()];
      _tapCount = widget.defaultVariation.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _tapCount = (_tapCount + 1) % _variations.length;
        });
      },
      child: _variations[_tapCount],
    );
  }

  Widget whiteNoBg() {
    return RichText(
        text: TextSpan(
      children: [
        WidgetSpan(
            child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ColorFiltered(
            colorFilter:
                const ColorFilter.mode(Colors.white, BlendMode.modulate),
            child: SvgPicture.asset(
              widget.iconFilePath,
              width: widget.fontSize,
              height: widget.fontSize,
            ),
          ),
        )),
        TextSpan(
            text: widget.text,
            style: GoogleFonts.oswald(
              fontWeight: FontWeight.w700,
              fontSize: widget.fontSize,
              color: Colors.white,
              height: 1,
            ))
      ],
    ));
  }

  Widget blackNoBg() {
    return RichText(
        text: TextSpan(
      children: [
        WidgetSpan(
            child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ColorFiltered(
            colorFilter:
                const ColorFilter.mode(Colors.black, BlendMode.modulate),
            child: SvgPicture.asset(
              widget.iconFilePath,
              width: widget.fontSize,
              height: widget.fontSize,
            ),
          ),
        )),
        TextSpan(
            text: widget.text,
            style: GoogleFonts.oswald(
              fontWeight: FontWeight.w700,
              fontSize: widget.fontSize,
              color: Colors.black,
              height: 1,
            ))
      ],
    ));
  }

  Widget whiteBg() {
    return Container(
        padding: _padding,
        decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            borderRadius: BorderRadius.circular(15.0)),
        child: whiteNoBg());
  }

  Widget blackBg() {
    return Container(
        padding: _padding,
        decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.5),
            borderRadius: BorderRadius.circular(15.0)),
        child: blackNoBg());
  }
}
