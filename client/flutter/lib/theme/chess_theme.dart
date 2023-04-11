import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

const baseColors = DirectionalTuple(
      NordColors.$9,
      NordColors.$13,
      NordColors.$14,
      NordColors.$15,
      Colors.transparent,
    );

final accentColors = baseColors
    .map(
      (color) => Color.lerp(Colors.black, color, 0.6)!,
    )
    .copyWith(
      inactive: Color.lerp(NordColors.$2, NordColors.snowStorm.darkest, 0.125)!,
    );

final playerStyles = WikiPiecesPlayerStyles(
      accentColors: accentColors,
      baseColors: baseColors,
    );

final inactiveBaseTextColor = Color.lerp(NordColors.$3, Colors.white, 0.08)!;

final chessStyle = ChessBoardColorStyle(
      backgroundColor: Colors.transparent,
      fieldColor1: NordColors.$1,
      fieldColor2: NordColors.$0,
      selectedFieldColor: NordColors.$3,
      inactiveAccentTextColor: Color.lerp(
        Colors.black,
        inactiveBaseTextColor,
        0.65,
      ),
      inactiveBaseTextColor: inactiveBaseTextColor,
    );
