import 'package:web_socket_channel/io.dart';

class ChessConnection {
  final Uri uri;
  late final IOWebSocketChannel _channel;

  ChessConnection(this.uri);

  void openConnection() {
    _channel =
        IOWebSocketChannel.connect(Uri.parse('ws://localhost:8080'));
  }

  void closeConnection() {}

  void send() {

  }
}
