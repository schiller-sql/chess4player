import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:chess_4p_connection/src/chess_connection_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() async {
  var channel = IOWebSocketChannel.connect(Uri.parse('ws://localhost:8080'));

  // channel.sink.add('{"type": "room", "subtype": "create", "content": {"name": "name"}}');
  // channel.sink.add('{"type": "room", "subtype": "create", "content": {"name": "name"}}');
  //
  // channel.stream.listen((message) {
  //   channel.sink.add('received!');
  //   channel.sink.close(status.goingAway);
  // });

  final connectionService = ChessConnectionService(channel: channel);
  connectionService.createRoom(playerName: "deine mom");
}
