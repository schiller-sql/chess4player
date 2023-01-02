part of 'room_join_error_cubit.dart';

@immutable
abstract class RoomJoinErrorState {}

class RoomJoinErrorInitial extends RoomJoinErrorState {}

class RoomJoinError extends RoomJoinErrorState {
  final String message;

  RoomJoinError({required this.message});
}
