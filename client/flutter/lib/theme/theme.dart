import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

ThemeData get fPlotTheme => ThemeData.from(
      colorScheme: const ColorScheme(
        primary: NordColors.$1,
        onPrimary: NordColors.$4,
        secondary: NordColors.$8,
        onSecondary: NordColors.$6,
        background: NordColors.$0,
        onBackground: NordColors.$4,
        surface: NordColors.$1,
        onSurface: NordColors.$5,
        error: NordColors.$11,
        onError: NordColors.$5,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        titleSmall: TextStyle(
          fontSize: 14,
          color: NordColors.$3,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: NordColors.$11,
        ),
      ).apply(
        bodyColor: NordColors.$5,
        displayColor: NordColors.$0,
      ),
      useMaterial3: true,
    ).copyWith(
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: NordColors.$10,
  ),
      primaryIconTheme: const IconThemeData(
        color: NordColors.$9,
      ),
      textTheme: const TextTheme(
        subtitle1: TextStyle(
          color: NordColors.$10,
        ),
      ),
      primaryTextTheme: const TextTheme(
        subtitle1: TextStyle(
          color: NordColors.$10,
        ),
      ),
      appBarTheme: const AppBarTheme(
        toolbarHeight: 42,
        foregroundColor: NordColors.$10,
        iconTheme: IconThemeData(color: NordColors.$10),
        actionsIconTheme: IconThemeData(color: NordColors.$10),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(NordColors.$0),
        fillColor: MaterialStateProperty.all(NordColors.$10),
        shape: const ContinuousRectangleBorder(),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: NordColors.$10,
        ),
        textStyle: TextStyle(color: NordColors.$6),
      ),
      dividerTheme: const DividerThemeData(
        color: NordColors.$1,
        thickness: 3,
        space: 3,
      ),
      dialogTheme: const DialogTheme(
        shape: ContinuousRectangleBorder(),
        backgroundColor: NordColors.$1,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: NordColors.$10,
        selectionColor: NordColors.$9,
      ),
      disabledColor: NordColors.$10,
      splashColor: NordColors.$3,
      splashFactory: InkSplash.splashFactory,
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        filled: true,
        hoverColor: NordColors.$2,
        fillColor: NordColors.$1,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.zero),
          borderSide: BorderSide(width: 2, color: NordColors.$10),
        ),
        iconColor: NordColors.$10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.zero),
          borderSide: BorderSide.none,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(const ContinuousRectangleBorder()),
          splashFactory: InkSplash.splashFactory,
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.focused)) {
              return NordColors.$2;
            }
            return NordColors.$3;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return NordColors.$1;
            }
            return NordColors.$8;
          }),
          shape: MaterialStateProperty.all(const ContinuousRectangleBorder()),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return NordColors.$0;
            }
            return NordColors.$1;
          }),
          side: MaterialStateProperty.all(BorderSide.none),
          padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
        ),
      ),
    );
