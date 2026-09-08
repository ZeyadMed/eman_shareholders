part of "theme.dart";

abstract interface class AppTextTheme {


  // Method to get base style with dynamic color
  static TextStyle get _baseStyle {
    final context = scaffoldMessengerKey.currentContext;
    final isDark = context != null
        ? Theme.of(context).brightness == Brightness.dark
        : false; // Default to light if context unavailable

    return TextStyle(
      height: 1.5,
      color: isDark ? Colors.white : HexColor.primaryColor,
      fontFamily: 'Diodrum',
    );
  }

  // Static base style for ThemeData (where context isn't available)
  static TextStyle _staticBaseStyle(Color color) => TextStyle(
    height: 1.5,
    color: color,
    fontFamily: 'Diodrum',
  );

  // Dynamic text styles (now work WITHOUT passing context!)
  static TextStyle get heading1 => _baseStyle.copyWith(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get heading2 => _baseStyle.copyWith(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get body1 => _baseStyle.copyWith(fontSize: 16.sp);

  static TextStyle get body1Bold => _baseStyle.copyWith(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get body2 => _baseStyle.copyWith(fontSize: 14.sp);

  static TextStyle get caption => _baseStyle.copyWith(fontSize: 12.sp);

  static TextStyle get text9 => _baseStyle.copyWith(fontSize: 9.sp);

  static TextStyle get captionBold => _baseStyle.copyWith(
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get bodyLarge => _baseStyle.copyWith(fontSize: 30.sp);

  static TextStyle get bodyMedium => _baseStyle.copyWith(fontSize: 25.sp);

  static TextStyle get bodySmall => _baseStyle.copyWith(fontSize: 14.sp);

  static TextStyle get labelLarge => _baseStyle.copyWith(fontSize: 14.sp);

  static TextStyle get labelMedium => _baseStyle.copyWith(fontSize: 12.sp);

  static TextStyle get labelSmall => _baseStyle.copyWith(fontSize: 10.sp);

  static TextStyle get titleLarge => _baseStyle.copyWith(fontSize: 22.sp);

  static TextStyle get titleMedium => _baseStyle.copyWith(fontSize: 20.sp);

  static TextStyle get titleSmall => _baseStyle.copyWith(fontSize: 18.sp);

  static TextStyle get displayLarge => _baseStyle.copyWith(fontSize: 34.sp);

  static TextStyle get displayMedium => _baseStyle.copyWith(fontSize: 28.sp);

  static TextStyle get displaySmall => _baseStyle.copyWith(fontSize: 22.sp);

  static TextStyle get headlineLarge => _baseStyle.copyWith(
    fontSize: 35.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get headlineMedium => _baseStyle.copyWith(fontSize: 28.sp);

  static TextStyle get headlineSmall => _baseStyle.copyWith(fontSize: 24.sp);

  // Static versions for ThemeData (where context isn't available)
  // Light theme versions
  static TextStyle get bodyLargeLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 30.sp);
  static TextStyle get bodyMediumLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 25.sp);
  static TextStyle get bodySmallLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 14.sp);
  static TextStyle get labelLargeLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 14.sp);
  static TextStyle get labelMediumLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 12.sp);
  static TextStyle get labelSmallLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 10.sp);
  static TextStyle get titleLargeLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 22.sp);
  static TextStyle get titleMediumLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 20.sp);
  static TextStyle get titleSmallLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 18.sp);
  static TextStyle get displayLargeLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 34.sp);
  static TextStyle get displayMediumLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 28.sp);
  static TextStyle get displaySmallLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 22.sp);
  static TextStyle get headlineLargeLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 35.sp, fontWeight: FontWeight.bold);
  static TextStyle get headlineMediumLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 28.sp);
  static TextStyle get headlineSmallLight => _staticBaseStyle(HexColor.primaryColor).copyWith(fontSize: 24.sp);

  // Dark theme versions
  static TextStyle get bodyLargeDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 30.sp);
  static TextStyle get bodyMediumDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 25.sp);
  static TextStyle get bodySmallDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 14.sp);
  static TextStyle get labelLargeDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 14.sp);
  static TextStyle get labelMediumDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 12.sp);
  static TextStyle get labelSmallDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 10.sp);
  static TextStyle get titleLargeDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 22.sp);
  static TextStyle get titleMediumDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 20.sp);
  static TextStyle get titleSmallDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 18.sp);
  static TextStyle get displayLargeDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 34.sp);
  static TextStyle get displayMediumDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 28.sp);
  static TextStyle get displaySmallDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 22.sp);
  static TextStyle get headlineLargeDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 35.sp, fontWeight: FontWeight.bold);
  static TextStyle get headlineMediumDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 28.sp);
  static TextStyle get headlineSmallDark => _staticBaseStyle(Colors.white).copyWith(fontSize: 24.sp);
}
