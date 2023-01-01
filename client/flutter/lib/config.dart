import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<ChessConnection> getConnection() async {
  await dotenv.load(fileName: "../.env");
  final url = dotenv.maybeGet("URL");
  assert(
    url != null,
    "create a '.env' file in the 'client' folder "
    "with a web-socket URL as follows: "
    "URL='[here comes the url]'",
  );
  final wsUri = Uri.parse(url!);
  return ChessConnection(uri: wsUri);
}
