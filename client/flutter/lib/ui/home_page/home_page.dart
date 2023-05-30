import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chess44/blocs/connection/connection_cubit.dart';
import 'package:chess44/blocs/connection_uri/connection_uri_cubit.dart';
import 'package:chess44/blocs/player_name/player_name_cubit.dart';
import 'package:chess44/theme/pin_theme.dart';
import 'package:chess44/ui/connection_uri_change/connection_uri_change_dialog.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../blocs/create_room/create_room_cubit.dart';
import '../../blocs/join_room/join_room_cubit.dart';
import '../../widgets/logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<PlayerNameCubit>().state,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  Widget _iconForConnectionStatus(ConnectionStatus status) {
    switch (status.type) {
      case ConnectionStatusType.connected:
        return const Icon(Icons.wifi, color: NordColors.$0);
      case ConnectionStatusType.loading:
        return const SizedBox.square(
          dimension: 24,
          child: CupertinoActivityIndicator(color: NordColors.$0),
        );
      case ConnectionStatusType.error:
        if (status.errorType == ConnectionErrorType.couldNotConnect) {
          return const Icon(Icons.wifi_off, color: NordColors.$4);
        }
        return const Icon(Icons.warning, color: NordColors.$4);
      default:
        throw StateError("message");
    }
  }

  Color _colorForConnectionStatus(ConnectionStatus status) {
    switch (status.type) {
      case ConnectionStatusType.connected:
        return NordColors.$10;
      case ConnectionStatusType.loading:
        return NordColors.$2;
      case ConnectionStatusType.error:
        return NordColors.$11;
      default:
        throw StateError("message");
    }
  }

  String _textForConnectionStatus(ConnectionStatus status) {
    switch (status.type) {
      case ConnectionStatusType.connected:
        return "connected";
      case ConnectionStatusType.loading:
        return "loading...";
      case ConnectionStatusType.error:
        if (status.errorType == ConnectionErrorType.couldNotConnect) {
          return "could not connect";
        }
        return "connection error";
      default:
        throw StateError("message");
    }
  }

  Widget _buildConnectionStatusShow() {
    return Align(
      alignment: Alignment.topRight,
      child: BlocBuilder<ConnectionCubit, ConnectionStatus>(
        builder: (context, status) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<ConnectionUriCubit, String>(
                    builder: (context, connectionUri) {
                      return Tooltip(
                        message: connectionUri,
                        decoration: BoxDecoration(
                          color: _colorForConnectionStatus(status),
                        ),
                        child: AnimatedContainer(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                          color: _colorForConnectionStatus(status),
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _iconForConnectionStatus(status),
                              const SizedBox(width: 4),
                              Text(
                                _textForConnectionStatus(status),
                                style: TextStyle(
                                  color: status.type == ConnectionStatusType.error
                                      ? NordColors.$4
                                      : NordColors.$0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: _colorForConnectionStatus(status),
                    tooltip: "edit server",
                    onPressed: () => showConnectionUriChangeDialog(context),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              AnimatedOpacity(
                opacity: status.type == ConnectionStatusType.error ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.refresh,
                    color: NordColors.$11,
                  ),
                  label: const Text(
                    "try again",
                    style: TextStyle(color: NordColors.$11),
                  ),
                  onPressed: () {
                    context.read<ConnectionCubit>().retry();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNameTextField() {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 200,
        child: TextField(
          controller: _nameController,
          onChanged: (val) {
            context.read<PlayerNameCubit>().changeName(val);
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(16),
          ],
          decoration: const InputDecoration(
            hintText: "Name",
            suffixIcon: Icon(Icons.account_circle),
          ),
        ),
      ),
    );
  }

  static const _createRoomText = Text(
    "Create a new chess room for others to join and be its admin",
    style: TextStyle(
      color: NordColors.$8,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _buildCreateRoomButton() {
    return BlocBuilder<CreateRoomCubit, CreateRoomState>(
      builder: (context, state) {
        late final bool canCreateRoom;
        if (state is CannotCreateRoom) {
          canCreateRoom = false;
        } else if (state is CanCreateRoom) {
          canCreateRoom = true;
        } else {
          throw StateError("initial state should not be given");
        }
        return OutlinedButton(
          onPressed: canCreateRoom
              ? () {
                  final playerName = context.read<PlayerNameCubit>().state;
                  context
                      .read<CreateRoomCubit>()
                      .createRoom(playerName: playerName);
                }
              : null,
          child: const Text(
            "Create room",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      },
    );
  }

  static const _joinRoomText = Text(
    "Join a chess room by inputting its code in the field below",
    style: TextStyle(
      color: NordColors.$9,
      fontWeight: FontWeight.w600,
    ),
  );

  static final _roomCodeFieldFormatters = [
    TextInputFormatter.withFunction(
      (oldValue, newValue) => newValue.copyWith(
        text: newValue.text.toUpperCase(),
      ),
    ),
    FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]")),
  ];

  Widget _buildJoinRoomCodeField() {
    return SizedBox(
      width: 340,
      child: Theme(
        data: ThemeData(),
        child: BlocBuilder<JoinRoomCubit, JoinRoomState>(
          builder: (context, state) {
            return PinCodeTextField(
              autoFocus: true,
              beforeTextPaste: (_) => false,
              enablePinAutofill: false,
              autoUnfocus: false,
              inputFormatters: _roomCodeFieldFormatters,
              textStyle: const TextStyle(
                fontSize: 36,
                color: NordColors.$9,
                fontWeight: FontWeight.w800,
              ),
              cursorColor: Colors.transparent,
              enableActiveFill: true,
              pinTheme: pinTheme,
              enabled: state.canConnect,
              onChanged: (value) {
                context.read<JoinRoomCubit>().updateCode(value);
              },
              length: 6,
              appContext: context,
            );
          },
        ),
      ),
    );
  }

  Widget _buildJoinRoomButton() {
    return BlocBuilder<JoinRoomCubit, JoinRoomState>(
      builder: (context, state) {
        return OutlinedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) {
                if (!states.contains(MaterialState.disabled)) {
                  return NordColors.$9;
                }
                return null;
              },
            ),
          ),
          onPressed: state.validCode && state.canConnect
              ? () {
                  final playerName = context.read<PlayerNameCubit>().state;
                  context.read<JoinRoomCubit>().joinRoom(playerName);
                }
              : null,
          child: const Text(
            "Join with code",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WindowTitleBarBox(child: MoveWindow()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32).copyWith(
                top: max(32 - appWindow.titleBarHeight, 0),
              ),
              child: Stack(
                children: [
                  _buildNameTextField(),
                  _buildConnectionStatusShow(),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Logo(size: 120),
                        const SizedBox(height: 32),
                        _createRoomText,
                        const SizedBox(height: 8),
                        _buildCreateRoomButton(),
                        const SizedBox(height: 24),
                        const ColoredBox(
                          color: NordColors.$3,
                          child: SizedBox(
                            width: 500,
                            height: 4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _joinRoomText,
                        const SizedBox(height: 8),
                        _buildJoinRoomCodeField(),
                        _buildJoinRoomButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
