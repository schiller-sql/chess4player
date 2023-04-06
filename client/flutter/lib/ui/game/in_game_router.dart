import 'package:chess/blocs/resign/resign_cubit.dart';
import 'package:chess/ui/game/game_ended_dialog.dart';
import 'package:chess/ui/game/game_page.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/game/game_cubit.dart';
import '../../blocs/game_draw/game_draw_cubit.dart';
import '../../blocs/game_events/game_events_bloc.dart';
import '../../blocs/in_room/in_room_cubit.dart';
import '../../blocs/join_game/join_game_cubit.dart';
import '../../blocs/room/room_cubit.dart';

class InGameRouter extends StatefulWidget {
  const InGameRouter({Key? key}) : super(key: key);

  @override
  State<InGameRouter> createState() => _InGameRouterState();
}

class _InGameRouterState extends State<InGameRouter> {
  late final GameDrawCubit gameDrawCubit;
  late final GameEventsBloc gameEventsCubit;

  @override
  void initState() {
    gameDrawCubit = GameDrawCubit(
      chessGameRepository: context.read<ChessGameRepository>(),
    );
    gameEventsCubit = GameEventsBloc(
      chessGameRepository: context.read<ChessGameRepository>(),
    )..startListeningToGame();
    super.initState();
  }

  @override
  void dispose() {
    gameDrawCubit.close();
    gameEventsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameEventsBloc, GameEventsState>(
      bloc: gameEventsCubit,
      listener: (context, state) {
        if (state is NoEvent) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        } else if (state is ShowEvent) {
          final event = state.eventData;
          final SnackBar snackBar;
          if (event is DrawRequestEvent) {
            snackBar = SnackBar(
              content: Text("${event.playerName} wants to draw"),
            );
          } else if (event is PlayerLostEvent) {
            snackBar = SnackBar(
              content: Text("${event.playerName} has lost"),
            );
          } else {
            throw StateError(
              "event can only be DrawRequestEvent or PlayerLostEvent",
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: BlocListener<GameCubit, GameState>(
        listener: (context, state) {
          if (state is GameHasEnded) {
            showDialog(
              context: context,
              barrierDismissible: false,
              useRootNavigator: false,
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: context.read<InRoomCubit>(),
                  ),
                  BlocProvider.value(
                    value: context.read<JoinGameCubit>(),
                  ),
                  BlocProvider.value(
                    value: context.read<RoomCubit>(),
                  ),
                ],
                child: GameEndedDialog(gameEndReason: state.gameEndReason),
              ),
            );
          }
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ResignCubit(
                chessGameRepository: context.read<ChessGameRepository>(),
              ),
            ),
            BlocProvider.value(
              value: gameDrawCubit,
            ),
            BlocProvider.value(
              value: gameEventsCubit,
            ),
          ],
          child: const GamePage(),
        ),
      ),
    );
  }
}
