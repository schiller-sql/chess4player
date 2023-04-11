/// a library to connect with a websockets-server for four player chess in /server,
/// also contains abstract classes independent of implementation
library chess_4p_connection;

export 'src/chess_connection/chess_connection_listener.dart';
export 'src/chess_connection/chess_connection.dart';

export 'src/chess_room_repository/domain/room.dart';
export 'src/chess_room_repository/domain/room_update.dart';
export 'src/chess_room_repository/domain/room_update_type.dart';
export 'src/chess_room_repository/errors/room_join_exception.dart';
export 'src/chess_room_repository/errors/room_disbanded_exception.dart';

export 'src/chess_room_repository/chess_room_repository.dart';
export 'src/chess_room_repository/chess_room_repository_contract.dart';

export 'src/chess_connection_repository/domain/connection_error_type.dart';
export 'src/chess_connection_repository/domain/connection_status.dart';
export 'src/chess_connection_repository/domain/connection_status_type.dart';

export 'src/chess_game_start_repository/domain/game.dart';

export 'src/chess_game_start_repository/chess_game_start_repository.dart';
export 'src/chess_game_start_repository/chess_game_start_repository_contract.dart';

export 'src/chess_game_repository/domain/player.dart';
export 'src/chess_game_repository/chess_game_repository.dart';
export 'src/chess_game_repository/chess_game_repository_contract.dart';

export 'src/chess_connection_repository/chess_connection_repository.dart';
export 'src/chess_connection_repository/chess_connection_repository_contract.dart';

export 'src/chess_connection/domain/lose_reason.dart';
