import 'dart:io';

import 'package:chess44/widgets/ms_window_buttons.dart';
import 'package:flutter/material.dart';

class MSWindowButtonsFixWrapper extends StatelessWidget {
  final Widget child;

  const MSWindowButtonsFixWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    if(Platform.isWindows) {
      return Stack(
        children: [
          child,
          const MSWindowButtons(),
        ],
      );
    }
    return child;
  }
}
