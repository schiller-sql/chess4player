import 'package:chess/blocs/join_room/join_room_cubit.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/connection/connection_cubit.dart';
import 'blocs/connection_error/connection_error_cubit.dart';
import 'blocs/create_room/create_room_cubit.dart';
import 'blocs/player_name/player_name_cubit.dart';
import 'blocs/room/room_cubit.dart';
import 'pages/room/room_router.dart';
import 'theme/theme.dart';

class Chess4pApp extends StatelessWidget {
  const Chess4pApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chess 44',
      theme: fPlotTheme,
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => ChessConnectionRepository(
              connection: GetIt.I.get<ChessConnection>(),
            ),
          ),
          RepositoryProvider(
            create: (context) => ChessRoomRepository(
              connection: GetIt.I.get<ChessConnection>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              lazy: false,
              create: (context) => ConnectionCubit(
                connectionRepository: context.read<ChessConnectionRepository>(),
                roomRepository: context.read<ChessRoomRepository>(),
              )..startConnection(),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => RoomCubit(
                roomRepository: context.read<ChessRoomRepository>(),
              )..startListeningToRoom(),
            ),
            BlocProvider(
              create: (context) => PlayerNameCubit(
                preferences: GetIt.I.get<SharedPreferences>(),
              )..getNameFromPreferences(),
            ),
            BlocProvider(
              create: (context) => CreateRoomCubit(
                roomRepository: context.read<ChessRoomRepository>(),
                connectionRepository: context.read<ChessConnectionRepository>(),
              )..startListeningToConnection(),
            ),
            BlocProvider(
              create: (context) => JoinRoomCubit(
                roomRepository: context.read<ChessRoomRepository>(),
                connectionRepository: context.read<ChessConnectionRepository>(),
              )..startListeningToConnection(),
            ),
            BlocProvider(
              create: (context) => ConnectionErrorCubit(
                connectionRepository: context.read<ChessConnectionRepository>(),
              )..startListeningToConnection(),
            ),
          ],
          child: const RoomRouter(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
