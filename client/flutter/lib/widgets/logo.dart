import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Logo extends StatelessWidget {
  final double size;

  const Logo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          children: [
            WidgetSpan(
              child: SvgPicture.asset(
                "assets/chess_logo.svg",
                semanticsLabel: "chess44 logo",
                height: size,
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
