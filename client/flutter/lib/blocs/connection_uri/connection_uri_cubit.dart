import 'package:bloc/bloc.dart';
import 'package:chess44/repositories/connection_uri/connection_uri_repository.dart';

class ConnectionUriCubit extends Cubit<String> {
  final ConnectionUriRepository connectionUriRepository;

  ConnectionUriCubit({required this.connectionUriRepository}) : super("");

  void getConnectionFromPreferences() {
    emit(connectionUriRepository.currentUri);
  }

  void changeUri(String newUri) {
    connectionUriRepository.currentUri = Uri.parse(newUri).toString();
    emit(newUri);
  }
}


