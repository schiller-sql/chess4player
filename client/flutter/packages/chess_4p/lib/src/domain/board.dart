import 'package:chess_4p/src/board_handlers/board_serializer.dart';
import 'package:chess_4p/src/domain/default_board.dart';

import 'direction.dart';
import 'piece.dart';

/// An editable 14x14 with a 3x3 missing on each corner chess board,
/// for four players.
class Board {
  final List<List<Piece?>> _boardData;

  int _changeIndex = 0;

  /// The changeIndex, after each change this number increases; starts at 0.
  int get changeIndex => _changeIndex;

  /// Standard constructor for an Empty board.
  Board.empty()
      : _boardData =
            Iterable<List<Piece?>>.generate(14, (i) => List.filled(14, null))
                .toList();

  /// Standard board for four players, with directions.
  Board.standard() : _boardData = genDefaultBoard();

  Board._raw(this._boardData);

  /// If a coordinate is in the board.
  bool isOut(int x, int y) {
    if (x < 0 || x >= 14 || y < 0 || y >= 14) {
      return true;
    }
    // corners
    return (x < 3 || x > 10) && (y < 3 || y > 10);
  }

  /// If on a coordinate on the board, there is no piece.
  bool isEmpty(int x, int y) {
    return _boardData[y][x] == null;
  }

  /// Get the piece of a coordinate, check if there is a piece with [isEmpty].
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
    assert(isEmpty(nx, ny));
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
}
