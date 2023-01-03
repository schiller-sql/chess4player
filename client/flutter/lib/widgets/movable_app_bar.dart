import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class MovableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;

  const MovableAppBar({super.key, this.title, this.leading, this.actions});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
          // foregroundColor: NordColors.$10,
          title: title,
          toolbarHeight: _preferredHeight,
          leading: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: leading ?? const BackButton(),
            ),
          ),
          actions: actions,
        ),
        MoveWindow(),
      ],
    );
  }

  double get _preferredHeight => kToolbarHeight;// + appWindow.titleBarHeight;

  @override
  Size get preferredSize => Size(
        double.infinity,
        _preferredHeight,
      );
}
