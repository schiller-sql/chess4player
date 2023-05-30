import 'package:chess44/blocs/in_room/in_room_cubit.dart';
import 'package:chess44/blocs/join_game/join_game_cubit.dart';
import 'package:chess44/blocs/room/room_cubit.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../in_room/in_room_router.dart';
import '../home_page/home_page.dart';

class RoomRouter extends StatelessWidget {
  const RoomRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomState>(
      builder: (context, state) {
        return Navigator(
          pages: [
            const MaterialPage(
              child: HomePage(),
            ),
            if (state is InRoom)
              MaterialPage(
                child: WillPopScope(
                  onWillPop: () async => false,
                  child: RepositoryProvider(
                    create: (context) => ChessGameStartRepository(
                      connection: GetIt.I.get<ChessConnection>(),
                      playerName: state.room.playerName,
                    ),
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => JoinGameCubit(
                            gameStartRepository:
                                context.read<ChessGameStartRepository>(),
                          )..startListeningToGames(),
                        ),
                        BlocProvider(
                          create: (context) => InRoomCubit(
                            roomRepository: context.read<ChessRoomRepository>(),
                          )..startListeningToRoom(),
                        ),
                      ],
                      child: InRoomRouter(adminGame: state.room.isAdmin),
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
