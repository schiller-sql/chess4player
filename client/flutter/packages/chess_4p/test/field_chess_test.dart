import 'package:chess_4p/chess_4p.dart';
import 'package:test/test.dart';

void main() {
  test("test rotation of points", () {
    for(int y = 0; y < 14; y++) {
      for(int x = 0; x < 14; x++) {
        Field f = Field(x, y);
        expect(f, f.clockwiseRotation.clockwiseRotation.clockwiseRotation.clockwiseRotation);
      }
    }
  });
}