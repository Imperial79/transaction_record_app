import 'package:flutter/material.dart';

import 'commons.dart';

// bool isDark = false;

ColorScheme kColor(BuildContext context) =>
    ColorScheme.fromSeed(seedColor: Light.primary);
ColorFilter svgColor(Color color) => ColorFilter.mode(
      color,
      BlendMode.srcIn,
    );

class Light {
  static const Color scaffold = Colors.white;
  static const Color modal = Color(0xFFE0E0E0);
  static const Color card = Color(0xFFEEEEEE);
  static const Color text = Colors.black;
  static const Color primaryAccent = Color(0xFFDCEDC8);
  static const Color profitText = Color(0xFF689F38);
  static const Color lossText = Color(0xFFB71C1C);
  static const Color profitCard = Color(0xff98d3cb);
  static const Color onProfitCard = text;
  static const Color completeCard = Color(0xFFB5FFB7);
  static const Color onCompleteCard = Color(0xFF33691E);
  static const Color lossCard = Color(0xffca705f);
  static const Color onLossCard = Colors.black;
  static const Color primary = Color(0xFF33691E);
  static const Color fadeText = Colors.grey;
}

class Dark {
  static const Color scaffold = Colors.black;
  static const Color modal = Color(0xFF616161);
  static const Color card = Color(0xFF212121);
  static const Color text = Colors.white;
  static const Color primaryAccent = Color(0xFFC5E1A5);
  static const Color profitText = Color(0xFFC5E1A5);
  static const Color lossText = Color(0xFFFFCDD2);
  static const Color profitCard = Color(0xFF80CBC1);
  static const Color onProfitCard = Colors.black;
  static const Color completeCard = Color(0xFF223B05);
  static const Color onCompleteCard = Colors.lightGreenAccent;
  static const Color lossCard = Color(0xFFFF5252);
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
