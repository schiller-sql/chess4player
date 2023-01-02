import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

get pinTheme => PinTheme(
      borderWidth: 3,
      shape: PinCodeFieldShape.box,
      disabledColor: NordColors.$1,
      inactiveColor: NordColors.$3,
      inactiveFillColor: NordColors.$3,
      activeColor: NordColors.$2,
      activeFillColor: NordColors.$2,
      selectedColor: NordColors.$9,
      selectedFillColor: NordColors.$3,
      fieldHeight: 60 * (8/9),
      fieldWidth: 50 * (8/9),
    );
