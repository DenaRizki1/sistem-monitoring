import 'package:flutter/material.dart';

Color getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
  return Colors.white;
}

Color colorBackground = getColorFromHex("#f3f5fa");
Color colorInfo = getColorFromHex("#fff4d4");
Color colorButtonRed = getColorFromHex("#ff6961");

const Map<int, Color> color = {
  50: Color.fromRGBO(0, 0, 0, .0),
  100: Color.fromRGBO(0, 0, 0, .0),
  200: Color.fromRGBO(0, 0, 0, .0),
  300: Color.fromRGBO(0, 0, 0, .0),
  400: Color.fromRGBO(0, 0, 0, .0),
  500: Color.fromRGBO(0, 0, 0, .0),
  600: Color.fromRGBO(0, 0, 0, .0),
  700: Color.fromRGBO(0, 0, 0, .0),
  800: Color.fromRGBO(0, 0, 0, .0),
  900: Color.fromRGBO(0, 0, 0, .0),
};

MaterialColor colorPrimary = const MaterialColor(0xff0077ff, color);
