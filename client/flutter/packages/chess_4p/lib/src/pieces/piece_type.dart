enum PieceType {
  king,
  queen,
  rook,
  bishop,
  knight,
  pawn;

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
}
