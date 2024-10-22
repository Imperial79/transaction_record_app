import 'package:flutter/material.dart';

import 'commons.dart';

bool isDark = false;
ColorFilter svgColor(Color color) => ColorFilter.mode(
      color,
      BlendMode.srcIn,
    );

class Light {
  static const Color scaffold = Colors.white;
  static final Color modal = Colors.grey.shade300;
  static final Color card = Colors.grey.shade200;
  static const Color text = Colors.black;
  static final Color primaryAccent = Colors.lightGreen.shade900;
  static final Color profitText = Colors.lightGreen.shade700;
  static final Color lossText = Colors.red.shade900;
  static const Color profitCard = Color(0xff98d3cb);
  static const Color onProfitCard = text;
  static const Color completeCard = Color(0xFFB5FFB7);
  static final Color onCompleteCard = Colors.lightGreen.shade900;
  static const Color lossCard = Color(0xffca705f);
  static const Color onLossCard = primary;
  static const Color primary = Colors.black;
  static const Color fadeText = Colors.grey;
}

class Dark {
  static const Color scaffold = Colors.black;
  static final Color modal = Colors.grey.shade700;
  static final Color card = Colors.grey.shade900;
  static const Color text = Colors.white;
  static final Color primaryAccent = Colors.lightGreen.shade200;
  static final Color profitText = Colors.lightGreen.shade200;
  static final Color lossText = Colors.red.shade100;
  static const Color profitCard = Color(0xFF80CBC1);
  static const Color onProfitCard = Colors.black;
  static const Color completeCard = Color(0xFF223B05);
  static const Color onCompleteCard = Colors.lightGreenAccent;
  static final Color lossCard = Colors.redAccent.shade200;
  static const Color onLossCard = text;
  static const Color primary = Color(0xff98d3cb);
  static const Color fadeText = Colors.grey;
}

// --------- CUSTOM THEMEDATA --------------

class KThemeData {
  static ThemeData light() => ThemeData(
        fontFamily: 'Product',
        useMaterial3: true,
        scaffoldBackgroundColor: Light.scaffold,
        brightness: Brightness.light,
        colorSchemeSeed: Light.profitCard,
        cardTheme: CardTheme(
          elevation: 0,
          color: Light.card,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: kRadius(20),
          ),
        ),
        primaryColorLight: Light.profitCard,
        primaryColorDark: Dark.profitCard,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Light.primary,
              foregroundColor: Colors.white),
        ),
      );
  static ThemeData dark() => ThemeData(
        fontFamily: 'Product',
        useMaterial3: true,
        scaffoldBackgroundColor: Dark.scaffold,
        brightness: Brightness.dark,
        cardColor: Dark.card,
        cardTheme: CardTheme(
          elevation: 0,
          color: Dark.card,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: kRadius(20),
          ),
        ),
        textTheme: const TextTheme(
          labelLarge: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
        ),
        colorSchemeSeed: Dark.profitCard,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Dark.primary,
              foregroundColor: Colors.black),
        ),
      );
}
