import 'package:chess_4p/chess_4p.dart';

class DirectionalTuple<E> {
  final E up, right, down, left;

  const DirectionalTuple(this.up, this.right, this.down, this.left);

  const DirectionalTuple.all(E e) : this(e, e, e, e);

  const DirectionalTuple.allWithOverride(E all, {E? up, E? right, E? down, E? left})
      : this(up ?? all, right ?? all, down ?? all, left ?? all);

  E get(Direction direction) {
    switch (direction) {
      case Direction.up:
        return up;
      case Direction.right:
        return right;
      case Direction.down:
        return down;
      default:
        return left;
    }
  }

  // E getDirection(Direction direction) {
  //   return _get(direction)!;
  // }

  // E getDirectionWithDefault(Direction direction, E alt) {
  //   return _get(direction) ?? alt;
  // }
}
