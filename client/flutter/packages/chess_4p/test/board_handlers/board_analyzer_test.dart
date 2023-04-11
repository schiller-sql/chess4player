import 'package:chess_4p/chess_4p.dart';
import 'package:test/test.dart';

void main() {
  group("simple starting positions tests", () {
    late final BoardAnalyzer analyzer;

    setUpAll(() {
      analyzer = BoardAnalyzer(
        board: Board.standard(),
        analyzingDirection: Direction.up,
      );
    });

    test("pawn 2 forward", () {
      expect(analyzer.accessibleFields(4, 12), {Field(4, 11), Field(4, 10)});
    });

    test("knight only allowed positions", () {
      expect(analyzer.accessibleFields(4, 13), {Field(5, 11), Field(3, 11)});
    });

    test("others no positions", () {
      final y = 13;
      for (var x = 3; x < 11; x++) {
        if (x == 4 || x == 9) continue;
        if (x == 7) continue; // TODO: remove when king finished
        expect(analyzer.accessibleFields(x, y), isEmpty);
      }
    });
  });

  group("pawn exceptions", () {
    // TODO: en passent
    late BoardAnalyzer analyzer;
    late Board board;
    late Piece pawnPiece; // pawn is still at state 0, allowed to move +2

    setUp(() {
      board = Board.empty();
      pawnPiece = p3;
      board.writePiece(pawnPiece, 8, 8);
      board.writePiece(k3, 3, 3);
      analyzer = BoardAnalyzer(
        board: board,
        analyzingDirection: Direction.left,
      );
    });

    test("friendly piece (+1) in front and diagonal (no moving,no attacking)",
        () {
      board.writePiece(k3, 7, 8);
      board.writePiece(k3, 7, 7);
      expect(analyzer.accessibleFields(8, 8), isEmpty);
    });

    test("enemy piece (+2) in front and diagonal (no moving 2,attacking", () {
      board.writePiece(k2, 6, 8);
      board.writePiece(k2, 7, 7);
      expect(
        analyzer.accessibleFields(8, 8),
        {Field(7, 8), Field(7, 7)},
      );
    });

    test("pawn has already been moved and cant move +2", () {
      pawnPiece.hasBeenMoved = true;
      expect(
        analyzer.accessibleFields(8, 8),
        {Field(7, 8)},
      );
    });
  });

  test("knight on friendly, unfriendly, empty and not in bound pieces", () {
    final board = Board.empty();
    // knight and king
    board.writePiece(k0, 10, 10);
    board.writePiece(n0, 3, 10);

    // unfriendly pieces
    board.writePiece(k1, 4, 12);
    board.writePiece(k1, 5, 11);

    // friendly pieces
    board.writePiece(n0, 1, 9);
    board.writePiece(p0, 2, 8);

    final analyzer =
        BoardAnalyzer(board: board, analyzingDirection: Direction.up);
    expect(
      analyzer.accessibleFields(3, 10),
      {Field(4, 12), Field(5, 11), Field(4, 8), Field(5, 9)},
    );
  });

  test("queen, bishop, rook", () {
    final board = Board.empty();
    // queen (internally uses methods of bishop and rook)
    board.writePiece(q0, 3, 1);

    // friendly pieces
    board.writePiece(k0, 5, 1);

    // enemy pieces
    board.writePiece(k1, 5, 3);
    board.writePiece(k1, 3, 2);

    final analyzer =
        BoardAnalyzer(board: board, analyzingDirection: Direction.up);
    expect(
      analyzer.accessibleFields(3, 1),
      {
        Field(4, 1),
        Field(3, 0),
        Field(4, 0),
        Field(4, 2),
        Field(5, 3),
        Field(3, 2),
      },
    );
  });

  group("king in check", () {
    test("queen can save king in check by rook", () {
      final board = Board.empty();
      // attacked king
      board.writePiece(k1, 4, 6);

      // attacking rook
      board.writePiece(r0, 4, 1);

      // saving queen
      board.writePiece(q1, 2, 3);

      final analyzer =
          BoardAnalyzer(board: board, analyzingDirection: Direction.right);
      expect(
        analyzer.accessibleFields(2, 3),
        {
          Field(4, 1), // queen attack rook
          Field(4, 3), // between rook and king
          Field(4, 5), // right before rook
        },
      );
    });

    test("to pawns can attack king, queen cannot save", () {
      final board = Board.empty();
      // attacked king
      board.writePiece(k1, 4, 6);

      // attacking pawns
      board.writePiece(p0, 3, 7);
      board.writePiece(p0, 5, 7);

      // saving queen
      board.writePiece(q1, 8, 7);

      final analyzer =
          BoardAnalyzer(board: board, analyzingDirection: Direction.right);
      expect(
        analyzer.accessibleFields(8, 7),
        isEmpty,
      );
    });
  });

  group("king attacked by queen, pawn and knight", () {
    late Board board;
    late BoardAnalyzer boardAnalyzer;

    setUp(() {
      board = Board.empty();
      boardAnalyzer =
          BoardAnalyzer(board: board, analyzingDirection: Direction.up);
      // attacked king
      board.writePiece(k0, 8, 8);
      // queen (right above king)
      board.writePiece(q1, 9, 7);
      // knight (right under king)
      board.writePiece(n3, 9, 11);
      // pawn coming from left, attacking left field next to king (does not change anything)
      board.writePiece(p1, 6, 8);
    });

    test("pawn does not exist, queen attack able", () {
      board.removePiece(6, 8);
      expect(
        boardAnalyzer.accessibleFields(8, 8),
        {Field(9, 7), Field(7, 8)},
      );
    });

    test("queen attack able, field with own person", () {
      board.writePiece(n0, 7, 8);
      expect(
        boardAnalyzer.accessibleFields(8, 8),
        {Field(9, 7)},
      );
    });

    test("queen not attack able (covered by pawn)", () {
      board.writePiece(p3, 10, 6);
      expect(
        boardAnalyzer.accessibleFields(8, 8),
        {Field(7, 8)},
      );
    });

    test("queen attack able", () {
      expect(
        boardAnalyzer.accessibleFields(8, 8),
        {Field(9, 7), Field(7, 8)},
      );
    });
  });

  group("castle", () {
    group("direction up", () {
      late Board board;
      late BoardAnalyzer boardAnalyzer;

      setUp(() {
        board = Board.empty();
        boardAnalyzer =
            BoardAnalyzer(board: board, analyzingDirection: Direction.up);
        // easiest two way castle scenario
        board.writePiece(k0, 7, 13);
        board.writePiece(r0, 3, 13);
        board.writePiece(r0, 10, 13);
      });

      test("two ways castle possible", () {
        expect(
          boardAnalyzer.accessibleFields(7, 13),
          containsAll({Field(5, 13), Field(9, 13)}),
        );
      });
    });

    group("direction left", () {
      late Board board;
      late BoardAnalyzer boardAnalyzer;

      setUp(() {
        board = Board.empty();
        boardAnalyzer =
            BoardAnalyzer(board: board, analyzingDirection: Direction.left);
        // easiest two way castle scenario
        board.writePiece(k3, 13, 6);
        board.writePiece(r3, 13, 3);
        board.writePiece(r3, 13, 10);
        // TODO: does not give back castling pieces, but the other ones
      });

      test("two way castle possible", () {
        expect(
          boardAnalyzer.accessibleFields(13, 6),
          containsAll({Field(13, 4), Field(13, 8)}),
        );
      });

      test("king being attacked", () {
        board.writePiece(n0, 11, 7);
        expect(
          boardAnalyzer.accessibleFields(13, 6),
          isNot(containsAll({Field(13, 4), Field(13, 8)})),
        );
      });

      test("right castle position (position where king would be) attacked", () {
        board.writePiece(n0, 11, 9);
        expect(
          boardAnalyzer.accessibleFields(13, 6),
          contains(Field(13, 4)),
        );

        expect(
          boardAnalyzer.accessibleFields(13, 6),
          isNot(
            contains(
              Field(13, 8),
            ),
          ),
        );
      });

      test("friendly or unfriendly piece between left rook and king", () {
        // friendly
        board.writePiece(p3, 13, 4);
        final pieces0 = boardAnalyzer.accessibleFields(13, 6);
        // unfriendly
        board.overwritePiece(p1, 13, 4);
        final pieces1 = boardAnalyzer.accessibleFields(13, 6);
        expect(pieces0, pieces1);

        expect(
          pieces0,
          contains(Field(13, 8)),
        );

        expect(
          pieces0,
          isNot(
            contains(
              Field(13, 4),
            ),
          ),
        );
      });
    });
  });

  group("specific tests", () {
    test(
        "bug: a enemy queen directly next to king, yet rook can be moved, "
        "as it is technically in vector of queen", () {
      final board = Board.standardWithOmission([true, false, false, false]);
      final analyzer = BoardAnalyzer(
        board: board,
        analyzingDirection: Direction.up,
      );
      board.removePiece(6, 13);
      board.removePiece(8, 13);
      board.overwritePiece(b3, 4, 13);
      board.writePiece(q3, 8, 13);

      expect(analyzer.accessibleFields(3, 13), isEmpty);
      expect(analyzer.accessibleFields(7, 13), {Field(8, 13)});
    });

    test("horse attacks king, queen can save, pawn cannot", () {
      final board = Board.empty();
      final analyzer = BoardAnalyzer(
        board: board,
        analyzingDirection: Direction.up,
      );
      board.writePiece(k0, 8, 8);
      board.writePiece(n1, 7, 10);
      board.writePiece(q0, 7, 11);
      board.writePiece(p0, 3, 3);

      expect(analyzer.accessibleFields(3, 3), isEmpty);
      expect(analyzer.accessibleFields(7, 11), {Field(7, 10)});
    });
  });
}
