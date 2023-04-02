import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

final baseColors = DirectionalTuple(
  NordColors.$9,
  NordColors.$13,
  NordColors.$14,
  NordColors.$15,
  Color.lerp(NordColors.$2, NordColors.$0, 0.6)!
);

final accentColors = baseColors.map(
  (color) => Color.lerp(Colors.black, color, 0.65)!,
).copyWith(inactive: Color.lerp(Colors.black, NordColors.$1, 0.75)!);

final playerStyles = WikiPiecesPlayerStyles(
  accentColors: accentColors,
  baseColors: baseColors,
);

final chessStyle = ChessBoardColorStyle(
  backgroundColor: Colors.transparent,
  fieldColor1: NordColors.$1,
  fieldColor2: NordColors.$0,
  selectedFieldColor: NordColors.$3,
  inactiveAccentTextColor: NordColors.$0,
  inactiveBaseTextColor: NordColors.$1.withAlpha(200),
);
