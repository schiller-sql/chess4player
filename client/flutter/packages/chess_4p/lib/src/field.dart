class Field {
  final int x, y;

  Field(this.x, this.y);

  factory Field.rotatedClockwise(int x, int y, int clockwiseRotation) {
    final rotatedX = clockwiseRotateXBy(x, y, clockwiseRotation);
    final rotatedY = clockwiseRotateYBy(x, y, clockwiseRotation);
    return Field(rotatedX, rotatedY);
  }

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
    if(rotations == 0) return x;
    if(rotations == 1) return 13 - y;
    if(rotations == 2) return 13 - x;
    return y;
  }

  static int clockwiseRotateYBy(int x, int y, int rotations) {
    rotations = _minPosRotations(rotations);
    if(rotations == 0) return y;
    if(rotations == 1) return x;
    if(rotations == 2) return 13 - y;
    return 13 - x;
  }

  static int clockwiseRotateX(int x, int y) {
    return 13 - y;
  }

  static int clockwiseRotateY(int x, int y) {
    return x;
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
    return '($x,$y)';
  }
}
