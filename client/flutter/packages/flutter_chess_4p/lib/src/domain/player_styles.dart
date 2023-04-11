import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';

abstract class PlayerStyles {
  Color getPlayerColor(Direction? playerDirection);

  Color getPlayerAccentColor(Direction? playerDirection);

  Widget createPiece(
    PieceType pieceType,
    Direction? direction,
  );
}
