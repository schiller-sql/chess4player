/// The direction a [Piece] can face in 4 players chess.
enum Direction {
  down(0, 1, 2), // y = 0
  left(-1, 0, 3), // x = 0
  up(0, -1, 0), // y = 13
  right(1, 0, 1); // x = 13

  final int dx;
  final int dy;
  final int clockwiseRotationsFromUp;

  const Direction(this.dx, this.dy, this.clockwiseRotationsFromUp);

  /// Rotate the direction by one clockwise.
  Direction get clockwiseRotate {
    switch (this) {
      case down:
        return left;
      case left:
        return up;
      case up:
        return right;
      default:
        return down;
    }
  }

  static Direction fromInt(int i) {
    assert(i >= 0);
    var direction = up;
    for (var j = 0; j < i; j++) {
      direction = direction.clockwiseRotate;
    }
    return direction;
  }
}
