/// A piece type in chess.
enum PieceType {
  pawn,
  knight,
  bishop,
  rook,
  queen,
  king;

  @override
  String toString() {
    return toStringBW(true);
  }

  String toStringBW(bool white) {
    if (white) {
      switch (this) {
        case king:
          return "♔";
        case queen:
          return "♕";
        case rook:
          return "♖";
        case bishop:
          return "♗";
        case knight:
          return "♘";
        default:
          return "♙";
      }
    }
    switch (this) {
      case king:
        return "♚";
      case queen:
        return "♛";
      case rook:
        return "♜";
      case bishop:
        return "♝";
      case knight:
        return "♞";
      default:
        return "♟︎";
    }
  }

  String toSimpleString() {
    switch (this) {
      case king:
        return "k";
      case queen:
        return "q";
      case rook:
        return "r";
      case knight:
        return "n";
      case bishop:
        return "b";
      default:
        return "";
    }
  }
}
