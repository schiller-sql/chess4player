import 'package:chess44/blocs/in_room/in_room_cubit.dart';
import 'package:chess44/theme/chess_theme.dart';
import 'package:chess44/ui/in_room/in_room_common.dart';
import 'package:chess44/widgets/animation/chess_loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess_4p/flutter_4p_chess.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../widgets/movable_app_bar.dart';

class PlayerRoomWaitingPage extends StatelessWidget {
  const PlayerRoomWaitingPage({Key? key}) : super(key: key);

  Widget _buildTitle() {
    return BlocBuilder<InRoomCubit, InRoomState>(builder: (context, state) {
      if (state.stillLoading) {
        return const Text("Loading room...");
      }
      return const Text("Waiting for admin to start the game...");
    });
  }



  Widget _buildLeaveRoomButton(BuildContext context) {
    return IconButton(
      tooltip: "leave room",
      color: NordColors.$10,
      icon: const Icon(Icons.logout),
      onPressed: () => showShouldLeaveDialog(context),
    );
  }

  Widget _buildRoomCodeDisplay() {
    return Expanded(
      child: Center(
        child: BlocBuilder<InRoomCubit, InRoomState>(
          builder: (context, state) {
            return Wrap(
              children: [
                Text(
                  "Room code: ${state.room.code}",
                  style: const TextStyle(
                    color: NordColors.$3,
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                  ),
                ),
                IconButton(
                  tooltip: "copy code",
                  icon: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Icon(
                      Icons.copy_sharp,
                      color: NordColors.$3,
                      size: 36,
                    ),
                  ),
                  onPressed: state.stillLoading
                      ? null
                      : () {
                          copyCode(code: state.room.code, context: context);
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return SizedBox.square(
      dimension: 300,
      child: EmptyChessBoard(
        color1: NordColors.$3,
        color2: NordColors.$2,
        child: Center(
          child: ChessLoadingAnimation(
            pieces: playerStyles,
            size: 150,
          ),
        ),
      ),
    );
  }

  Widget _buildNameDisplay() {
    return Expanded(
      child: Center(
        child: BlocBuilder<InRoomCubit, InRoomState>(
          builder: (context, state) {
            return Text(
              "Joining as: ${state.room.playerName}",
              style: const TextStyle(
                color: NordColors.$3,
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MovableAppBar(
        title: _buildTitle(),
        leading: const SizedBox(),
        actions: [
          _buildLeaveRoomButton(context),
        ],
      ),
      body: Column(
        children: [
          _buildRoomCodeDisplay(),
          _buildLoader(),
          _buildNameDisplay(),
        ],
      ),
    );
  }
}
