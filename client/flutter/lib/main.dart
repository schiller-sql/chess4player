import 'dart:io';

import 'package:chess44/chess_4p_app.dart';
import 'package:chess44/repositories/connection_uri/connection_uri_repository.dart';
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
    connectionAcceptDuration: Platform.isWindows ? const Duration(seconds: 2) : const Duration(milliseconds: 500),
    pingInterval: const Duration(milliseconds: 500),
  );
  GetIt.I.registerSingleton<ChessConnection>(chessConnection);

  final connectionUriRepository = ConnectionUriRepository(
    preferences: preferences,
  );
  await connectionUriRepository.init();

  runApp(Chess4pApp(connectionUriRepository: connectionUriRepository));
}
