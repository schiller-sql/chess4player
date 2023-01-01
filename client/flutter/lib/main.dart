import 'package:chess/chess_4p_app.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart' as config;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

