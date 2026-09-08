part of 'extensions.dart';

extension HexColor on Color {
  static Color fromHex(String hexCode) {
    final buffer = StringBuffer();

    if (hexCode.length == 6 || hexCode.length == 7) buffer.write('ff');
    buffer.write(hexCode.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Color darken(double percent) {
    assert(0 <= percent && percent <= 1, 'percent must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final darkenedHsl = hsl.withLightness(hsl.lightness - percent);
    return darkenedHsl.toColor();
  }

  /// Lightens a color by the given [percent].
  Color lighten(double percent) {
    assert(0 <= percent && percent <= 1, 'percent must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final lightenedHsl = hsl.withLightness(hsl.lightness + percent);
    return lightenedHsl.toColor();
  }

  /// Creates a shade of the color by the given [shade] value.
  Color shade(double shade) {
    assert(-1 <= shade && shade <= 1, 'shade must be between -1 and 1');
    if (shade > 0) {
      return lighten(shade);
    } else if (shade < 0) {
      return darken(-shade);
    } else {
      return this;
    }
  }

  static Color get successColor => fromHex("#008000");

  static Color get white => fromHex("#FFFFFF");

  static Color get black => fromHex("#000000");
  static Color get red => fromHex("#FF0000");
  static Color get blueLight => fromHex("#C1D2E4");

  static Color get secondaryColor => fromHex("#EF7923");
  static Color get lightBlue => fromHex("#77A1CF");


  static Color get primaryColor =>    fromHex("#15304E");
  static Color get darkPrimaryColor => fromHex("#64FFDA");
  static Color get darkSecondaryColor => fromHex("#A0410F");

  static Color get backgroundColor => fromHex("#C5C8CC");
  static Color get darkBackgroundColor => fromHex("#1E1E1E");
  static Color get errorColor => fromHex("#FF0000");

  static Color get greyColor => fromHex("#6B7280");
}
