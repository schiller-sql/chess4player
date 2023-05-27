import 'package:chess/chess_4p_app.dart';
import 'package:chess/repositories/connection_uri/connection_uri_repository.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  doWhenWindowReady(() {
    const initialSize = Size(850, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.show();
  });

  final preferences = await SharedPreferences.getInstance();
  GetIt.I.registerSingleton<SharedPreferences>(preferences);

  final chessConnection = ChessConnection(
    pingInterval: const Duration(milliseconds: 500),
  );
  GetIt.I.registerSingleton<ChessConnection>(chessConnection);

  final connectionUriRepository = ConnectionUriRepository(
    preferences: preferences,
  );
  await connectionUriRepository.init();

  connectionUriRepository.currentUri = "ws://mueller.v6.rocks:80";

  runApp(Chess4pApp(connectionUriRepository: connectionUriRepository));
}
