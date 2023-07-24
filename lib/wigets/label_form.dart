import 'package:flutter/material.dart';

class LabelForm extends StatelessWidget {
  final String label;
  final bool isRequired;
  final double fontSize;

  const LabelForm({
    Key? key,
    required this.label,
    this.isRequired = false,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Visibility(
          visible: isRequired,
          child: Text('*', style: TextStyle(color: Colors.red, fontSize: (fontSize + 2), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
