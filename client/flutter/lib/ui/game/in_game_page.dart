import 'package:chess/blocs/in_room/in_room_cubit.dart';
import 'package:chess/theme/chess_theme.dart' as theme;
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/room/room_cubit.dart';

class InGamePage extends StatefulWidget {
  const InGamePage({Key? key}) : super(key: key);

  @override
  State<InGamePage> createState() => _InGamePageState();
}

class _InGamePageState extends State<InGamePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [

          ChessBoard(
            chessGameRepository: context.read<ChessGameRepository>(),
            pieceSet: theme.pieceSet,
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
    );
  }
}
