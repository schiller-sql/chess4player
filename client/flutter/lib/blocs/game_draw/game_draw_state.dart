part of 'game_draw_cubit.dart';

@immutable
class GameDrawState {
  final bool didAcceptDraw;
  final bool didLose;
  bool get canDraw => !didAcceptDraw && !didLose;

  const GameDrawState({
    this.didAcceptDraw = false,
    this.didLose = false,
  });
}
