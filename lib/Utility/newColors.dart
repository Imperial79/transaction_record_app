import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Raw color tokens for the app.
/// These should be used to build the [AppColors] extension and [ThemeData].
class AppPalette {
  // Light Mode Tokens
  static const Color primaryLight = Color(0xFF1B5E20);
  static const Color scaffoldLight = Color(0xFFFBFBFE);
  static const Color cardLight = Colors.white;
  static const Color textLight = Color(0xFF1A1C1E);
  static const Color fadeTextLight = Color(0xFF74777F);
  static const Color profitLight = Color(0xFF006D31);
  static const Color lossLight = Color(0xFFBA1A1A);
  static const Color profitCardLight = Color(0xFFD3E8D3);
  static const Color lossCardLight = Color(0xFFFFDAD6);

  // Dark Mode Tokens
  static const Color primaryDark = Color(0xFF81C784);
  static const Color scaffoldDark = Color(0xFF0F1113);
  static const Color cardDark = Color(0xFF1A1C1E);
  static const Color textDark = Color(0xFFE2E2E6);
  static const Color fadeTextDark = Color(0xFF90A4AE);
  static const Color profitDark = Color(
    0xFF00E676,
  ); // Illuminated vibrant green for dark mode
  static const Color lossDark = Color(0xFFFFB4AB);
  static const Color profitCardDark = Color(0xFF005324);
  static const Color lossCardDark = Color(0xFF93000A);

  // Universal
  static const Color blue = Color(0xFF2196F3);
  static const Color amber = Color(0xFFFFC107);
}

/// Theme extension for custom semantic colors that aren't part of [ColorScheme].
class AppColors extends ThemeExtension<AppColors> {
  final Color profit;
  final Color loss;
  final Color profitCard;
  final Color lossCard;
  final Color fadeText;
  final Color link;

  const AppColors({
    required this.profit,
    required this.loss,
    required this.profitCard,
    required this.lossCard,
    required this.fadeText,
    required this.link,
  });

  @override
  AppColors copyWith({
    Color? profit,
    Color? loss,
    Color? profitCard,
    Color? lossCard,
    Color? fadeText,
    Color? link,
  }) {
    return AppColors(
      profit: profit ?? this.profit,
      loss: loss ?? this.loss,
      profitCard: profitCard ?? this.profitCard,
      lossCard: lossCard ?? this.lossCard,
      fadeText: fadeText ?? this.fadeText,
      link: link ?? this.link,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      profit: Color.lerp(profit, other.profit, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      profitCard: Color.lerp(profitCard, other.profitCard, t)!,
      lossCard: Color.lerp(lossCard, other.lossCard, t)!,
      fadeText: Color.lerp(fadeText, other.fadeText, t)!,
      link: Color.lerp(link, other.link, t)!,
    );
  }

  static const light = AppColors(
    profit: AppPalette.profitLight,
    loss: AppPalette.lossLight,
    profitCard: AppPalette.profitCardLight,
    lossCard: AppPalette.lossCardLight,
    fadeText: AppPalette.fadeTextLight,
    link: Color(0xFF0D47A1),
  );

  static const dark = AppColors(
    profit: AppPalette.profitDark,
    loss: AppPalette.lossDark,
    profitCard:
        AppPalette.profitDark, // Use vibrant green for interaction elements
    lossCard: AppPalette.lossCardDark,
    fadeText: AppPalette.fadeTextDark,
    link: Color(0xFF64B5F6),
  );
}

extension ColorUtils on Color {
  Color lighten([double opacity = .15]) {
    return withAlpha((opacity * 255).round());
  }

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

extension ThemeExtensionGetter on BuildContext {
  AppColors get appColors {
    if (!mounted) return AppColors.light;
    return Theme.of(this).extension<AppColors>() ?? AppColors.light;
  }

  ColorScheme get colorScheme {
    if (!mounted) return KThemeData.light().colorScheme;
    return Theme.of(this).colorScheme;
  }

