import 'package:flutter/material.dart';

class ChessBoardColorStyle {
  final Color backgroundColor;
  final Color fieldColor1, fieldColor2, selectedFieldColor;
  final Color? inactiveBaseTextColor, inactiveAccentTextColor;

  const ChessBoardColorStyle({
    this.backgroundColor = Colors.grey,
    this.fieldColor1 = Colors.black,
    this.fieldColor2 = Colors.white,
    this.selectedFieldColor = const Color(0x6F69F0AE),
    this.inactiveBaseTextColor,
    this.inactiveAccentTextColor,
  });
}
