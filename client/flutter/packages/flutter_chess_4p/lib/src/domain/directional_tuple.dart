import 'package:chess_4p/chess_4p.dart';

class DirectionalTuple<E> {
  final E up, right, down, left, inactive;

  const DirectionalTuple(
    this.up,
    this.right,
    this.down,
    this.left,
    this.inactive,
  );

  const DirectionalTuple.all(E e) : this(e, e, e, e, e);

  const DirectionalTuple.allWithOverride(E all,
      {E? up, E? right, E? down, E? left, E? inactive})
      : this(
          up ?? all,
          right ?? all,
          down ?? all,
          left ?? all,
          inactive ?? all,
        );

  E getFromInt(int? i) {
    if(i == null) {
      return inactive;
    }
    assert(i >= 0);
    i = i % 4;
    switch (i) {
      case 0:
        return up;
      case 1:
        return right;
      case 2:
        return down;
      default:
        return left;
    }
  }

  E get(Direction? direction) {
    switch (direction) {
      case Direction.up:
        return up;
      case Direction.right:
        return right;
      case Direction.down:
        return down;
      case Direction.left:
        return left;
      default:
        return inactive;
    }
  }

  // E getDirection(Direction direction) {
  //   return _get(direction)!;
  // }

  // E getDirectionWithDefault(Direction direction, E alt) {
  //   return _get(direction) ?? alt;
  // }
}
