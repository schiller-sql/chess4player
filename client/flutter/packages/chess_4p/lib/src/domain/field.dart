/// A field/point in chess.
class Field {
  final int x, y;

  /// Standard constructor.
  const Field(this.x, this.y)
      : assert(x >= 0),
        assert(y >= 0);

  /// Get the field at [x] and [y],
  /// but rotated [clockwiseRotation] times clockwise.
  factory Field.rotatedClockwise(int x, int y, int clockwiseRotation) {
    final rotatedX = clockwiseRotateXBy(x, y, clockwiseRotation);
    final rotatedY = clockwiseRotateYBy(x, y, clockwiseRotation);
    return Field(rotatedX, rotatedY);
  }

  /// Get the next [Field] rotated clockwise.
  Field get clockwiseRotation =>
      Field(clockwiseRotateX(x, y), clockwiseRotateY(x, y));

  /// Get the next [Field] rotated clockwise [rotations] times.
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

  /// Give back x of a field at [x] and [y]
  /// that has been rotated [rotations] times clockwise.
  static int clockwiseRotateXBy(int x, int y, int rotations) {
    rotations = _minPosRotations(rotations);
    if (rotations == 0) return x;
    if (rotations == 1) return 13 - y;
    if (rotations == 2) return 13 - x;
    return y;
  }

  /// Give back y of a field at [x] and [y]
  /// that has been rotated [rotations] times clockwise.
  static int clockwiseRotateYBy(int x, int y, int rotations) {
    rotations = _minPosRotations(rotations);
    if (rotations == 0) return y;
    if (rotations == 1) return x;
    if (rotations == 2) return 13 - y;
    return 13 - x;
  }

  /// Give back x of a field at [x] and [y]
  /// that has been rotated once clockwise.
  static int clockwiseRotateX(int x, int y) {
    return 13 - y;
  }

  /// Give back y of a field at [x] and [y]
  /// that has been rotated once clockwise.
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
