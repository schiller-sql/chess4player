import 'dart:math';

import 'package:chess/chess_board_painter.dart';
import 'package:chess/theme/theme.dart';
import 'package:flutter/material.dart';

import 'chess_board.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chess',
      theme: fPlotTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
