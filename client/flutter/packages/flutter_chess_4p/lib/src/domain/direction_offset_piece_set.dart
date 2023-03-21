import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';
import './piece_set.dart';

class DirectionOffsetPieceSet extends PieceSet {
  final PieceSet baseSet;
  final int offset;

  DirectionOffsetPieceSet({required this.baseSet, required this.offset})
      : assert(offset >= 0 && offset <= 3);

  @override
  Widget createPiece(
    PieceType pieceType,
    Direction? direction,
  ) =>
      baseSet.createPiece(
        pieceType,
        direction == null
            ? null
            : Direction.fromInt(direction.clockwiseRotationsFromUp + offset),
      );
}
