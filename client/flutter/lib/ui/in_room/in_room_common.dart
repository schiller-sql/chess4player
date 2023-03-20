import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/in_room/in_room_cubit.dart';
import '../../blocs/room/room_cubit.dart';

void copyCode({required String code, required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 750),
      content: RichText(
        text: const TextSpan(
          children: [
            WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.check,
                  size: 14,
                ),
              ),
            ),
            TextSpan(text: "copied"),
          ],
        ),
      ),
    ),
  );
  Future.microtask(
    () {
      Clipboard.setData(
        ClipboardData(text: code),
      );
    },
  );
}


Widget _buildShouldLeaveDialog(BuildContext context, bool isAdmin) {
  final Widget content;
  if (isAdmin) {
    content = const Text("After you, the admin, leaves this room,\n"
        "it is closed permanently for everyone\nand cannot be rejoined.");
  } else {
    content = const Text("Do you really want to leave this room?");
  }
  return AlertDialog(
    title: const Text(
      "Confirm leave",
      style: TextStyle(color: NordColors.$11),
    ),
    content: content,
    actions: [
      OutlinedButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text("cancel"),
      ),
      OutlinedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(NordColors.$11),
        ),
        child: const Text("leave"),
      ),
    ],
  );
}

Future<bool> showShouldLeaveDialog(BuildContext context, ) async {
  final inRoomCubit = context.read<InRoomCubit>();
  final roomCubit = context.read<RoomCubit>();
  final confirmLeave = await showDialog<bool>(
    context: context,
    useRootNavigator: false,
    builder: (context) => _buildShouldLeaveDialog(
      context,
      inRoomCubit.state.room.isAdmin,
    ),
  ) ??
      false;
  if (confirmLeave) {
    roomCubit.leave();
  }
  return confirmLeave;
}