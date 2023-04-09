import 'package:chess/blocs/resign/resign_cubit.dart';
import 'package:chess/ui/game/game_ended_dialog.dart';
import 'package:chess/ui/game/game_page.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/game/game_cubit.dart';
import '../../blocs/game_draw/game_draw_cubit.dart';
import '../../blocs/game_events/game_events_bloc.dart';
import '../../blocs/in_room/in_room_cubit.dart';
import '../../blocs/join_game/join_game_cubit.dart';
import '../../blocs/room/room_cubit.dart';
import '../../theme/chess_theme.dart' as theme;

class InGameRouter extends StatefulWidget {
  const InGameRouter({Key? key}) : super(key: key);

  @override
  State<InGameRouter> createState() => _InGameRouterState();
}

class _InGameRouterState extends State<InGameRouter> {
  late final GameDrawCubit gameDrawCubit;
  late final GameEventsBloc gameEventsCubit;

  Widget _buildTextWithIconInFront({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: color),
        children: [
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(icon, color: color, size: 18),
            ),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }

  @override
  void initState() {
    gameDrawCubit = GameDrawCubit(
      chessGameRepository: context.read<ChessGameRepository>(),
    )..startListeningToGame();
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
        if (state is ShowEvent) {
          final event = state.eventData;
          final canDraw = gameDrawCubit.state.canDraw;

          final SnackBar snackBar;
          if (event is DrawRequestEvent) {
            String text;
            if (event.isSelf) {
              text = "You have sent a draw request";
            } else {
              text = "${event.playerName} wants to draw";
              if (!canDraw) {
                text += " (you have already accepted)";
              }
            }
            snackBar = SnackBar(
              action: canDraw
                  ? SnackBarAction(
                      label: "accept draw",
                      onPressed: gameDrawCubit.acceptDraw,
                    )
                  : null,
              duration: state.duration,
              content: Row(
                children: [
                  _buildTextWithIconInFront(
                    icon: Icons.handshake_sharp,
                    text: text,
                    color: NordColors.$4,
                  ),
                ],
              ),
            );
          } else if (event is PlayerLostEvent) {
            final baseColor = theme.baseColors[event.playerDirection];
            final accentColor = theme.accentColors[event.playerDirection];
            final hasResigned = event.reason == "resign";
            final loseReason = hasResigned ? "resigned" : "been set checkmate";
            snackBar = SnackBar(
              duration: state.duration,
              backgroundColor: baseColor,
              content: _buildTextWithIconInFront(
                icon: hasResigned
                    ? Icons.flag
                    : ChessIcons.fallen_filled_king,
                text: event.isSelf
                    ? "You have $loseReason"
                    : "${event.playerName} has $loseReason",
                color: accentColor,
              ),
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
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
