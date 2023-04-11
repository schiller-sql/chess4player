part of 'resign_cubit.dart';

@immutable
class ResignState {
  final bool canResign;

  const ResignState({required this.canResign});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResignState &&
          runtimeType == other.runtimeType &&
          canResign == other.canResign;

  @override
  int get hashCode => canResign.hashCode;
}

