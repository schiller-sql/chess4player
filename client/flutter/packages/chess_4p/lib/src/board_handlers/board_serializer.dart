import '../domain/board.dart';
import '../domain/direction.dart';

/// Converts a [Board] to a string.
class BoardSerializer {
  /// The [Board] that should be serialized.
  final Board board;

  /// Standard constructor to give the [board] on which to move.
  BoardSerializer({required this.board});

  @override
  String toString() {
    const whiteEmp = "\u25FB";
    const blackEmp = "\u25FC";

    final buffer = StringBuffer();
    var isBlack = false;
    for (var y = 0; y < 14; y++) {
      for (var x = 0; x < 14; x++) {
        isBlack = !isBlack;
        if (board.isOut(x, y)) {
          buffer.write(" ");
        } else if (board.isEmpty(x, y)) {
          buffer.write(isBlack ? blackEmp : whiteEmp);
        } else {
          final piece = board.getPiece(x, y);
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
}