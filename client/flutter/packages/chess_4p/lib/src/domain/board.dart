import 'package:chess_4p/src/board_handlers/board_serializer.dart';
import 'package:chess_4p/src/domain/default_board.dart';
import 'package:chess_4p/src/domain/direction.dart';
import 'package:chess_4p/src/domain/readable_board.dart';

import 'field.dart';
import 'piece.dart';

/// An editable 14x14 with a 3x3 missing on each corner chess board,
/// for four players.
class Board implements ReadableBoard {
  final List<List<Piece?>> _boardData;

  int _changeIndex = 0;

  /// The changeIndex, after each change this number increases; starts at 0.
  @override
  int get changeIndex => _changeIndex;

  /// Standard constructor for an Empty board.
  Board.empty()
      : _boardData =
            Iterable<List<Piece?>>.generate(14, (i) => List.filled(14, null))
                .toList();

  /// Standard board for four players, with directions.
  Board.standard() : _boardData = genDefaultBoard();

  factory Board.standardWithOmission(
    List<bool> keepRotations,
    [int fromPosition = 0,]
  ) {
    assert(keepRotations.length == 4);

    final board = Board.standard();
    for (var rotation = 0; rotation < 4; rotation++) {
      final actualRotation = rotation - fromPosition;
      if (keepRotations[rotation]) continue;
      for (var x = 3; x <= 10; x++) {
        for (var y = 12; y <= 13; y++) {
          final rotatedX = Field.clockwiseRotateXBy(x, y, actualRotation);
          final rotatedY = Field.clockwiseRotateYBy(x, y, actualRotation);
          board.removePiece(rotatedX, rotatedY);
        }
      }
    }
    return board;
  }

  Board._raw(this._boardData);

  /// Set all pieces with [direction] to dead
  void setInactive(Direction direction) {
    _setDirectionDead(dead: true, direction: direction);
  }

  /// Set all pieces with [direction] to alive
  void setActive(Direction direction) {
    _setDirectionDead(dead: false, direction: direction);
  }

  void _setDirectionDead({required bool dead, required Direction direction}) {
    for (var y = 0; y < 14; y++) {
      for (var x = 0; x < 14; x++) {
        final piece = _boardData[y][x];
        if (piece != null && piece.direction == direction) {
          piece.isDead = dead;
        }
      }
    }
  }

  /// If a coordinate is in the board.
  @override
  bool isOut(int x, int y) {
    if (x < 0 || x >= 14 || y < 0 || y >= 14) {
      return true;
    }
    // corners
    return (x < 3 || x > 10) && (y < 3 || y > 10);
  }

  /// If on a coordinate on the board, there is no piece.
  @override
  bool isEmpty(int x, int y) {
    return _boardData[y][x] == null;
  }

  /// Get the piece of a coordinate, check if there is a piece with [isEmpty].
  @override
  Piece getPiece(int x, int y) {
    return _boardData[y][x]!;
  }

  /// Move a piece from [x] and [y] to [nx] and [ny].
  ///
  /// This requires a piece to be at the coordinate [x] and [y].
  void move(int x, int y, int nx, int ny) {
    Piece? p = _boardData[y][x];
    _boardData[y][x] = null;
    assert(p != null);
    _boardData[ny][nx] = p;
    _changeIndex++;
  }

  /// Write [piece] to [x] and [y], without caring if there is already a piece.
  void overwritePiece(Piece piece, int x, int y) {
    assert(!isOut(x, y));
    _boardData[y][x] = piece;
    _changeIndex++;
  }

  /// Write [piece] to [x] and [y], with checking if there is already a piece.
  /// If there is already a piece, an error is thrown.
  void writePiece(Piece piece, int x, int y) {
    assert(isEmpty(x, y));
    overwritePiece(piece, x, y);
    _changeIndex++;
  }

  /// Remove a piece at [x] and [y]. [x] and [y] is then empty.
  void removePiece(int x, int y) {
    assert(!isOut(x, y));
    assert(!isEmpty(x, y));
    _boardData[y][x] = null;
    _changeIndex++;
  }

  @override
  String toString() {
    return BoardSerializer(board: this).toString();
  }

  Board clone() {
    return Board._raw(
      Iterable<List<Piece?>>.generate(14, (i) => [..._boardData[i]]).toList(),
    );
  }

  void clear() {
    for (var y = 0; y < 14; y++) {
      for (var x = 0; x < 14; x++) {
        _boardData[y][x] = null;
      }
    }
    _changeIndex++;
  }

  void copyFromBoardOnEmpty(Board board) {
    for (var y = 0; y < 14; y++) {
      for (var x = 0; x < 14; x++) {
        if (isEmpty(x, y)) {
          _boardData[y][x] = board._boardData[y][x];
        }
      }
    }
    _changeIndex++;
  }

  void copyBoard(Board board) {
    clear();
    copyFromBoardOnEmpty(board);
  }
}
