import 'package:chess/blocs/in_room/in_room_cubit.dart';
import 'package:chess/blocs/room/room_cubit.dart';
import 'package:chess/theme/chess_theme.dart';
import 'package:chess/widgets/animation/chess_loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoomWaitingPage extends StatelessWidget {
  const RoomWaitingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InRoomCubit, InRoomState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.animation),
              onPressed: () {
                context.read<RoomCubit>().leave();
              },
            ),
          ),
          body: Column(
            children: [
              Text(state.toString()),
              ChessLoadingAnimation(
                size: 75,
                pieces: pieceSet,
              ),
            ],
          ),
        );
      },
    );
  }
}
