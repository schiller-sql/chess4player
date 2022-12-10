import 'package:chess/theme/pin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 200,
                child: TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(16),
                  ],
                  decoration: const InputDecoration(
                    hintText: "Name",
                    suffixIcon: Icon(Icons.edit),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text(
                    "Create room",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const ColoredBox(
                  color: NordColors.$1,
                  child: SizedBox(
                    width: 700,
                    height: 4,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 600,
                  child: Theme(
                    data: ThemeData(),
                    child: PinCodeTextField(
                      autoUnfocus: false,
                      textStyle:
                          const TextStyle(fontSize: 50, color: NordColors.$4),
                      cursorColor: Colors.transparent,
                      enableActiveFill: true,
                      pinTheme: pinTheme,
                      onChanged: (String value) {},
                      length: 6,
                      appContext: context,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text(
                    "Join with code",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
