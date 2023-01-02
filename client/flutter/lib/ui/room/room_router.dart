import 'package:chess/blocs/in_room/in_room_cubit.dart';
import 'package:chess/blocs/room/room_cubit.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home_page/home_page.dart';
import '../in_room/room_waiting_page.dart';

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
                  child: BlocProvider(
                    create: (context) =>
                    InRoomCubit(
                      roomRepository: context.read<ChessRoomRepository>(),
                    )
                      ..startListeningToRoom(),
                    child: const RoomWaitingPage(),
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
