import 'package:chess_4p/src/board/default_board.dart';

import '../direction.dart';
import '../pieces/piece.dart';

/// unten ist 0 link daneben 1, oben 2, rechts 3
class Board {
  final List<List<Piece?>> _boardData;
  int _changeIndex = 0;

  int get changeIndex => _changeIndex;

  Board.empty()
      : _boardData =
            Iterable<List<Piece?>>.generate(14, (i) => List.filled(14, null))
                .toList();

  Board.standard() : _boardData = genDefaultBoard();

  Board._raw(this._boardData);

  bool isOut(int x, int y) {
    if (x < 0 || x >= 14 || y < 0 || y >= 14) {
      return true;
    }
    // corners
    return (x < 3 || x > 10) && (y < 3 || y > 10);
  }

  bool isEmpty(int x, int y) {
    return _boardData[y][x] == null;
  }

  Piece getPiece(int x, int y) {
    return _boardData[y][x]!;
  }

  void move(int x, int y, int nx, int ny) {
    Piece? p = _boardData[y].removeAt(x);
    assert(p != null);
    assert(isEmpty(nx, ny));
    _boardData[ny][nx] = p;
    _changeIndex++;
  }

  void overwritePiece(Piece piece, int x, int y) {
    assert(!isOut(x, y));
    _boardData[y][x] = piece;
    _changeIndex++;
  }

  void writePiece(Piece piece, int x, int y) {
    assert(isEmpty(x, y));
    overwritePiece(piece, x, y);
    _changeIndex++;
  }

  @override
  String toString() {
    const whiteEmp = "\u25FB";
    const blackEmp = "\u25FC";

    final buffer = StringBuffer();
    var isBlack = false;
    for (var y = 0; y < 14; y++) {
      for (var x = 0; x < 14; x++) {
        isBlack = !isBlack;
        if (isOut(x, y)) {
          buffer.write(" ");
        } else if (isEmpty(x, y)) {
          buffer.write(isBlack ? blackEmp : whiteEmp);
        } else {
          final piece = getPiece(x, y);
          final pieceIsWhite =
              [Direction.up, Direction.down].contains(piece.direction);
          buffer.write(piece.type.toStringBW(pieceIsWhite));
        }
        buffer.write("  ");
      }
      isBlack = !isBlack;
      buffer.write("\n");
    }
    return buffer.toString();
  }

  Board clone() {
    return Board._raw(
      Iterable<List<Piece?>>.generate(14, (i) => [..._boardData[i]]).toList(),
    );
  }
}
