import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerNameCubit extends Cubit<String> {
  static const String _nameKey = "player_name";

  final SharedPreferences preferences;

  PlayerNameCubit({required this.preferences}) : super("");

  void getNameFromPreferences() {
    emit(preferences.getString(_nameKey) ?? "");
  }

  void changeName(String newName) {
    emit(newName);
    preferences.setString(_nameKey, newName);
  }
}
