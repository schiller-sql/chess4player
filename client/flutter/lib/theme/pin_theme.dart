import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

get pinTheme => PinTheme(
      borderWidth: 0,
      shape: PinCodeFieldShape.box,
      disabledColor: NordColors.$1,
      inactiveColor: Color.lerp(NordColors.$9, NordColors.$0, 0.4),
      inactiveFillColor: Color.lerp(NordColors.$9, NordColors.$0, 0.4),
      activeColor: NordColors.$9,
      activeFillColor: NordColors.$9,
      selectedColor: NordColors.$9,
      selectedFillColor: NordColors.$9,
      fieldHeight: 60 * (8/9),
      fieldWidth: 50 * (8/9),
    );
