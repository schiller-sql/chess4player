import 'package:chess44/blocs/in_room/in_room_cubit.dart';
import 'package:chess44/ui/in_room/in_room_common.dart';
import 'package:chess44/widgets/animation/chess_loading_animation.dart';
import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/game/game_cubit.dart';
import '../../blocs/join_game/join_game_cubit.dart';
import '../../theme/chess_theme.dart';
import 'game_common.dart';

class GameEndedDialog extends StatefulWidget {
  final GameHasEnded gameEnd;

  const GameEndedDialog({super.key, required this.gameEnd});

  @override
  State<GameEndedDialog> createState() => _GameEndedDialogState();
}

class _GameEndedDialogState extends State<GameEndedDialog> {
  Iterable<TextSpan> _playerNameSpans(
    List<String> names,
    String ownName,
    Map<String, Direction> playerDirections,
  ) sync* {
    for (var i = 0; i < names.length; i++) {
      final name = names[i];
      yield playerNameSpan(name, ownName, playerDirections[name]!);
      if (i != names.length - 1) {
        yield const TextSpan(
          text: ", ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }
  }

  Widget _remainingPlayers(
    List<String> names,
    String ownName,
    Map<String, Direction> playerDirections,
  ) {
    return Text.rich(
      TextSpan(
        text: "The remaining players are: ",
        children: _playerNameSpans(names, ownName, playerDirections).toList(),
      ),
    );
  }

  Widget _winningPlayer(
    String name,
    String ownName,
    Map<String, Direction> playerDirections,
  ) {
    return Text.rich(
      TextSpan(
        text: "The winner is: ",
        children: [playerNameSpan(name, ownName, playerDirections[name]!)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameEnd = widget.gameEnd;
    final isAdmin = context.read<InRoomCubit>().state.room.isAdmin;
    final reason = gameEnd.gameEndReason;
    var title = "The game has ended";
    if (gameEnd.isRemainingPlayer) {
      if (gameEnd.remainingPlayers.length == 1) {
        title = "You have won";
      } else {
        if (reason == "draw") {
          title = "You have agreed to draw";
        } else if (reason == "remi") {
          title = "You have stalemated";
        }
      }
    } else {
      if (reason == "draw") {
        title = "The remaining players have agreed to draw";
      } else if (reason == "remi") {
        title = "The game is a stalemate";
      }
    }
    Widget content;
    if (gameEnd.singleWinner) {
      if (gameEnd.isRemainingPlayer) {
        content = const Text("You are the last player standing");
      } else {
        content = _winningPlayer(
          gameEnd.remainingPlayers.first,
          gameEnd.ownName,
          gameEnd.playerDirections,
        );
      }
    } else {
      content = _remainingPlayers(
        gameEnd.remainingPlayers,
        gameEnd.ownName,
        gameEnd.playerDirections,
      );
    }
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        if (!isAdmin) ...[
          SizedBox(
            width: 28,
            height: 28,
            child: ChessLoadingAnimation(pieces: playerStyles),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "waiting for next round...",
              style: TextStyle(
                color: NordColors.$4,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        OutlinedButton(
          onPressed: () {
            context.read<JoinGameCubit>().leaveGame();
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(NordColors.$7),
          ),
          child: Text("return to lobby${isAdmin ? " to start new game" : ""}"),
        ),
        OutlinedButton(
          onPressed: () async {
            final left = await showShouldLeaveDialog(context);
            if (!mounted) return;
            if (left) {
              Navigator.pop(context);
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(NordColors.aurora.red),
          ),
          child: const Text("leave room"),
        ),
      ],
    );
  }
}
