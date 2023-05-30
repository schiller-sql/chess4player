import 'package:chess44/blocs/join_room/join_room_cubit.dart';
import 'package:chess44/repositories/connection_uri/connection_uri_repository.dart';
import 'package:chess44/ui/error_handlers/connection_error_handler.dart';
import 'package:chess44/ui/error_handlers/room_error_handler.dart';
import 'package:chess44/widgets/ms_window_buttons_fix_wrapper.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/connection/connection_cubit.dart';
import 'blocs/connection_error/connection_error_cubit.dart';
import 'blocs/connection_uri/connection_uri_cubit.dart';
import 'blocs/create_room/create_room_cubit.dart';
import 'blocs/player_name/player_name_cubit.dart';
import 'blocs/room/room_cubit.dart';
import 'blocs/room_error/room_error_cubit.dart';
import 'ui/room/room_router.dart';
import 'theme/theme.dart';

class Chess4pApp extends StatelessWidget {
  final ConnectionUriRepository connectionUriRepository;

  const Chess4pApp({
    Key? key,
    required this.connectionUriRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chess 44',
      theme: fPlotTheme,
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(
            value: connectionUriRepository,
          ),
          RepositoryProvider(
            lazy: false,
            create: (context) => ChessConnectionRepository(
              connection: GetIt.I.get<ChessConnection>(),
            ),
          ),
          RepositoryProvider(
            lazy: false,
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
                connectionUriRepository:
                    context.read<ConnectionUriRepository>(),
              )..startConnection(),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => RoomCubit(
                roomRepository: context.read<ChessRoomRepository>(),
              )..startListeningToRoom(),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => PlayerNameCubit(
                preferences: GetIt.I.get<SharedPreferences>(),
              )..getNameFromPreferences(),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => ConnectionUriCubit(
                connectionUriRepository:
                    context.read<ConnectionUriRepository>(),
              )..getConnectionFromPreferences(),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => CreateRoomCubit(
                roomRepository: context.read<ChessRoomRepository>(),
                connectionRepository: context.read<ChessConnectionRepository>(),
              )..startListeningToConnection(),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => JoinRoomCubit(
                roomRepository: context.read<ChessRoomRepository>(),
                connectionRepository: context.read<ChessConnectionRepository>(),
              )..startListeningToConnection(),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => ConnectionErrorCubit(
                connectionRepository: context.read<ChessConnectionRepository>(),
              )..startListeningToConnection(),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => RoomErrorCubit(
                roomRepository: context.read<ChessRoomRepository>(),
              )..startListeningToRoom(),
            ),
          ],
          child: const RoomJoinErrorHandler(
            child: ConnectionErrorHandler(
              child: MSWindowButtonsFixWrapper(
                child: RoomRouter(),
              ),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
