part of 'theme.dart';

mixin AppThemeData on ThemeData {
  static ThemeData light(BuildContext context) => ThemeData(
    brightness: Brightness.light,
    primaryColor: HexColor.primaryColor,
    colorScheme: ColorScheme.light(
      primary: HexColor.primaryColor,
      secondary: HexColor.fromHex('#083740'),
      surface: Colors.white,
      error: Colors.red,

      onPrimary: const Color.fromRGBO(27, 22, 94, 1),
      onSecondary: const Color.fromRGBO(22, 82, 166, 1),
      onSurface: Colors.black,
      onError: Colors.white,
      outlineVariant: Colors.blueAccent,
      onInverseSurface: Colors.grey[200],
    ),

    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: AppTextTheme.headlineLarge,
      surfaceTintColor: Colors.white,
      elevation: 0,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.teal,
      selectionColor: Colors.teal,
      selectionHandleColor: Colors.teal,
    ),
    fontFamily: 'Diodrum',
    textTheme:
        TextTheme(
          bodyLarge: AppTextTheme.bodyLarge,
          bodyMedium: AppTextTheme.bodyMedium,
          bodySmall: AppTextTheme.bodySmall,
          labelLarge: AppTextTheme.labelLarge,
          labelMedium: AppTextTheme.labelMedium,
          labelSmall: AppTextTheme.labelSmall,
          titleLarge: AppTextTheme.titleLarge,
          titleMedium: AppTextTheme.titleMedium,
          titleSmall: AppTextTheme.titleSmall,
          displayLarge: AppTextTheme.displayLarge,
          displayMedium: AppTextTheme.displayMedium,
          displaySmall: AppTextTheme.displaySmall,
          headlineLarge: AppTextTheme.headlineLarge,
          headlineMedium: AppTextTheme.headlineMedium,
          headlineSmall: AppTextTheme.headlineSmall,
        )..apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
          fontFamilyFallback: ['Arial', 'sans-serif'],
          fontFamily: 'Diodrum',
        ),

    inputDecorationTheme: InputDecorationTheme(
      errorStyle: AppTextTheme.bodyMedium.copyWith(
        color: Colors.red,
        fontSize: 20.sp,
      ),
      hintStyle: AppTextTheme.caption.copyWith(color: HexColor.greyColor),
    ),
    // textSelectionTheme: ,
    iconTheme: const IconThemeData(color: Colors.black87),
  );

  static CupertinoThemeData cupertinoLight(BuildContext context) =>
      CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: HexColor.primaryColor,
        primaryContrastingColor: const Color.fromRGBO(27, 22, 94, 1),
        scaffoldBackgroundColor: Colors.white,
        barBackgroundColor: Colors.white,

        textTheme: CupertinoTextThemeData(
          primaryColor: Colors.black,

          // Body text styles
          textStyle: AppTextTheme.bodyMedium.copyWith(
            color: Colors.black,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Action/Button text
          actionTextStyle: AppTextTheme.labelLarge.copyWith(
            color: HexColor.primaryColor,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Tab bar labels
          tabLabelTextStyle: AppTextTheme.labelMedium.copyWith(
            color: Colors.black,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Navigation bar title
          navTitleTextStyle: AppTextTheme.headlineLarge.copyWith(
            color: Colors.black,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Large navigation title
          navLargeTitleTextStyle: AppTextTheme.displayLarge.copyWith(
            color: Colors.black,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Navigation action buttons
          navActionTextStyle: AppTextTheme.labelLarge.copyWith(
            color: HexColor.primaryColor,
            fontFamily: 'Montserrat',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Picker text
          pickerTextStyle: AppTextTheme.bodyMedium.copyWith(
            color: Colors.black,
            fontFamily: 'Montserrat',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Date/Time picker
          dateTimePickerTextStyle: AppTextTheme.bodyMedium.copyWith(
            color: Colors.black,
            fontFamily: 'Montserrat',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),
        ),
      );
  static ThemeData dark(BuildContext context) => ThemeData(
    brightness: Brightness.dark,
    primaryColor: HexColor.darkPrimaryColor,
    colorScheme: ColorScheme.dark(
      primary: HexColor.darkPrimaryColor,
      secondary: HexColor.fromHex('#0a4a56'),
      surface: HexColor.darkBackgroundColor,
      error: Colors.redAccent,

      onPrimary: const Color.fromRGBO(200, 195, 255, 1),
      onSecondary: const Color.fromRGBO(150, 200, 255, 1),
      onSurface: Colors.white,
      onError: HexColor.darkBackgroundColor,
      outlineVariant: Colors.blueAccent.shade200,
      onInverseSurface: Colors.grey[800],
    ),

    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: HexColor.darkBackgroundColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: HexColor.darkBackgroundColor,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: AppTextTheme.headlineLarge.copyWith(color: Colors.white),
      surfaceTintColor: HexColor.darkBackgroundColor,
      elevation: 0,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.tealAccent[900],
      selectionColor: Colors.tealAccent[900],
      selectionHandleColor: Colors.tealAccent[900],
    ),
    fontFamily: 'Diodrum',
    textTheme:
        TextTheme(
          bodyLarge: AppTextTheme.bodyLarge,
          bodyMedium: AppTextTheme.bodyMedium,
          bodySmall: AppTextTheme.bodySmall,
          labelLarge: AppTextTheme.labelLarge,
          labelMedium: AppTextTheme.labelMedium,
          labelSmall: AppTextTheme.labelSmall,
          titleLarge: AppTextTheme.titleLarge,
          titleMedium: AppTextTheme.titleMedium,
          titleSmall: AppTextTheme.titleSmall,
          displayLarge: AppTextTheme.displayLarge,
          displayMedium: AppTextTheme.displayMedium,
          displaySmall: AppTextTheme.displaySmall,
          headlineLarge: AppTextTheme.headlineLarge,
          headlineMedium: AppTextTheme.headlineMedium,
          headlineSmall: AppTextTheme.headlineSmall,
        )..apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          fontFamilyFallback: ['Arial', 'sans-serif'],
          fontFamily: 'Diodrum',
        ),

    inputDecorationTheme: InputDecorationTheme(
      errorStyle: AppTextTheme.bodyMedium.copyWith(
        color: Colors.redAccent,
        fontSize: 20.sp,
      ),
      hintStyle: AppTextTheme.caption.copyWith(color: HexColor.greyColor),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );

  static CupertinoThemeData cupertinoDark(BuildContext context) =>
      CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: HexColor.primaryColor,
        primaryContrastingColor: const Color.fromRGBO(200, 195, 255, 1),
        scaffoldBackgroundColor: const Color(0xFF121212),
        barBackgroundColor: const Color(0xFF1E1E1E),

        textTheme: CupertinoTextThemeData(
          primaryColor: Colors.white,

          // Body text styles
          textStyle: AppTextTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Action/Button text
          actionTextStyle: AppTextTheme.labelLarge.copyWith(
            color: HexColor.darkPrimaryColor,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Tab bar labels
          tabLabelTextStyle: AppTextTheme.labelMedium.copyWith(
            color: Colors.white,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Navigation bar title
          navTitleTextStyle: AppTextTheme.headlineLarge.copyWith(
            color: Colors.white,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Large navigation title
          navLargeTitleTextStyle: AppTextTheme.displayLarge.copyWith(
            color: Colors.white,
            fontFamily: 'Diodrum',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Navigation action buttons
          navActionTextStyle: AppTextTheme.labelLarge.copyWith(
            color: HexColor.darkPrimaryColor,
            fontFamily: 'Montserrat',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Picker text
          pickerTextStyle: AppTextTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),

          // Date/Time picker
          dateTimePickerTextStyle: AppTextTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontFamilyFallback: ['Arial', 'sans-serif'],
          ),
        ),
      );
}