  bool get isDarkMode {
    if (!mounted) return false;
    return Theme.of(this).brightness == Brightness.dark;
  }

  Color get primaryColor => colorScheme.primary;
  Color get scaffoldColor => Theme.of(this).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(this).cardTheme.color ?? colorScheme.surface;

  // Semantic Shortcuts
  Color get profitColor => appColors.profit;
  Color get lossColor => appColors.loss;
  Color get profitCardColor => appColors.profitCard;
  Color get lossCardColor => appColors.lossCard;
  Color get textColor => colorScheme.onSurface;
  Color get fadeTextColor => appColors.fadeText;
  Color get linkColor => appColors.link;
}

// Legacy support for classes Light and Dark if used elsewhere
class Light {
  static const Color primary = AppPalette.primaryLight;
  static const Color scaffold = AppPalette.scaffoldLight;
  static const Color card = AppPalette.cardLight;
  static const Color text = AppPalette.textLight;
  static const Color fadeText = AppPalette.fadeTextLight;
  static const Color profitText = AppPalette.profitLight;
  static const Color lossText = AppPalette.lossLight;
  static const Color profitCard = AppPalette.profitCardLight;
  static const Color lossCard = AppPalette.lossCardLight;
}

class Dark {
  static const Color primary = AppPalette.primaryDark;
  static const Color scaffold = AppPalette.scaffoldDark;
  static const Color card = AppPalette.cardDark;
  static const Color text = AppPalette.textDark;
  static const Color fadeText = AppPalette.fadeTextDark;
  static const Color profitText = AppPalette.profitDark;
  static const Color lossText = AppPalette.lossDark;
  static const Color profitCard = AppPalette.profitCardDark;
  static const Color lossCard = AppPalette.lossCardDark;
}

// Utility functions
Color kOpacity(Color color, double opacity) =>
    color.withAlpha((opacity * 255).round());

ColorScheme kColor(BuildContext context) => context.colorScheme;
ColorFilter svgColor(Color color) => ColorFilter.mode(color, BlendMode.srcIn);

class KThemeData {
  static ThemeData light({ColorScheme? dynamicColorScheme}) {
    final scheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: AppPalette.primaryLight,
          brightness: Brightness.light,
          primary: AppPalette.primaryLight,
          surface: AppPalette.cardLight,
          onSurface: AppPalette.textLight,
          error: AppPalette.lossLight,
        );

    return ThemeData(
      fontFamily: 'Product',
      useMaterial3: true,
      splashFactory: InkSparkle.splashFactory,
      scaffoldBackgroundColor: AppPalette.scaffoldLight,
      brightness: Brightness.light,
      extensions: [AppColors.light],
      colorScheme: scheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppPalette.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.grey.withAlpha(25), width: 1),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppPalette.textLight),
        bodyMedium: TextStyle(color: AppPalette.textLight),
        titleLarge: TextStyle(
          color: AppPalette.textLight,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppPalette.primaryLight,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }

  static ThemeData dark({ColorScheme? dynamicColorScheme}) {
    final scheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: AppPalette.primaryDark,
          brightness: Brightness.dark,
          primary: AppPalette.primaryDark,
          surface: AppPalette.cardDark,
          onSurface: AppPalette.textDark,
          error: AppPalette.lossDark,
        );

    return ThemeData(
      fontFamily: 'Product',
      useMaterial3: true,
      splashFactory: InkSparkle.splashFactory,
      scaffoldBackgroundColor: AppPalette.scaffoldDark,
      brightness: Brightness.dark,
      extensions: [AppColors.dark],
      colorScheme: scheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppPalette.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.white.withAlpha(15), width: 1),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppPalette.textDark),
        bodyMedium: TextStyle(color: AppPalette.textDark),
        titleLarge: TextStyle(
          color: AppPalette.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppPalette.primaryDark,
          foregroundColor: Colors.black,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }
}
