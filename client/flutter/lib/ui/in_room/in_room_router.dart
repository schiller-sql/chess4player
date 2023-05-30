import 'package:chess44/ui/in_room/player_room_waiting_page.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../blocs/game/game_cubit.dart';
import '../../blocs/game_timer/game_timer_cubit.dart';
import '../../blocs/join_game/join_game_cubit.dart';
import '../../blocs/participants_count/participants_count_cubit.dart';
import '../game/in_game_router.dart';
import 'admin_room_lobby.dart';

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
                  ? MultiBlocProvider(providers: [
                      BlocProvider(
                        create: (context) => ParticipantsCountCubit(
                          roomRepository: context.read<ChessRoomRepository>(),
                        )..startListeningToParticipants(),
                      ),
                      BlocProvider(
                        create: (context) => GameTimerCubit(
                        )..setDefaultGameTime(),
                      ),
                    ], child: const AdminRoomLobby())
                  : const PlayerRoomWaitingPage(),
            ),
            if (state is InGameState)
              MaterialPage(
                key: ValueKey(state.game),
                child: WillPopScope(
                  onWillPop: () async => false,
                  child: RepositoryProvider(
                    create: (context) => ChessGameRepository(
                        connection: GetIt.I.get<ChessConnection>(),
                        game: state.game)
                      ..connect(),
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => GameCubit(
                            chessGameStartRepository:
                                context.read<ChessGameStartRepository>(),
                            chessGameRepository:
                                context.read<ChessGameRepository>(),
                          )..startListeningToGames(),
                        ),
                        // BlocProvider.value(
                        //   value: context.read<InRoomCubit>(),
                        // ),
                      ],
                      child: const InGameRouter(),
                    ),
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
