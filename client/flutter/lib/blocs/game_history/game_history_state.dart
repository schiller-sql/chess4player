part of 'game_history_cubit.dart';

class ReverseSubListView<E> {
  final List<E> _baseList;
  final int start, end;
  final int length;

  const ReverseSubListView(this._baseList, this.start, this.end)
      : length = end - start;

  E operator [](int i) {
    return _baseList[end - i - 1];
  }

  const ReverseSubListView.empty() : this(const [], 0, 0);
}

@immutable
class GameHistoryState {
  final int ownPosition;
  final ReverseSubListView<BoardUpdate<LoseReason>> updates;
  final List<Player?> playersFromOwnPosition;
  final String ownName;

  GameHistoryState({
    required this.updates,
    required this.ownPosition,
    required this.playersFromOwnPosition,
  }) : ownName = playersFromOwnPosition[0]!.name;

  const GameHistoryState.empty()
      : ownPosition = 0,
        updates = const ReverseSubListView.empty(),
        playersFromOwnPosition = const [],
        ownName = "";

  Direction convertToColorDirection(Direction direction) =>
      Direction.fromInt(direction.clockwiseRotationsFromUp + ownPosition);
  String convertToName(Direction direction) =>
      playersFromOwnPosition[direction.clockwiseRotationsFromUp]!.name;
}
