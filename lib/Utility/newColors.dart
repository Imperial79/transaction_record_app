import 'package:flutter/material.dart';
import 'commons.dart';

extension ColorUtils on Color {
  Color lighten([double opacity = .15]) {
    return kOpacity(this, opacity);
  }

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

extension ThemeColors on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryColor => colorScheme.primary;
  Color get scaffoldColor => Theme.of(this).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(this).cardTheme.color ?? colorScheme.surface;

  // Semantic Colors
  Color get profitColor => isDarkMode ? Dark.profitText : Light.profitText;
  Color get lossColor => isDarkMode ? Dark.lossText : Light.lossText;
  Color get profitCardColor => isDarkMode ? Dark.profitCard : Light.profitCard;
  Color get lossCardColor => isDarkMode ? Dark.lossCard : Light.lossCard;
  Color get fadeTextColor =>
      isDarkMode ? Dark.fadeText : const Color.fromARGB(255, 98, 98, 98);
}

Color kOpacity(Color color, double opacity) =>
    color.withAlpha((opacity * 255).round());

// Function to get ColorScheme based on theme
ColorScheme kColor(BuildContext context) => Theme.of(context).colorScheme;

ColorFilter svgColor(Color color) => ColorFilter.mode(color, BlendMode.srcIn);

class Light {
  static const Color primary = Color(0xFF1B5E20); // Deep Green
  static const Color scaffold = Color(0xFFF8F9FA); // Very Light Grey
  static const Color card = Colors.white;
  static const Color modal = Colors.white;

  static const Color text = Color(0xFF212121);
  static const Color fadeText = Color(0xFF757575);

  static const Color primaryAccent = Color(0xFFE8F5E9);

  static const Color profitText = Color(0xFF2E7D32);
  static const Color lossText = Color(0xFFC62828);

  static const Color profitCard = Color(0xFFC8E6C9);
  static const Color onProfitCard = Color(0xFF1B5E20);

  static const Color completeCard = Color(0xFFE8F5E9);
  static const Color onCompleteCard = Color(0xFF2E7D32);

  static const Color lossCard = Color(0xFFFFEBEE);
  static const Color onLossCard = Color(0xFFC62828);
}

class Dark {
  static const Color primary = Color(0xFF81C784); // Soft Green
  static const Color scaffold = Color(0xFF121212); // Deep Charcoal
  static const Color card = Color(0xFF1E1E1E); // Slightly Brighter Charcoal
  static const Color modal = Color(0xFF1E1E1E);

  static const Color text = Color(0xFFECEFF1);
  static const Color fadeText = Color(0xFF90A4AE);

  static const Color primaryAccent = Color(0xFF2E7D32);

  static const Color profitText = Color(0xFFB9F6CA);
  static const Color lossText = Color(0xFFFF8A80);

  static const Color profitCard = Color(0xFF1B5E20);
  static const Color onProfitCard = Color(0xFFB9F6CA);

  static const Color completeCard = Color(0xFF1B5E20);
  static const Color onCompleteCard = Color(0xFFB9F6CA);

  static const Color lossCard = Color(0xFFC62828);
  static const Color onLossCard = Color(0xFFFFEBEE);
}

class KThemeData {
  static ThemeData light() => ThemeData(
    fontFamily: 'Product',
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    scaffoldBackgroundColor: Light.scaffold,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Light.primary,
      brightness: Brightness.light,
      primary: Light.primary,
      surface: Light.card,
      onSurface: Light.text,
      error: Light.lossText,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Light.card,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius(16),
        side: BorderSide(color: Colors.grey.withAlpha(25), width: 1),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Light.text),
      bodyMedium: TextStyle(color: Light.text),
      titleLarge: TextStyle(color: Light.text, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Light.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: kRadius(12)),
      ),
    ),
  );

  static ThemeData dark() => ThemeData(
    fontFamily: 'Product',
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    scaffoldBackgroundColor: Dark.scaffold,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Dark.primary,
      brightness: Brightness.dark,
      primary: Dark.primary,
      surface: Dark.card,
      onSurface: Dark.text,
      error: Dark.lossText,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Dark.card,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius(16),
        side: BorderSide(color: Colors.white.withAlpha(15), width: 1),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Dark.text),
      bodyMedium: TextStyle(color: Dark.text),
      titleLarge: TextStyle(color: Dark.text, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Dark.primary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: kRadius(12)),
      ),
    ),
  );
}
