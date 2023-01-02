part of 'room_error_cubit.dart';

@immutable
abstract class RoomErrorState {}

class RoomErrorInitial extends RoomErrorState {}

class CouldNotGetInRoomError extends RoomErrorState {
  final String message;

  CouldNotGetInRoomError({required this.message});
}

class RoomDisbandedError extends RoomErrorState {}
