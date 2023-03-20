import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/room_error/room_error_cubit.dart';
import '../../widgets/error_dialog.dart';

class RoomJoinErrorHandler extends StatelessWidget {
  final Widget child;

  const RoomJoinErrorHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomErrorCubit, RoomErrorState>(
      listener: (context, state) {
        if (state is CouldNotGetInRoomError) {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) => ErrorDialog(
              icon: Icons.groups,
              title: 'Could not join room',
              message: state.message,
              isRed: false,
            ),
          );
        } else if (state is RoomDisbandedError) {
          showDialog(
            context: context,
            builder: (context) => const ErrorDialog(
              title: 'Room was closed',
              message: 'The room was closed by the admin.',
              isRed: false,
            ),
          );
        }
      },
      child: child,
    );
  }
}
