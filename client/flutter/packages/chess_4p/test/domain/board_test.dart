import 'package:chess_4p/src/domain/board.dart';
import 'package:test/test.dart';

const defaultBoard = """
         ♖  ♘  ♗  ♔  ♕  ♗  ♔  ♖           
         ♙  ♙  ♙  ♙  ♙  ♙  ♙  ♙           
         ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼           
♜  ♟︎  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ♟︎  ♜  
♞  ♟︎  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ♟︎  ♞  
♝  ♟︎  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ♟︎  ♝  
♛  ♟︎  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ♟︎  ♚  
♚  ♟︎  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ♟︎  ♛  
♝  ♟︎  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ♟︎  ♝  
♞  ♟︎  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ♟︎  ♞  
♜  ♟︎  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻  ♟︎  ♜  
         ◼  ◻  ◼  ◻  ◼  ◻  ◼  ◻           
         ♙  ♙  ♙  ♙  ♙  ♙  ♙  ♙           
         ♖  ♘  ♗  ♕  ♔  ♗  ♔  ♖           
""";

void main() {
  test("standard board layout", () {
    expect(Board.standard().toString(), defaultBoard);
  });
}