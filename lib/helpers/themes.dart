import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? blue;
  final Color? redText;
  final Color? red;
  final Color? highlightRed;
  final Color? highlightBlue;
  final Color? primary700;
  final Color? primary600;
  final Color? primary500;
  final Color? primary400;
  final Color? primary300;
  final Color? primary200;
  final Color? primaryLv7;
  final Color? backgroundMultiLayer;
  final Color? backgroundSingleLayer;
  final Color? grayLight;
  final Color? grayDark;
  final Color? shimmerBaseColor;
  const CustomColors({
    required this.blue,
    required this.redText,
    required this.red,
    required this.highlightRed,
    required this.highlightBlue,
    required this.primary700,
    required this.primary600,
    required this.primary500,
    required this.primary400,
    required this.primary300,
    required this.primary200,
    required this.primaryLv7,
    required this.backgroundMultiLayer,
    required this.backgroundSingleLayer,
    required this.grayLight,
    required this.grayDark,
    required this.shimmerBaseColor,
  });

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? blue,
    Color? redText,
    Color? red,
    Color? highlightRed,
    Color? highlightBlue,
    Color? primary700,
    Color? primary600,
    Color? primary500,
    Color? primary400,
    Color? primary300,
    Color? primary200,
    Color? primaryLv7,
    Color? backgroundMultiLayer,
    Color? backgroundSingleLayer,
    Color? grayLight,
    Color? grayDark,
    Color? shimmerBaseColor,
  }) {
    return CustomColors(
      blue: blue ?? this.blue,
      redText: redText ?? this.redText,
      red: red ?? this.red,
      highlightRed: highlightRed ?? this.highlightRed,
      highlightBlue: highlightBlue ?? this.highlightBlue,
      primary700: primary700 ?? this.primary700,
      primary600: primary600 ?? this.primary600,
      primary500: primary500 ?? this.primary500,
      primary400: primary400 ?? this.primary400,
      primary300: primary300 ?? this.primary300,
      primary200: primary200 ?? this.primary200,
      primaryLv7: primaryLv7 ?? this.primaryLv7,
      backgroundMultiLayer: backgroundMultiLayer ?? this.backgroundMultiLayer,
      backgroundSingleLayer:
          backgroundSingleLayer ?? this.backgroundSingleLayer,
      grayLight: grayLight ?? this.grayLight,
      grayDark: grayDark ?? this.grayDark,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
      ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      blue: Color.lerp(blue, other.blue, t),
      redText: Color.lerp(redText, other.redText, t),
      red: Color.lerp(red, other.red, t),
      highlightRed: Color.lerp(highlightRed, other.highlightRed, t),
      highlightBlue: Color.lerp(highlightBlue, other.highlightBlue, t),
      primary700: Color.lerp(primary700, other.primary700, t),
      primary600: Color.lerp(primary600, other.primary600, t),
      primary500: Color.lerp(primary500, other.primary500, t),
      primary400: Color.lerp(primary400, other.primary400, t),
      primary300: Color.lerp(primary300, other.primary300, t),
      primary200: Color.lerp(primary200, other.primary200, t),
      primaryLv7: Color.lerp(primaryLv7, other.primaryLv7, t),
      backgroundMultiLayer:
          Color.lerp(backgroundMultiLayer, other.backgroundMultiLayer, t),
      backgroundSingleLayer:
          Color.lerp(backgroundSingleLayer, other.backgroundSingleLayer, t),
      grayLight: Color.lerp(grayLight, other.grayLight, t),
      grayDark: Color.lerp(grayDark, other.grayDark, t),
      shimmerBaseColor: Color.lerp(shimmerBaseColor, other.shimmerBaseColor, t),
    );
  }
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    backgroundColor: Colors.white,
    foregroundColor: meshBlack87,
    elevation: 1,
    shadowColor: meshBlack20,
  ),
  scaffoldBackgroundColor: meshGray,
  backgroundColor: Colors.white,
  textTheme: TextTheme(
    headlineLarge: const TextStyle(
      color: meshBlack87,
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    headlineMedium: const TextStyle(
      color: meshBlack87,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    headlineSmall: TextStyle(
      color: meshBlack87,
      fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
      fontSize: 18,
    ),
    displayMedium: const TextStyle(
      color: meshBlack66,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    displaySmall: const TextStyle(
      color: meshBlack66,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    bodyLarge: const TextStyle(
      color: meshBlack50,
      fontWeight: FontWeight.w400,
      fontSize: 18,
    ),
    bodyMedium: const TextStyle(
      color: meshBlack50,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    bodySmall: const TextStyle(
      color: meshBlack50,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    titleLarge: const TextStyle(
      color: meshBlack87,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    titleMedium: const TextStyle(
      color: meshBlack87,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    titleSmall: const TextStyle(
      color: meshBlack87,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    labelMedium: const TextStyle(
      color: meshBlack30,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: meshBlack10,
    thickness: 0.5,
    space: 1,
  ),
  dividerColor: meshBlack20,
  primaryColor: meshBlack66,
  primaryColorDark: meshBlack87,
  primaryColorLight: meshBlack50,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: meshBlack87,
    unselectedItemColor: meshBlack50,
  ),
  shadowColor: meshBlack10,
  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      blue: meshBlue,
      redText: meshRedText,
      red: meshRed,
      highlightRed: meshHighlightRed,
      highlightBlue: meshHighlightBlue,
      primary700: meshBlack87,
      primary600: meshBlack66,
      primary500: meshBlack50,
      primary400: meshBlack30,
      primary300: meshBlack20,
      primary200: meshBlack10,
      primaryLv7: meshBlack05,
      backgroundMultiLayer: meshGray,
      backgroundSingleLayer: Colors.white,
      grayLight: meshGrayLight,
      grayDark: meshGrayDark,
      shimmerBaseColor: meshBlack15,
    ),
  ],
  cardTheme: const CardTheme(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: meshBlack10, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
    ),
    clipBehavior: Clip.antiAlias,
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.light,
    backgroundColor: meshBlackDefault,
    foregroundColor: meshGray,
    elevation: 1,
    shadowColor: meshGray20,
  ),
  scaffoldBackgroundColor: meshBlackDark,
  backgroundColor: meshBlackDefault,
  textTheme: TextTheme(
    headlineLarge: const TextStyle(
      color: meshGray,
      fontWeight: FontWeight.w500,
      fontSize: 24,
    ),
    headlineMedium: const TextStyle(
      color: meshGray,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    headlineSmall: TextStyle(
      color: meshGray,
      fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
      fontSize: 18,
    ),
    displayMedium: const TextStyle(
      color: meshGray87,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    displaySmall: const TextStyle(
      color: meshGray87,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    bodyLarge: const TextStyle(
      color: meshGray66,
      fontWeight: FontWeight.w400,
      fontSize: 18,
    ),
    bodyMedium: const TextStyle(
      color: meshGray66,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    bodySmall: const TextStyle(
      color: meshGray66,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    titleLarge: const TextStyle(
      color: meshGray,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    titleMedium: const TextStyle(
      color: meshGray,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    titleSmall: const TextStyle(
      color: meshGray,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    labelMedium: const TextStyle(
      color: meshGray50,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: meshGray20,
    thickness: 0.5,
    space: 1,
  ),
  dividerColor: meshGray30,
  primaryColor: meshGray87,
  primaryColorDark: meshGray,
  primaryColorLight: meshGray66,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: meshBlackDefault,
    selectedItemColor: meshGray,
    unselectedItemColor: meshGray66,
  ),
  shadowColor: meshGray20,
  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      blue: meshBlueDarkMode,
      redText: meshRedTextDarkMode,
      red: meshRedDarkMode,
      highlightRed: meshHighlightRedDarkMode,
      highlightBlue: meshHighlightBlueDarkMode,
      primary700: meshGray,
      primary600: meshGray87,
      primary500: meshGray66,
      primary400: meshGray50,
      primary300: meshGray30,
      primary200: meshGray20,
      primaryLv7: meshGray10,
      backgroundMultiLayer: meshBlackLight,
      backgroundSingleLayer: meshBlackDefault,
      grayLight: meshGrayLightDarkMode,
      grayDark: meshGrayDarkDarkMode,
      shimmerBaseColor: meshGray15,
    ),
  ],
  cardTheme: const CardTheme(
    color: meshBlackDefault,
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: meshGray20, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
    ),
    clipBehavior: Clip.antiAlias,
  ),
);
