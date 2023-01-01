part of 'join_room_cubit.dart';

@immutable
class JoinRoomState {
  final String code;
  final bool validCode;
  final bool canConnect;

  const JoinRoomState({
    required this.code,
    required this.validCode,
    required this.canConnect,
  });

  const JoinRoomState.initial()
      : this(
          code: "",
          validCode: false,
          canConnect: false,
        );

  JoinRoomState copyWith({String? code, bool? validCode, bool? canConnect}) {
    return JoinRoomState(
      code: code ?? this.code,
      validCode: validCode ?? this.validCode,
      canConnect: canConnect ?? this.canConnect,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JoinRoomState &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          validCode == other.validCode &&
          canConnect == other.canConnect;

  @override
  int get hashCode => code.hashCode ^ validCode.hashCode;
}
