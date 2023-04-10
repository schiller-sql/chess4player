import 'package:chess/blocs/in_room/in_room_cubit.dart';
import 'package:chess/theme/chess_theme.dart';
import 'package:chess/ui/in_room/in_room_common.dart';
import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/game/game_cubit.dart';
import '../../blocs/join_game/join_game_cubit.dart';

class GameEndedDialog extends StatefulWidget {
  final GameHasEnded gameEnd;

  const GameEndedDialog({super.key, required this.gameEnd});

  @override
  State<GameEndedDialog> createState() => _GameEndedDialogState();
}

class _GameEndedDialogState extends State<GameEndedDialog> {
  TextSpan _playerNameSpan(
    String name,
    String ownName,
    Map<String, Direction> playerDirections,
  ) {
    return TextSpan(
      text: name == ownName ? "you" : name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: playerStyles.getPlayerColor(playerDirections[name]),
      ),
    );
  }

  Iterable<TextSpan> _playerNameSpans(
    List<String> names,
    String ownName,
    Map<String, Direction> playerDirections,
  ) sync* {
    for (var i = 0; i < names.length; i++) {
      yield _playerNameSpan(names[i], ownName, playerDirections);
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
        children: [_playerNameSpan(name, ownName, playerDirections)],
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
      if(gameEnd.isRemainingPlayer) {
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
        if (isAdmin)
          OutlinedButton(
            onPressed: () {
              context.read<JoinGameCubit>().leaveGame();
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(NordColors.$7),
            ),
            child: const Text("return to room"),
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
