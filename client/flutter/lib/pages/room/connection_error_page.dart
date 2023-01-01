import 'package:chess/blocs/connection_error/connection_error_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

class ConnectionErrorPage extends Page<void> {
  final String message;

  const ConnectionErrorPage({required this.message});

  @override
  Route<void> createRoute(BuildContext context) {
    return DialogRoute(
      settings: this,
      context: context,
      builder: (context) {
        return const ConnectionErrorAlert();
      },
    );
  }
}

class ConnectionErrorAlert extends StatelessWidget {
  const ConnectionErrorAlert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: NordColors.$11),
      child: AlertDialog(
        title: const Text(
          "Connection error",
          style: TextStyle(color: NordColors.$11),
        ),
        content: const Text(
          "A connection error has occurred, "
          "please check your internet connection",
        ),
        icon: const Icon(Icons.warning, size: 64, color: NordColors.$11),
        actions: [
          OutlinedButton(
            onPressed: () =>
                context.read<ConnectionErrorCubit>().clickErrorAway(),
            child: const Text("ok"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(NordColors.$11),
            ),
          ),
        ],
      ),
    );
  }
}
