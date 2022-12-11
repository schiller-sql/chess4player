class Field {
  final int x, y;

  Field(this.x, this.y);

  Field get clockwiseRotation =>
      Field(clockwiseRotateX(x, y), clockwiseRotateY(x, y));

  Field rotateClockwiseBy(int rotations) {
    return Field(clockwiseRotateXBy(x, y, rotations),
        clockwiseRotateYBy(x, y, rotations));
  }

  static int _minPosRotations(int rotations) {
    rotations = rotations % 4;
    if (rotations < 0) {
      rotations += 4;
    }
    return rotations;
  }

  static int clockwiseRotateXBy(int x, int y, int rotations) {
    rotations = _minPosRotations(rotations);
    final shouldBeRotatedFirstTime = (x <= 6 && y <= 6) || (x > 6 && y > 6);
    if ((shouldBeRotatedFirstTime && rotations < 3 && rotations > 0) ||
        (!shouldBeRotatedFirstTime && rotations > 1)) {
      return 13 - x;
    }
    return x;
  }

  static int clockwiseRotateYBy(int x, int y, int rotations) {
    rotations = _minPosRotations(rotations);
    final shouldBeRotatedFirstTime = (x <= 6 && y > 6) || (x > 6 && y <= 6);
    if ((shouldBeRotatedFirstTime && rotations < 3 && rotations > 0)||
        (!shouldBeRotatedFirstTime && rotations > 1)) {
      return 13 - y;
    }
    return y;
  }

  static int clockwiseRotateX(int x, int y) {
    if ((x <= 6 && y <= 6) || (x > 6 && y > 6)) {
      return 13 - x;
    }
    return x;
  }

  static int clockwiseRotateY(int x, int y) {
    if ((x <= 6 && y > 6) || (x > 6 && y <= 6)) {
      return 13 - y;
    }
    return y;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Field &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() {
    return '($x|$y}';
  }
}
