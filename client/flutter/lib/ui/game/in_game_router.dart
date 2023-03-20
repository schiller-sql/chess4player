import 'package:chess/ui/game/game_ended_dialog.dart';
import 'package:chess/ui/game/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/game/game_cubit.dart';
import '../../blocs/in_room/in_room_cubit.dart';
import '../../blocs/join_game/join_game_cubit.dart';
import '../../blocs/room/room_cubit.dart';

class InGameRouter extends StatelessWidget {
  const InGameRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(
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
            child: const GamePage(),
          ),
        ),
      ],
    );
  }
}
