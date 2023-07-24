import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

class TextMontserrat extends StatelessWidget {
  String text;
  double fontSize;
  bool bold;
  int maxLines;
  Color color;
  TextAlign textAlign;
  TextMontserrat({
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
