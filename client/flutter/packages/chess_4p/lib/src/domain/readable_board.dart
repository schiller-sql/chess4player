import 'piece.dart';

/// An interface for a chess board that is only readable.
abstract class ReadableBoard {
  /// If on a coordinate on the board, there is no piece.
  bool isEmpty(int x, int y);

  /// Get the piece of a coordinate, check if there is a piece with [isEmpty].
  Piece getPiece(int x, int y);

  bool isOut(int x, int y);

  int get changeIndex;
}
