import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';

abstract class PieceSet {
  Widget createPiece(
    PieceType pieceType,
    Direction? direction,
  );
}
