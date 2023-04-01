import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

import 'directional_tuple.dart';
import 'player_styles.dart';

class WikiPiecesPlayerStyles extends PlayerStyles {
  static const DirectionalTuple<Color> defaultAccentColors =
      DirectionalTuple.all(Colors.black);
  static const DirectionalTuple<Color> defaultBaseColors = DirectionalTuple(
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.red,
    Colors.grey,
  );

  final DirectionalTuple<Color> _playerColors;
  final DirectionalTuple<Color> _playerAccentColors;
  final Map<PieceType, DirectionalTuple<Widget>> _pieces;

  WikiPiecesPlayerStyles({
    DirectionalTuple<Color> baseColors = defaultBaseColors,
    DirectionalTuple<Color> accentColors = defaultAccentColors,
  })  : _pieces = _pieceMapFrom(
          accentColors,
          baseColors,
        ),
        _playerColors = baseColors,
        _playerAccentColors = accentColors;

  @override
  Widget createPiece(PieceType pieceType, Direction? direction) {
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
        _createPiece(pieceType, strokeColor.inactive, fillColor.inactive),
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

  @override
  Color getPlayerColor(Direction? playerDirection) {
    return _playerColors.get(playerDirection);
  }

  @override
  Color getPlayerAccentColor(Direction? playerDirection) {
    return _playerAccentColors.get(playerDirection);
  }
}
