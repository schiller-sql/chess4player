import 'dart:io';
import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chess44/blocs/game_draw/game_draw_cubit.dart';
import 'package:chess44/blocs/game_history/game_history_cubit.dart';
import 'package:chess44/theme/chess_theme.dart' as theme;
import 'package:chess44/ui/game/game_common.dart';
import 'package:chess44/ui/in_room/in_room_common.dart';
import 'package:chess_4p/chess_4p.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
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
    bool bottomPaddingForIcon = false,
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
              padding: EdgeInsets.only(
                right: 4,
                bottom: bottomPaddingForIcon ? 2 : 0,
              ),
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
            bottomPaddingForIcon: event.reason == LoseReason.checkmate,
            icon: iconDataFromLoseReason(event.reason),
            text: event.reason.getText(
              player: event.isSelf ? null : event.playerName,
            ),
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

  WidgetSpan _piece(Direction playerDirection, PieceType type) {
    Widget w = SizedBox(
      height: 20,
      width: 20,
      child: theme.playerStyles.createPiece(type, playerDirection),
    );
    final needsPadding = type != PieceType.rook && type != PieceType.pawn;
    if (needsPadding) {
      w = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: w,
      );
    }
    return WidgetSpan(
      child: w,
    );
  }

  Iterable<InlineSpan> _movement(
    BoardUpdate update,
    GameHistoryState state,
  ) sync* {
    final playerDirection =
        state.convertToColorDirection(update.playerDirection!);
    yield playerNameSpan(
      state.convertToName(update.playerDirection!),
      state.ownName,
      playerDirection,
    );
    yield const TextSpan(text: " moved");
    final move = update.moves[0];
    yield _piece(playerDirection, move.movedPieceType);
    if (update.moves.length == 2) {
      yield const TextSpan(text: " and");
      yield _piece(playerDirection, update.moves[1].movedPieceType);
    }
    if (move.hitPiece != null) {
      yield const TextSpan(text: "on");
      final hitPlayer = state.convertToColorDirection(move.hitPiece!.direction);
      yield _piece(hitPlayer, move.hitPiece!.type);
    }
    if (update.eliminatedPlayers.isNotEmpty) {
      yield const TextSpan(
        text: ", causing ",
      );
    }
  }

  Iterable<InlineSpan> _eliminatedPlayer(
    Direction eliminatedPlayer,
    BoardUpdate<LoseReason> update,
    GameHistoryState state,
  ) sync* {
    final reason = update.eliminatedPlayers[eliminatedPlayer]!;
    final name = state.convertToName(eliminatedPlayer);
    yield playerNameSpan(
      name,
      state.ownName,
      state.convertToColorDirection(eliminatedPlayer),
    );
    final causing = update.moves.isNotEmpty;
    yield TextSpan(
      text: reason.getTextWithoutNameComplex(
        causing: causing,
        isSelf: name == state.ownName,
      ),
    );
  }

  Widget _historyItem(
      BoardUpdate<LoseReason> update, int number, GameHistoryState state) {
    return Text.rich(
      TextSpan(
        text: "$number. ",
        children: [
          if (update.moves.isNotEmpty) ..._movement(update, state),
          for (final eliminatedPlayer in update.eliminatedPlayers.keys)
            ..._eliminatedPlayer(eliminatedPlayer, update, state),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return BlocBuilder<GameHistoryCubit, GameHistoryState>(
      builder: (context, state) {
        final updates = state.updates;
        return ListView.builder(
          itemCount: updates.length,
          itemBuilder: (context, index) {
            return ColoredBox(
              color: index % 2 == 0 ? NordColors.$1 : NordColors.$2,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  top: 6,
                  bottom: 6,
                ),
                child: _historyItem(
                  updates[index],
                  updates.length - index,
                  state,
                ),
              ),
            );
          },
        );
      },
    );
  }

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
      final sideBarChildren = [
          board,
          Expanded(
            child: Column(
              children: [
                Container(
                  color: NordColors.$3,
                  height: 56,
                ),
                Expanded(
                  child: Container(
                    color: NordColors.$2,
                    child: _buildHistoryList(),
                  ),
                ),
              ],
            ),
          ),
        ];
      if(Platform.isWindows) {
        sideBarChildren.add(sideBarChildren.removeAt(0));
      }
      board = Row(
        mainAxisSize: canFitSideBar ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: sideBarChildren,
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
                  alignment: Platform.isWindows
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                                      context
                                          .read<GameDrawCubit>()
                                          .requestDraw();
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
                                  if (Platform.isWindows) {
                                    appWindow.size = Size(
                                      size.width +
                                          _sideBarWidth -
                                          widthDiff +
                                          80,
                                      size.height,
                                    );
                                  } else {
                                    final off = appWindow.position;
                                    appWindow.size = Size(
                                      size.width + _sideBarWidth - widthDiff,
                                      size.height,
                                    );
                                    appWindow.position = off;
                                  }
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
