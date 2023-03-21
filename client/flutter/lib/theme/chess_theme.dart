import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

const pieceColors = DirectionalTuple(
  NordColors.$9,
  NordColors.$13,
  NordColors.$14,
  NordColors.$15,
  Colors.grey,
);

final pieceSet = WikiColoredPieceSet(
  strokeColor:
      DirectionalTuple.all(Color.lerp(NordColors.$3, NordColors.$4, 0.15)!),
  fillColor: pieceColors,
);
