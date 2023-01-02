import 'package:chess/blocs/room_join_error/room_join_error_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/error_dialog.dart';

class RoomJoinErrorHandler extends StatelessWidget {
  final Widget child;

  const RoomJoinErrorHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomJoinErrorCubit, RoomJoinErrorState>(
      listener: (context, state) {
        if (state is RoomJoinError) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              icon: Icons.groups,
              title: 'Could not join room',
              message: state.message,
              isRed: false,
            ),
          );
        }
      },
      child: child,
    );
  }
}
