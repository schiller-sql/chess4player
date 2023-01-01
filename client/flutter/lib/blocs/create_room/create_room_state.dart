part of 'create_room_cubit.dart';

@immutable
abstract class CreateRoomState {}

class CreateRoomInitial extends CreateRoomState {}

class CanCreateRoom extends CreateRoomState {}

class CannotCreateRoom extends CreateRoomState {}
