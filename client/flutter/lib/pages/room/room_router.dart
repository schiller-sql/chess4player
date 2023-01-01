import 'package:chess/blocs/in_room/in_room_cubit.dart';
import 'package:chess/blocs/room/room_cubit.dart';
import 'package:chess/pages/home_page/home_page.dart';
import 'package:chess/pages/in_room/room_waiting_page.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/connection_error/connection_error_cubit.dart';
import 'connection_error_page.dart';

class RoomRouter extends StatelessWidget {
  const RoomRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomCubit = context.watch<RoomCubit>();
    final roomState = roomCubit.state;
    final connectionErrorCubit = context.watch<ConnectionErrorCubit>();
    final connectionErrorState = connectionErrorCubit.state;
    return Navigator(
      pages: [
        const MaterialPage(
          child: HomePage(),
        ),
        if (roomState is InRoom)
          MaterialPage(
            child: WillPopScope(
              onWillPop: () async => false,
              child: BlocProvider(
                create: (context) => InRoomCubit(
                  roomRepository: context.read<ChessRoomRepository>(),
                )..startListeningToRoom(),
                child: const RoomWaitingPage(),
              ),
            ),
          ),
        if (connectionErrorState is ConnectionError)
          ConnectionErrorPage(message: connectionErrorState.message),
      ],
      onPopPage: (route, result) {
        return route.didPop(result);
      },
    );
  }
}
