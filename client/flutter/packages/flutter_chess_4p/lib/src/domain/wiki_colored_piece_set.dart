import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

import 'directional_tuple.dart';
import 'piece_set.dart';

class WikiColoredPieceSet extends PieceSet {
  static const DirectionalTuple<Color> _defaultStrokeColor =
      DirectionalTuple.all(Colors.black);
  static const DirectionalTuple<Color> _defaultFillColor = DirectionalTuple(
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.red,
  );

  // static const DirectionalTuple<double> _defaultStrokeWidth =
  //     DirectionalTuple.all(4);

  final Map<PieceType, DirectionalTuple<Widget>> _pieces;

  WikiColoredPieceSet({
    DirectionalTuple<Color> strokeColor = _defaultStrokeColor,
    DirectionalTuple<Color> fillColor = _defaultFillColor,
  }) : _pieces = _pieceMapFrom(
          strokeColor,
          fillColor,
        );

  @override
  Widget createPiece(PieceType pieceType, Direction direction) {
    return _pieces[pieceType]!.get(direction);
  }

  static Map<PieceType, DirectionalTuple<Widget>> _pieceMapFrom(
    DirectionalTuple<Color> strokeColor,
    DirectionalTuple<Color> fillColor,
  ) {
    final pieceMap = <PieceType, DirectionalTuple<Widget>>{};
    for (final pieceType in PieceType.values) {
      pieceMap[pieceType] = DirectionalTuple(
        _createPiece(pieceType, strokeColor.up, fillColor.up),
        _createPiece(pieceType, strokeColor.right, fillColor.right),
        _createPiece(pieceType, strokeColor.down, fillColor.down),
        _createPiece(pieceType, strokeColor.left, fillColor.left),
      );
    }
    return pieceMap;
  }

  static Widget _createPiece(
    PieceType pieceType,
    Color strokeColor,
    Color fillColor,
  ) {
    late final Widget widget;
    switch (pieceType) {
      case PieceType.king:
        widget = WhiteKing(fillColor: fillColor, strokeColor: strokeColor);
        break;
      case PieceType.queen:
        widget = WhiteQueen(fillColor: fillColor, strokeColor: strokeColor);
        break;
      case PieceType.rook:
        widget = WhiteRook(fillColor: fillColor, strokeColor: strokeColor);
        break;
      case PieceType.bishop:
        widget = WhiteBishop(fillColor: fillColor, strokeColor: strokeColor);
        break;
      case PieceType.knight:
        widget = WhiteKnight(fillColor: fillColor, strokeColor: strokeColor);
        break;
      default:
        widget = WhitePawn(fillColor: fillColor, strokeColor: strokeColor);
        break;
    }
    return SizedBox(
      key: UniqueKey(),
      child: widget,
    );
  }
}
