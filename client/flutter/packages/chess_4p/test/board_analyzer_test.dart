import 'package:chess_4p/chess_4p.dart';
import 'package:chess_4p/src/board/board.dart';
import 'package:chess_4p/src/board/default_board.dart';
import 'package:chess_4p/src/board_analyzer.dart';
import 'package:chess_4p/src/direction.dart';
import 'package:chess_4p/src/pieces/piece.dart';
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
    late Piece pawnPiece; // pawn is still at state 0, allowed to move +2

    setUp(() {
      final board = Board.empty();
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
      analyzer.board.writePiece(k3, 7, 8);
      analyzer.board.writePiece(k3, 7, 7);
      expect(analyzer.accessibleFields(8, 8), isEmpty);
    });

    test("enemy piece (+2) in front and diagonal (no moving 2,attacking", () {
      analyzer.board.writePiece(k2, 6, 8);
      analyzer.board.writePiece(k2, 7, 7);
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
}
