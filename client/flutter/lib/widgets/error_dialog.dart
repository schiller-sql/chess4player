import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

class ErrorDialog extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String message;
  final bool isRed;

  const ErrorDialog({
    Key? key,
    this.icon,
    required this.title,
    required this.message,
    this.isRed = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isRed ? NordColors.$11 : NordColors.$13;
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints.tightForFinite(width: 300),
        child: Text(message, textAlign: TextAlign.center),
      ),
      icon: icon != null ? Icon(icon, size: 64, color: color) : null,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color),
          ),
          child: const Text("ok"),
        ),
      ],
    );
  }
}
