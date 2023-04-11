import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';
import './player_styles.dart';

class DirectionOffsetPlayerStyles extends PlayerStyles {
  final PlayerStyles baseSet;
  final int offset;

  DirectionOffsetPlayerStyles({required this.baseSet, required this.offset})
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

  @override
  Color getPlayerColor(Direction? playerDirection) {
    if(playerDirection == null) {
      return baseSet.getPlayerColor(null);
    }
    playerDirection = Direction.fromInt(
      playerDirection.clockwiseRotationsFromUp + offset,
    );
    return baseSet.getPlayerColor(playerDirection);
  }

  @override
  Color getPlayerAccentColor(Direction? playerDirection) {
    if(playerDirection == null) {
      return baseSet.getPlayerAccentColor(null);
    }
    playerDirection = Direction.fromInt(
      playerDirection.clockwiseRotationsFromUp + offset,
    );
    return baseSet.getPlayerAccentColor(playerDirection);
  }
}
