import 'package:chess44/blocs/connection_uri/connection_uri_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/connection/connection_cubit.dart';

void showConnectionUriChangeDialog(BuildContext context) async {
  final connectionUriCubit = context.read<ConnectionUriCubit>();
  final newUri = await showDialog<String>(
    context: context,
    builder: (_) => _ConnectionUriChangeDialog(
      startingValue: connectionUriCubit.state,
    ),
  );
  if (newUri != null) {
    connectionUriCubit.changeUri(newUri);
    if (context.mounted) {
      context.read<ConnectionCubit>().retry();
    }
  }
}

class _ConnectionUriChangeDialog extends StatefulWidget {
  final String startingValue;

  const _ConnectionUriChangeDialog({required this.startingValue});

  @override
  State<_ConnectionUriChangeDialog> createState() =>
      _ConnectionUriChangeDialogState();
}

class _ConnectionUriChangeDialogState
    extends State<_ConnectionUriChangeDialog> {
  late final TextEditingController _textEditingController;
  bool _valid = true;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.startingValue);
  }

  void _validChecker() {
    setState(() {
      _valid = Uri.tryParse(_textEditingController.text) != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit connection"),
      content: TextField(
        controller: _textEditingController,
        onChanged: (_) => _validChecker(),
        onSubmitted: (uri) {
          if (_valid) {
            Navigator.pop(context, _textEditingController.text);
          }
        },
        decoration: InputDecoration(
          hintText: "URL for chess44 server",
          errorText: _valid ? null : "not a valid URL/URI",
          fillColor: NordColors.$0,
        ),
      ),
      icon: const Icon(Icons.settings_ethernet_sharp),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(NordColors.aurora.red),
          ),
          child: const Text("cancel"),
        ),
        OutlinedButton(
          onPressed: _valid
              ? () => Navigator.pop(context, _textEditingController.text)
              : null,
          child: const Text("reconnect"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
