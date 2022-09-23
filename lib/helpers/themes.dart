import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? systemBlue;
  final Color? redText;
  final Color? systemRed;
  final Color? highlightRed;
  final Color? highlightBlue;
  const CustomColors({
    required this.systemBlue,
    required this.redText,
    required this.systemRed,
    required this.highlightRed,
    required this.highlightBlue,
  });

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? systemBlue,
    Color? redText,
    Color? systemRed,
    Color? highlightRed,
    Color? highlightBlue,
  }) {
    return CustomColors(
      systemBlue: systemBlue ?? this.systemBlue,
      redText: redText ?? this.redText,
      systemRed: systemRed ?? this.systemRed,
      highlightRed: highlightRed ?? this.highlightRed,
      highlightBlue: highlightBlue ?? this.highlightBlue,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
      ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      systemBlue: Color.lerp(systemBlue, other.systemBlue, t),
      redText: Color.lerp(redText, other.redText, t),
      systemRed: Color.lerp(systemRed, other.systemRed, t),
      highlightRed: Color.lerp(highlightRed, other.highlightRed, t),
      highlightBlue: Color.lerp(highlightBlue, other.highlightBlue, t),
    );
  }
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    backgroundColor: Colors.white,
    foregroundColor: meshBlack87,
    elevation: 0.5,
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
      fontSize: 16,
    ),
    displaySmall: const TextStyle(
      color: meshBlack66,
      fontSize: 14,
    ),
    bodyMedium: const TextStyle(
      color: meshBlack50,
      fontSize: 16,
    ),
    bodySmall: const TextStyle(
      color: meshBlack50,
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
      fontSize: 14,
    ),
    labelMedium: const TextStyle(
      color: meshBlack30,
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
      systemBlue: meshBlue,
      redText: meshRedText,
      systemRed: meshRed,
      highlightRed: meshHighlightRed,
      highlightBlue: meshHighlightBlue,
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
    elevation: 0.5,
  ),
  scaffoldBackgroundColor: meshBlackDark,
  backgroundColor: meshBlackDefault,
  textTheme: TextTheme(
    headlineLarge: const TextStyle(
      color: meshGray,
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    headlineMedium: const TextStyle(
      color: meshGray,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    headlineSmall: TextStyle(
      color: meshGray,
      fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
      fontSize: 18,
    ),
    displayMedium: const TextStyle(
      color: meshGray87,
      fontSize: 16,
    ),
    displaySmall: const TextStyle(
      color: meshGray87,
      fontSize: 14,
    ),
    bodyMedium: const TextStyle(
      color: meshGray66,
      fontSize: 16,
    ),
    bodySmall: const TextStyle(
      color: meshGray66,
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
      fontSize: 14,
    ),
    labelMedium: const TextStyle(
      color: meshGray50,
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
      systemBlue: meshBlueDarkMode,
      redText: meshRedTextDarkMode,
      systemRed: meshRedDarkMode,
      highlightRed: meshHighlightRedDarkMode,
      highlightBlue: meshHighlightBlueDarkMode,
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
