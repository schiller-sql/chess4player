import 'package:chess/blocs/in_room/in_room_cubit.dart';
import 'package:chess/ui/in_room/in_room_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/join_game/join_game_cubit.dart';

class GameEndedDialog extends StatefulWidget {
  final String gameEndReason;

  const GameEndedDialog({super.key, required this.gameEndReason});

  @override
  State<GameEndedDialog> createState() => _GameEndedDialogState();
}

class _GameEndedDialogState extends State<GameEndedDialog> {
  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<InRoomCubit>().state.room.isAdmin;
    return AlertDialog(
      title: const Text("Game has ended"),
      content: Text(widget.gameEndReason),
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
            if(!mounted) return;
            if(left) {
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
