import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

class Logo extends StatelessWidget {
  final double size;

  const Logo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          children: [
            TextSpan(
              text: "♟",
              style: TextStyle(
                fontSize: (142 / 120) * size,
              ),
            ),
            TextSpan(
              text: "CHESS44",
              style: TextStyle(
                fontSize: size,
              ),
            ),
          ],
          style: const TextStyle(
            color: NordColors.$3,
            fontWeight: FontWeight.w900,
          )),
    );
  }
}
