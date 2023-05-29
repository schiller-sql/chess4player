import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

class MSWindowButtons extends StatefulWidget {
  const MSWindowButtons({Key? key}) : super(key: key);

  @override
  MSWindowButtonsState createState() => MSWindowButtonsState();
}

class MSWindowButtonsState extends State<MSWindowButtons> {
  static final _buttonColors = WindowButtonColors(
    iconNormal: NordColors.$3,
    iconMouseOver: NordColors.$6,
    iconMouseDown: NordColors.$4,
    mouseOver: NordColors.$1,
    mouseDown: NordColors.$2,
  );

  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MinimizeWindowButton(colors: _buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                onPressed: maximizeOrRestore, colors: _buttonColors)
            : MaximizeWindowButton(
                onPressed: maximizeOrRestore, colors: _buttonColors),
        CloseWindowButton(colors: _buttonColors),
      ],
    );
  }
}
