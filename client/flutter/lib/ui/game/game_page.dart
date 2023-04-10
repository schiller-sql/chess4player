import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chess/blocs/game_draw/game_draw_cubit.dart';
import 'package:chess/theme/chess_theme.dart' as theme;
import 'package:chess/ui/game/game_common.dart';
import 'package:chess/ui/in_room/in_room_common.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/game_events/game_events_bloc.dart';
import '../../blocs/resign/resign_cubit.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final GameEventsBloc gameEventsBloc;

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
    super.initState();
    gameEventsBloc = GameEventsBloc(
      chessGameRepository: context.read<ChessGameRepository>(),
    )..startListeningToGame();
  }

  void _showSnackBar(
    BuildContext context,
    GameEventsState state,
  ) {
    if (state is ShowEvent) {
      final event = state.eventData;
      final gameDrawCubit = context.read<GameDrawCubit>();
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
        snackBar = SnackBar(
          duration: state.duration,
          backgroundColor: baseColor,
          content: _buildTextWithIconInFront(
            icon: iconDataFromLoseReason(event.reason),
            text: event.reason.getText(event.isSelf ? null : event.playerName),
            color: accentColor,
          ),
        );
      } else {
        throw StateError(
          "event can only be DrawRequestEvent or PlayerLostEvent",
        );
      }
      scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
    } else {
      scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    }
  }

  @override
  void dispose() {
    super.dispose();
    gameEventsBloc.close();
  }

  static const double _sideBarWidth = 168 + 6;

  final boardKey = GlobalKey(debugLabel: "chess board");
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthDiff = size.width - size.height;
    final canFitSideBar = widthDiff >= _sideBarWidth;
    Widget board = Padding(
      padding: const EdgeInsets.all(32),
      child: ChessBoard(
        key: boardKey,
        chessGameRepository: context.read<ChessGameRepository>(),
        colorStyle: theme.chessStyle,
        playerStyles: DirectionOffsetPlayerStyles(
          baseSet: theme.playerStyles,
          offset: context.read<ChessGameRepository>().game.ownPlayerPosition,
        ),
      ),
    );
    if (canFitSideBar) {
      board = Row(
        mainAxisSize: canFitSideBar ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          board,
          Expanded(
            child: Container(color: NordColors.$3),
          ),
        ],
      );
    } else {
      board = Center(child: board);
    }
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: NordColors.$0,
        body: BlocListener<GameEventsBloc, GameEventsState>(
          bloc: gameEventsBloc,
          listener: _showSnackBar,
          child: Center(
            child: Stack(
              children: [
                board,
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: max(widthDiff, _sideBarWidth)),
                    child: SizedBox(
                      height: 32,
                      child: WindowTitleBarBox(
                        child: MoveWindow(),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        BlocBuilder<ResignCubit, ResignState>(
                          builder: (context, state) {
                            return IconButton(
                              icon: const Icon(
                                Icons.flag_sharp,
                              ),
                              tooltip: state.canResign
                                  ? "resign"
                                  : "you have already lost",
                              onPressed: state.canResign
                                  ? () => showShouldResignDialog(context)
                                  : null,
                            );
                          },
                        ),
                        BlocBuilder<GameDrawCubit, GameDrawState>(
                          builder: (context, state) {
                            return IconButton(
                              icon: const Icon(
                                Icons.handshake_sharp,
                              ),
                              tooltip: state.didLose
                                  ? "you have already lost"
                                  : (state.canDraw
                                      ? "request a draw"
                                      : "how have already agreed to draw"),
                              onPressed: state.canDraw
                                  ? () {
                                      context.read<GameDrawCubit>().requestDraw();
                                    }
                                  : null,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.low_priority_sharp,
                          ),
                          tooltip: canFitSideBar
                              ? "already showing history"
                              : "show history",
                          onPressed: canFitSideBar
                              ? null
                              : () {
                                  final off = appWindow.position;
                                  appWindow.size = Size(
                                    size.width + _sideBarWidth - widthDiff,
                                    size.height,
                                  );
                                  appWindow.position = off;
                                },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout_sharp,
                          ),
                          tooltip: "leave room",
                          onPressed: () => showShouldLeaveDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
                // context.read<RoomCubit>().leave();
              ],
            ),
          ),
        ),
      ),
    );
  }
}
