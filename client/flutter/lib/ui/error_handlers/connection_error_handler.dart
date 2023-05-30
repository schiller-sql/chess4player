import 'package:chess44/blocs/connection_error/connection_error_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/error_dialog.dart';

class ConnectionErrorHandler extends StatelessWidget {
  final Widget child;

  const ConnectionErrorHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionErrorCubit, ConnectionErrorState>(
      listener: (context, state) {
        if (state is ConnectionError) {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) => const ErrorDialog(
              icon: Icons.warning,
              title: 'Connection error',
              message: "A connection error has occurred, "
                  "please check your internet connection.",
            ),
          );
        }
      },
      child: child,
    );
  }
}
