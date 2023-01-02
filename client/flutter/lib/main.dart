import 'package:chess/chess_4p_app.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'config.dart' as config;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  doWhenWindowReady(() {
    // 823x592
    const initialSize = Size(850, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });

  final configObjects = await Future.wait(
    [
      SharedPreferences.getInstance(),
      config.getConnection(),
    ],
  );
  final preferences = configObjects[0] as SharedPreferences;
  GetIt.I.registerSingleton<SharedPreferences>(preferences);

  final chessConnection = configObjects[1] as ChessConnection;
  GetIt.I.registerSingleton<ChessConnection>(chessConnection);

  runApp(const Chess4pApp());
}

