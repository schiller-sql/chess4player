import 'package:chess_4p/src/domain/direction.dart';
import 'package:test/test.dart';

main() {
  test("from integer", () {
    expect(Direction.fromInt(-3), Direction.right);
    expect(Direction.fromInt(1), Direction.right);
    expect(Direction.fromInt(-10), Direction.down);
    expect(Direction.fromInt(10), Direction.down);
  });
}