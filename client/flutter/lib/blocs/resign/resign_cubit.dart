import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'resign_state.dart';

class ResignCubit extends Cubit<ResignState> with DefaultChessGameRepositoryListener {
  final IChessGameRepository chessGameRepository;

  ResignCubit({
    required this.chessGameRepository,
  }) : super(const ResignState(canResign: true));

  void startListeningToGame() {
    chessGameRepository.addListener(this);
  }

  void resign() {
    emit(const ResignState(canResign: false));
    chessGameRepository.resign();
  }

  @override
  void changed(IChessGameRepository chessGameRepository) {
    final hasLost = chessGameRepository.playersFromOwnPerspective[0]!.isOut;
    emit(ResignState(canResign: !hasLost));
  }

  @override
  Future<void> close() {
    chessGameRepository.removeListener(this);
    return super.close();
  }
}
