class Field {
  final int x, y;

  Field(this.x, this.y);

  Field get clockwiseRotation =>
      Field(clockwiseRotateX(x, y), clockwiseRotateY(x, y));

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
