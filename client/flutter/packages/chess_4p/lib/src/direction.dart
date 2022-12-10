enum Direction {
  down(0, 1), // y = 0
  left(-1, 0), // x = 0
  up(0, -1), // y = 13
  right(1, 0); // x = 13

  final int dx;
  final int dy;

  const Direction(this.dx, this.dy);

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
