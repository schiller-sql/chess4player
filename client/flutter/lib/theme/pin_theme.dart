import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

get pinTheme => PinTheme(
      shape: PinCodeFieldShape.box,
      inactiveColor: NordColors.$1,
      inactiveFillColor: NordColors.$1,
      activeColor: NordColors.$2,
      activeFillColor: NordColors.$2,
      selectedColor: NordColors.$3,
      selectedFillColor: NordColors.$3,
      fieldHeight: 80,
      fieldWidth: 65,
    );
