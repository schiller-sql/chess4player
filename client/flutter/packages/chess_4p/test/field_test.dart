import 'dart:math';

import 'package:chess_4p/chess_4p.dart';
import 'package:test/test.dart';

void main() {
  test("test rotation of points", () {
    for(int y = 0; y < 14; y++) {
      for(int x = 0; x < 14; x++) {
        // test single rotation
        Field f = Field(x, y);
        expect(f, f.clockwiseRotation.clockwiseRotation.clockwiseRotation.clockwiseRotation);

        // test multiple rotations at once
        int half = Random().nextInt(16);
        int otherHalf = 16 - half;
        expect(f, f.rotateClockwiseBy(half).rotateClockwiseBy(otherHalf));
      }
    }
  });
}