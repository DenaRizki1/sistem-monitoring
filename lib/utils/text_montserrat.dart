import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextMontserrat extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool bold;
  final int maxLines;
  final Color color;
  final TextAlign textAlign;

  const TextMontserrat({
    Key? key,
    required this.text,
    required this.fontSize,
    this.bold = false,
    this.color = Colors.white,
    this.textAlign = TextAlign.start,
    this.maxLines = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.montserrat(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : null,
      ),
    );
  }
}
