import 'package:chess/theme/chess_theme.dart' as theme;
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/room/room_cubit.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NordColors.$0,
      body: Center(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ChessBoard(
                  chessGameRepository: context.read<ChessGameRepository>(),
                  colorStyle: theme.chessStyle,
                  playerStyles: DirectionOffsetPlayerStyles(
                    baseSet: theme.playerStyles,
                    offset:
                        context.read<ChessGameRepository>().game.ownPlayerPosition,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                child: const Text("leave room"),
                onPressed: () {
                  context.read<RoomCubit>().leave();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
