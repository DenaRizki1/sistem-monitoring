import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LabelForm extends StatelessWidget {
  final String label;
  final bool isRequired;
  final double fontSize;

  const LabelForm({
    Key? key,
    required this.label,
    this.isRequired = false,
    this.fontSize = 11,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: fontSize, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Visibility(
          visible: isRequired,
          child: Text('*', style: GoogleFonts.montserrat(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
