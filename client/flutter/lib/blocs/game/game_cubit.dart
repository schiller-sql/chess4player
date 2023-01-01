import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameInitial());
}
