import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextWidget extends StatefulWidget {
  const TextWidget(
      {super.key,
      required this.text,
      required this.fontSize,
      required this.defaultVariation});

  final String text;
  final double fontSize;
  final int defaultVariation;

  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  int _tapCount = 0;
  final EdgeInsets _padding = const EdgeInsets.fromLTRB(12, 16, 12, 12);

  List<Widget> _variations = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _variations = [whiteNoBg(), blackNoBg(), whiteBg(), blackBg()];
      _tapCount = widget.defaultVariation;
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
    return Text(widget.text,
        style: GoogleFonts.oswald(
            fontWeight: FontWeight.w700,
            fontSize: widget.fontSize,
            color: Colors.white,
            height: 1));
  }

  Widget blackNoBg() {
    return Text(widget.text,
        style: GoogleFonts.oswald(
            fontWeight: FontWeight.w700,
            fontSize: widget.fontSize,
            color: Colors.black,
            height: 1));
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
