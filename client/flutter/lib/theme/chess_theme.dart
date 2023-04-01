import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

const baseColors = DirectionalTuple(
  NordColors.$9,
  NordColors.$13,
  NordColors.$14,
  NordColors.$15,
  Colors.grey,
);

final accentColors = baseColors.map(
  (color) => Color.lerp(Colors.black, color, 0.6)!,
).copyWith(inactive: Colors.grey.shade600);

final playerStyles = WikiPiecesPlayerStyles(
  accentColors: accentColors,
  baseColors: baseColors,
);
