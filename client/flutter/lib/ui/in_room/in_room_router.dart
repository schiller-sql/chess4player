import 'package:chess/ui/in_room/player_room_waiting_page.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../blocs/join_game/join_game_cubit.dart';
import '../../blocs/participants_count/participants_count_cubit.dart';
import 'admin_room_lobby.dart';
import '../game/in_game_page.dart';

class InRoomRouter extends StatelessWidget {
  final bool adminGame;

  const InRoomRouter({required this.adminGame, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JoinGameCubit, JoinGameState>(
      builder: (context, state) {
        return Navigator(
          pages: [
            MaterialPage(
              child: adminGame
                  ? BlocProvider(
                      create: (context) => ParticipantsCountCubit(
                        roomRepository: context.read<ChessRoomRepository>(),
                      )..startListeningToParticipants(),
                      child: const AdminRoomLobby(),
                    )
                  : const PlayerRoomWaitingPage(),
            ),
            if (state is InGameState)
              MaterialPage(
                key: ValueKey(state.game),
                child: WillPopScope(
                  onWillPop: () async => false,
                  child: RepositoryProvider(
                    create: (context) {
                      // TODO: for test purposes
                      print("hahahahahahhahahah");
                      return ChessGameRepository(
                        connection: GetIt.I.get<ChessConnection>(),
                        game: state.game)..connect();
                    },
                    child: const InGamePage(),
                  ),
                ),
              ),
          ],
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        );
      },
    );
  }
}
