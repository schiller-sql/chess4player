import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chess44/blocs/join_game/join_game_cubit.dart';
import 'package:chess44/blocs/participants_count/participants_count_cubit.dart';
import 'package:chess44/ui/in_room/in_room_common.dart';
import 'package:chess44/ui/in_room/which_players_in_room_display.dart';
import '../../blocs/game_timer/game_timer_cubit.dart';
import "../../widgets/custom_date_picker.dart";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/in_room/in_room_cubit.dart';

class AdminRoomLobby extends StatelessWidget {
  const AdminRoomLobby({Key? key}) : super(key: key);

  Widget _buildCopyCodeButton(BuildContext context) {
    return BlocBuilder<InRoomCubit, InRoomState>(
      builder: (context, state) {
        return Tooltip(
          waitDuration: const Duration(milliseconds: 600),
          message: "copy code",
          child: OutlinedButton.icon(
            onPressed: state.stillLoading
                ? null
                : () {
              copyCode(code: state.room.code, context: context);
            },
            icon: const Icon(
              Icons.copy_sharp,
              size: 28,
            ),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              animationDuration: const Duration(milliseconds: 500),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              overlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered)) {
                  return NordColors.$9.withAlpha(36);
                }
                return Colors.transparent;
              }),
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.disabled)) {
                  return NordColors.$3;
                }
                return NordColors.$10;
              }),
            ),
            label: Text(
              "#${state.room.code}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      color: NordColors.$1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCopyCodeButton(context),
          const SizedBox(height: 24),
          const Text(
            "Players joined:",
            style: TextStyle(
              color: NordColors.$4,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          BlocBuilder<ParticipantsCountCubit, int>(
            builder: (context, count) {
              return Text(
                "$count/4",
                style: const TextStyle(
                  color: NordColors.$4,
                  fontSize: 40,
                  fontWeight: FontWeight.w200,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          const Expanded(
            child: Center(
              child: WhichPlayersInRoomDisplay(),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => showShouldLeaveDialog(context),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.all(16)),
                  overlayColor: MaterialStateProperty.resolveWith(
                        (states) {
                      if (!states
                          .contains(MaterialState.disabled)) {
                        return NordColors.$11.withAlpha(50);
                      }
                      return null;
                    },
                  ),
                ),
                child: const Text(
                  "close room",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: NordColors.$11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStartGameButton(context),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStartGameButton(BuildContext context) {
    return BlocSelector<GameTimerCubit, GameTimerState, bool>(
      selector: (state) {
        return state.isValid;
      },
      builder: (context, isValid) {
        return BlocBuilder<ParticipantsCountCubit, int>(
          builder: (context, count) {
            final enabled = isValid && count > 1;
            return TextButton(
              onPressed: enabled
                  ? () {
                final duration = context
                    .read<GameTimerCubit>()
                    .state
                    .timerDuration;
                context
                    .read<JoinGameCubit>()
                    .startGame(duration);
              }
                  : null,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    const EdgeInsets.all(16)),
                foregroundColor:
                MaterialStateProperty.resolveWith(
                      (states) {
                    if (states
                        .contains(MaterialState.disabled)) {
                      return NordColors.$3;
                    }
                    return NordColors.$7;
                  },
                ),
              ),
              child: const Text(
                "start game",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            );
          },
        )
        ;
      },
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(24).copyWith(right: 0),
        padding: const EdgeInsets.all(36),
        color: NordColors.$1,
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 24,
                color: NordColors.$4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const ColoredBox(
              color: NordColors.$3,
              child: SizedBox(
                height: 2,
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Time",
              style: TextStyle(
                fontSize: 20,
                color: NordColors.$4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              width: 200,
              child: Stack(
                children: [
                  CupertinoTimerPicker(
                    initialTimerDuration:
                    const Duration(minutes: 15),
                    alignment: Alignment.topLeft,
                    mode: CupertinoTimerPickerMode.ms,
                    onTimerDurationChanged: (Duration time) {
                      context
                          .read<GameTimerCubit>()
                          .setNewGameTimerDuration(time);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 28,
            child: MoveWindow(),
          ),
          const Text(
            "Room admin",
            style: TextStyle(
              color: NordColors.$4,
              fontWeight: FontWeight.w500,
              fontSize: 28,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildLeftColumn(context),
                _buildRightColumn(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//TODO: wierd switches that cannot be completeely turned off pretending
