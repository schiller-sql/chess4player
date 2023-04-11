import 'package:chess_4p/src/domain/board.dart';
import 'package:chess_4p/src/domain/default_board.dart';
import 'package:chess_4p/src/board_handlers/board_mover.dart';
import 'package:chess_4p/src/domain/piece_type.dart';
import 'package:test/test.dart';

final promotion_promotion_possible_test_expect = """
         ◻  ◼  ◻  ♝  ◻  ◼  ◻  ◼           
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
""";

final castle_left_castle_test_expect = """
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ♜  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ♜  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ♚  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
""";

final castle_right_castle_test_expect = """
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ♚  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ♜  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ♜  
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
""";

final castle_no_castle_test_expect = """
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ♜  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ♚  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  
◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  
◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ♜  
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
""";

void main() {
  group("castle", () {
    late Board board;
    late BoardMover boardMover;

    setUp(() {
      board = Board.empty();
      board.writePiece(k3, 13, 6);
      board.writePiece(r3, 13, 3);
      board.writePiece(r3, 13, 10);
      boardMover = BoardMover(board: board);
    });

    test("left castle", () {
      boardMover.analyzeAndApplyMoves(13, 6, 13, 8);
      print(board);
      expect(board.toString(), castle_left_castle_test_expect);
    });

    test("right castle", () {
      boardMover.analyzeAndApplyMoves(13, 6, 13, 4);
      print(board);
      expect(board.toString(), castle_right_castle_test_expect);
    });

    test("no castle", () {
      boardMover.analyzeAndApplyMoves(13, 6, 13, 5);
      print(board);
      expect(board.toString(), castle_no_castle_test_expect);
    });
  });

  group("promotion", () {
    late Board board;
    late BoardMover boardMover;

    setUp(() {
      board = Board.empty();
      board.writePiece(p3, 7, 0);
      boardMover = BoardMover(board: board);
    });

    test("promotion possible", () {
      expect(boardMover.analyzeMoveIsPromotion(7, 0, 6, 0), true);
      boardMover.analyzeAndApplyMoves(7, 0, 6, 0, PieceType.bishop);
      expect(board.toString(), promotion_promotion_possible_test_expect);
    });

    test("no promotion possible", () {
      board.move(7, 0, 8, 0);
      expect(boardMover.analyzeMoveIsPromotion(8, 0, 7, 0), false);
    });
  });
}
