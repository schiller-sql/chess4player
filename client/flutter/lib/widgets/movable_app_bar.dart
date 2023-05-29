import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

class MovableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;

  const MovableAppBar({super.key, this.title, this.leading, this.actions});

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      title: title,
      toolbarHeight: _preferredHeight,
      leading: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: leading ?? const BackButton(),
        ),
      ),
      actions: actions,
    );
    if (Platform.isWindows) {
      appBar = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ColoredBox(
            color: NordColors.$1,
            child: SizedBox(height: 18, width: double.infinity),
          ),
          appBar,
        ],
      );
    }
    return Stack(
      children: [
        appBar,
        MoveWindow(),
      ],
    );
  }

  double get _preferredHeight => kToolbarHeight; // + appWindow.titleBarHeight;

  @override
  Size get preferredSize => Size(
        double.infinity,
        (Platform.isWindows ? 18 : 0) + _preferredHeight,
      );
}
