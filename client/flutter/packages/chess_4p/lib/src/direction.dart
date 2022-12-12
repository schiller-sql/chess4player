enum Direction {
  down(0, 1, 2), // y = 0
  left(-1, 0, 3), // x = 0
  up(0, -1, 0), // y = 13
  right(1, 0, 1); // x = 13

  final int dx;
  final int dy;
  final int clockwiseRotationsFromUp;

  const Direction(this.dx, this.dy, this.clockwiseRotationsFromUp);

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
}
