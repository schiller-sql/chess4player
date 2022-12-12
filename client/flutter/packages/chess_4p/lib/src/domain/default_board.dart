import 'package:chess_4p/src/domain/direction.dart';
import 'package:chess_4p/src/domain/piece_type.dart';

import 'piece.dart';

/// up
get k0 => Piece(direction: Direction.up, type: PieceType.king);

get q0 => Piece(direction: Direction.up, type: PieceType.queen);

get r0 => Piece(direction: Direction.up, type: PieceType.rook);

get b0 => Piece(direction: Direction.up, type: PieceType.bishop);

get n0 => Piece(direction: Direction.up, type: PieceType.knight);

get p0 => Piece(direction: Direction.up, type: PieceType.pawn);

/// right
get k1 => Piece(direction: Direction.right, type: PieceType.king);

get q1 => Piece(direction: Direction.right, type: PieceType.queen);

get r1 => Piece(direction: Direction.right, type: PieceType.rook);

get b1 => Piece(direction: Direction.right, type: PieceType.bishop);

get n1 => Piece(direction: Direction.right, type: PieceType.knight);

get p1 => Piece(direction: Direction.right, type: PieceType.pawn);

/// down
get k2 => Piece(direction: Direction.down, type: PieceType.king);

get q2 => Piece(direction: Direction.down, type: PieceType.queen);

get r2 => Piece(direction: Direction.down, type: PieceType.rook);

get b2 => Piece(direction: Direction.down, type: PieceType.bishop);

get n2 => Piece(direction: Direction.down, type: PieceType.knight);

get p2 => Piece(direction: Direction.down, type: PieceType.pawn);

/// left
get k3 => Piece(direction: Direction.left, type: PieceType.king);

get q3 => Piece(direction: Direction.left, type: PieceType.queen);

get r3 => Piece(direction: Direction.left, type: PieceType.rook);

get b3 => Piece(direction: Direction.left, type: PieceType.bishop);

get n3 => Piece(direction: Direction.left, type: PieceType.knight);

get p3 => Piece(direction: Direction.left, type: PieceType.pawn);

// ignore: constant_identifier_names
const __ = null;

List<List<Piece?>> genDefaultBoard() => [
      [__, __, __, r2, n2, b2, k2, q2, b2, n2, r2, __, __, __],
      [__, __, __, p2, p2, p2, p2, p2, p2, p2, p2, __, __, __],
      [__, __, __, __, __, __, __, __, __, __, __, __, __, __],
      [r1, p1, __, __, __, __, __, __, __, __, __, __, p3, r3],
      [n1, p1, __, __, __, __, __, __, __, __, __, __, p3, n3],
      [b1, p1, __, __, __, __, __, __, __, __, __, __, p3, b3],
      [q1, p1, __, __, __, __, __, __, __, __, __, __, p3, k3],
      [k1, p1, __, __, __, __, __, __, __, __, __, __, p3, q3],
      [b1, p1, __, __, __, __, __, __, __, __, __, __, p3, b3],
      [n1, p1, __, __, __, __, __, __, __, __, __, __, p3, n3],
      [r1, p1, __, __, __, __, __, __, __, __, __, __, p3, r3],
      [__, __, __, __, __, __, __, __, __, __, __, __, __, __],
      [__, __, __, p0, p0, p0, p0, p0, p0, p0, p0, __, __, __],
      [__, __, __, r0, n0, b0, q0, k0, b0, n0, r0, __, __, __],
    ];
