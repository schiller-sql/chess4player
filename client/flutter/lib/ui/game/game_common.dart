import 'package:chess44/blocs/resign/resign_cubit.dart';
import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../theme/chess_theme.dart';

const _resignRouteSettings = RouteSettings(name: "resign");

class _ShouldResignDialog extends StatefulWidget {
  final ResignCubit resignCubit;

  const _ShouldResignDialog({required this.resignCubit});

  @override
  State<_ShouldResignDialog> createState() => _ShouldResignDialogState();
}

class _ShouldResignDialogState extends State<_ShouldResignDialog> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ResignCubit, ResignState>(
      bloc: widget.resignCubit,
      listener: (context, state) {
        if (!state.canResign) {
          Navigator.of(context).popUntil(
            (route) => route.settings != _resignRouteSettings,
          );
        }
      },
      child: AlertDialog(
        title: const Text(
          "Confirm leave",
          style: TextStyle(color: NordColors.$11),
        ),
        content: const Text("Do you really want to resign?"),
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
            child: const Text("resign"),
          ),
        ],
      ),
    );
  }
}

Future<bool> showShouldResignDialog(BuildContext context) async {
  final resignCubit = context.read<ResignCubit>();
  final confirmResign = await showDialog<bool>(
        routeSettings: _resignRouteSettings,
        context: context,
        useRootNavigator: false,
        builder: (context) => _ShouldResignDialog(resignCubit: resignCubit),
      ) ??
      false;
  final willResign = confirmResign && resignCubit.state.canResign;
  if (willResign) {
    resignCubit.resign();
  }
  return willResign;
}

TextSpan playerNameSpan(
    String name,
    String ownName,
    Direction playerDirection,
    ) {
  return TextSpan(
    text: name == ownName ? "you" : name,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: playerStyles.getPlayerColor(playerDirection),
    ),
  );
}
