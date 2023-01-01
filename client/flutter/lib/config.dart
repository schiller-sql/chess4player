import 'package:chess_4p_connection/chess_4p_connection.dart';

Future<ChessConnection> getConnection() async {
  // TODO: change to .env file
  final wsUri = Uri.parse("ws://localhost:8080");
  return ChessConnection(uri: wsUri);
}
